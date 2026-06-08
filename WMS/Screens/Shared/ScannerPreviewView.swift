import AVFoundation
import SwiftUI

struct ScannerPreviewView: UIViewRepresentable {
    let scanAreaSize: CGSize?
    let isScanningEnabled: Bool
    let onScan: (String) -> Void

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.onLayout = { [weak coordinator = context.coordinator] previewView in
            coordinator?.setScanAreaSize(scanAreaSize, for: previewView)
        }
        context.coordinator.configureSession(for: view)
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.onLayout = { [weak coordinator = context.coordinator] previewView in
            coordinator?.setScanAreaSize(scanAreaSize, for: previewView)
        }
        context.coordinator.setScanAreaSize(scanAreaSize, for: uiView)
        context.coordinator.setScanningEnabled(isScanningEnabled)
        context.coordinator.onScan = onScan
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isScanningEnabled: isScanningEnabled, onScan: onScan)
    }

    static func dismantleUIView(_ uiView: PreviewView, coordinator: Coordinator) {
        uiView.onLayout = nil
        coordinator.stopSession()
    }
}

final class PreviewView: UIView {
    var onLayout: ((PreviewView) -> Void)?

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?(self)
    }
}

extension ScannerPreviewView {
    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var isScanningEnabled: Bool
        var onScan: (String) -> Void

        private let session = AVCaptureSession()
        private let sessionQueue = DispatchQueue(label: "scanner.session.queue")
        private var metadataOutput: AVCaptureMetadataOutput?
        private var pendingRectOfInterest: CGRect?
        private var captureDevice: AVCaptureDevice?
        private var didScanDuringCurrentPress = false

        init(isScanningEnabled: Bool, onScan: @escaping (String) -> Void) {
            self.isScanningEnabled = isScanningEnabled
            self.onScan = onScan
        }

        func setScanningEnabled(_ isEnabled: Bool) {
            if isScanningEnabled == true && isEnabled == false {
                didScanDuringCurrentPress = false
            }

            isScanningEnabled = isEnabled
            setTorchEnabled(isEnabled)
        }

        func configureSession(for previewView: PreviewView) {
            previewView.previewLayer.videoGravity = .resizeAspectFill
            previewView.previewLayer.session = session

            startSessionIfAuthorized()
        }

        func stopSession() {
            isScanningEnabled = false
            didScanDuringCurrentPress = false
            setTorchEnabled(false)

            sessionQueue.async { [weak self] in
                guard let self, session.isRunning else { return }
                session.stopRunning()
            }
        }

        private func startSessionIfAuthorized() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                startSession()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
                    guard isGranted else { return }
                    self?.startSession()
                }
            case .denied, .restricted:
                print("Camera access is not available")
            @unknown default:
                print("Unknown camera authorization status")
            }
        }

        private func startSession() {
            sessionQueue.async { [weak self] in
                guard let self else { return }
                configureSessionIfNeeded()
                guard !session.inputs.isEmpty,
                      !session.outputs.isEmpty,
                      !session.isRunning else { return }
                session.startRunning()
            }
        }

        private func configureSessionIfNeeded() {
            guard session.inputs.isEmpty, session.outputs.isEmpty else { return }

            session.beginConfiguration()
            session.sessionPreset = .high

            guard let device = preferredVideoDevice(),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                session.commitConfiguration()
                return
            }
            captureDevice = device
            session.addInput(input)

            let metadataOutput = AVCaptureMetadataOutput()
            guard session.canAddOutput(metadataOutput) else {
                session.commitConfiguration()
                return
            }

            session.addOutput(metadataOutput)
            self.metadataOutput = metadataOutput
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = supportedMetadataObjectTypes(for: metadataOutput)

            if let pendingRectOfInterest {
                metadataOutput.rectOfInterest = pendingRectOfInterest
            }

            session.commitConfiguration()
        }

        private func preferredVideoDevice() -> AVCaptureDevice? {
            AVCaptureDevice.default(
                .builtInUltraWideCamera,
                for: .video,
                position: .back
            ) ?? AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ) ?? AVCaptureDevice.default(for: .video)
        }

        private func supportedMetadataObjectTypes(
            for output: AVCaptureMetadataOutput
        ) -> [AVMetadataObject.ObjectType] {
            let preferredTypes: [AVMetadataObject.ObjectType] = [
                .ean13,
                .ean8,
                .code128,
                .code39,
                .code93,
                .interleaved2of5,
                .itf14,
                .upce,
                .qr,
                .dataMatrix,
                .pdf417
            ]

            let supportedTypes = preferredTypes.filter {
                output.availableMetadataObjectTypes.contains($0)
            }

            return supportedTypes.isEmpty
                ? output.availableMetadataObjectTypes
                : supportedTypes
        }

        func setScanAreaSize(_ size: CGSize?, for previewView: PreviewView) {
            let visibleBounds = previewView.bounds
            guard visibleBounds.width > 0, visibleBounds.height > 0 else { return }

            let scanRect: CGRect
            if let size {
                let width = min(size.width, visibleBounds.width)
                let height = min(size.height, visibleBounds.height)
                scanRect = CGRect(
                    x: visibleBounds.midX - width / 2,
                    y: visibleBounds.midY - height / 2,
                    width: width,
                    height: height
                )
            } else {
                scanRect = visibleBounds
            }

            let rectOfInterest = previewView.previewLayer
                .metadataOutputRectConverted(fromLayerRect: scanRect)

            sessionQueue.async { [weak self] in
                guard let self else { return }
                pendingRectOfInterest = rectOfInterest
                metadataOutput?.rectOfInterest = rectOfInterest
            }
        }

        private func setTorchEnabled(_ isEnabled: Bool) {
            sessionQueue.async { [weak self] in
                guard let device = self?.captureDevice, device.hasTorch else { return }
                guard device.torchMode != (isEnabled ? .on : .off) else { return }

                do {
                    try device.lockForConfiguration()
                    defer {
                        device.unlockForConfiguration()
                    }

                    device.torchMode = isEnabled ? .on : .off
                } catch {
                    print("Failed to change torch mode:", error)
                }
            }
        }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard isScanningEnabled, !didScanDuringCurrentPress else { return }
            guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let scannedCode = metadataObject.stringValue else { return }

            didScanDuringCurrentPress = true
            onScan(scannedCode)
        }
    }
}
