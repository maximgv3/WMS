import SwiftUI
import UIKit

struct CameraShot {
    let data: Data
    let thumbnail: Image
}

struct CameraPickerView: UIViewControllerRepresentable {
    let hint: String
    var onFinish: (CameraShot?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.cameraOverlayView = hintOverlay(over: picker.view)
        return picker
    }

    func updateUIViewController(
        _ picker: UIImagePickerController,
        context: Context
    ) {
        context.coordinator.onFinish = onFinish
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func hintOverlay(over pickerView: UIView) -> UIView {
        let overlay = UIView(frame: pickerView.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.isUserInteractionEnabled = false

        let label = UILabel()
        label.text = hint
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.shadowColor = UIColor.black.withAlphaComponent(0.5)
        label.shadowOffset = CGSize(width: 0, height: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(
                equalTo: overlay.safeAreaLayoutGuide.topAnchor,
                constant: 60
            ),
            label.leadingAnchor.constraint(
                equalTo: overlay.leadingAnchor,
                constant: 24
            ),
            label.trailingAnchor.constraint(
                equalTo: overlay.trailingAnchor,
                constant: -24
            ),
        ])
        return overlay
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate,
        UINavigationControllerDelegate
    {
        var onFinish: (CameraShot?) -> Void = { _ in }

        // 96 = квадрат 32pt в строке списка на экране ×3
        private let thumbnailSize = CGSize(width: 96, height: 96)
        private let maxPhotoSide: CGFloat = 2048
        private let photoQuality: CGFloat = 0.8

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController
                .InfoKey: Any]
        ) {
            onFinish(shot(from: info[.originalImage] as? UIImage))
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onFinish(nil)
        }

        private func shot(from image: UIImage?) -> CameraShot? {
            guard let image,
                let data = downscaled(image).jpegData(
                    compressionQuality: photoQuality
                )
            else {
                return nil
            }
            let thumbnail = image.preparingThumbnail(of: thumbnailSize) ?? image
            return CameraShot(data: data, thumbnail: Image(uiImage: thumbnail))
        }

        private func downscaled(_ image: UIImage) -> UIImage {
            let side = max(image.size.width, image.size.height)
            guard side > maxPhotoSide else { return image }
            return image.preparingThumbnail(
                of: CGSize(width: maxPhotoSide, height: maxPhotoSide)
            ) ?? image
        }
    }
}
