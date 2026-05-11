/// Обертка над AVFoundation scanner.
/// Комментарии намеренно подробные: этот файл используется для изучения camera capture APIs.

import AVFoundation // Подключает AVFoundation: камеру, AVCaptureSession, metadata scanner и preview layer.
import SwiftUI // Подключает SwiftUI, чтобы использовать ScannerPreviewView как обычную SwiftUI-вью.

struct ScannerPreviewView: UIViewRepresentable { // SwiftUI-обёртка для UIKit-view с камерой.
    let scanAreaSize: CGSize? // Размер области, внутри которой scanner принимает коды. nil = вся видимая область preview.
    let isScanningEnabled: Bool // Флаг: сейчас сканы нужно принимать или игнорировать.
    let onScan: (String) -> Void // Callback, который вызывается, когда камера считала код.

    func makeUIView(context: Context) -> PreviewView { // Создаёт UIKit-view один раз при появлении SwiftUI-вью.
        let view = PreviewView() // Создаём view, внутри которой будет жить preview камеры.
        view.onLayout = { [weak coordinator = context.coordinator] previewView in // Когда SwiftUI выдаст view финальный размер, пересчитаем область скана.
            coordinator?.setScanAreaSize(scanAreaSize, for: previewView)
        }
        context.coordinator.configureSession(for: view) // Просим coordinator настроить камеру и привязать её к этой view.
        return view // Возвращаем UIKit-view в SwiftUI.
    }

    func updateUIView(_ uiView: PreviewView, context: Context) { // Вызывается SwiftUI при изменении входных данных view.
        uiView.onLayout = { [weak coordinator = context.coordinator] previewView in // Обновляем замыкание, чтобы оно видело актуальный scanAreaSize.
            coordinator?.setScanAreaSize(scanAreaSize, for: previewView)
        }
        context.coordinator.setScanAreaSize(scanAreaSize, for: uiView) // Ограничиваем сканирование видимой зоной preview.
        context.coordinator.setScanningEnabled(isScanningEnabled) // Передаём coordinator актуальное состояние: сканировать или нет.
        context.coordinator.onScan = onScan // Обновляем callback на случай, если SwiftUI пересоздал замыкание.
    }

    func makeCoordinator() -> Coordinator { // Создаёт объект-посредник между SwiftUI и AVCaptureMetadataOutputDelegate.
        Coordinator(isScanningEnabled: isScanningEnabled, onScan: onScan) // Передаём стартовое состояние и callback в coordinator.
    }

    static func dismantleUIView(_ uiView: PreviewView, coordinator: Coordinator) { // Вызывается, когда SwiftUI убирает UIKit-view с экрана.
        uiView.onLayout = nil // Разрываем связь view -> coordinator, чтобы не держать лишние ссылки.
        coordinator.stopSession() // Останавливаем камеру и выключаем фонарик при уходе с экрана.
    }
}

final class PreviewView: UIView { // UIKit-view, которая умеет показывать camera preview.
    var onLayout: ((PreviewView) -> Void)? // Callback нужен, потому что bounds становятся точными только после layout.

    override class var layerClass: AnyClass { // Говорим UIKit, какой CALayer использовать как основной слой этой view.
        AVCaptureVideoPreviewLayer.self // Вместо обычного слоя используем слой, который показывает поток с камеры.
    }

    var previewLayer: AVCaptureVideoPreviewLayer { // Удобное свойство для доступа к layer как к AVCaptureVideoPreviewLayer.
        layer as! AVCaptureVideoPreviewLayer // Приводим базовый layer к нужному типу; безопасно, потому что layerClass задан выше.
    }

    override func layoutSubviews() { // UIKit вызывает этот метод при изменении размера view.
        super.layoutSubviews()
        onLayout?(self) // После layout пересчитываем rectOfInterest под реальную видимую область.
    }
}

extension ScannerPreviewView { // Расширение, чтобы держать Coordinator рядом с ScannerPreviewView.
    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate { // Coordinator получает события распознавания штрихкодов от AVFoundation.
        var isScanningEnabled: Bool // Хранит текущее состояние: принимать сканы или игнорировать.
        var onScan: (String) -> Void // Хранит callback, который отдаёт считанный код наружу.

        private let session = AVCaptureSession() // Сессия камеры: объединяет input камеры и output распознавания.
        private let sessionQueue = DispatchQueue(label: "scanner.session.queue") // Очередь для настройки и запуска камеры не на main thread.
        private var metadataOutput: AVCaptureMetadataOutput? // Output, которому задаём видимую область сканирования.
        private var pendingRectOfInterest: CGRect? // Последняя область скана, если она посчиталась до создания metadata output.
        private var captureDevice: AVCaptureDevice? // Камера, которую используем для preview, скана и управления фонариком.
        private var didScanDuringCurrentPress = false // Защита: одно удержание кнопки даёт максимум один принятый скан.

        init(isScanningEnabled: Bool, onScan: @escaping (String) -> Void) { // Инициализатор coordinator.
            self.isScanningEnabled = isScanningEnabled // Сохраняем стартовое состояние сканирования.
            self.onScan = onScan // Сохраняем callback скана.
        }

        func setScanningEnabled(_ isEnabled: Bool) { // Обновляет режим сканирования при нажатии/отпускании кнопки.
            if isScanningEnabled == true && isEnabled == false { // Проверяем момент отпускания кнопки: было включено, стало выключено.
                didScanDuringCurrentPress = false // Сбрасываем защиту, чтобы следующее удержание снова могло принять один скан.
            }

            isScanningEnabled = isEnabled // Запоминаем новое состояние сканирования.
            setTorchEnabled(isEnabled) // Включаем фонарик на время удержания кнопки и выключаем после отпускания.
        }

        func configureSession(for previewView: PreviewView) { // Настраивает preview и запускает камеру.
            previewView.previewLayer.videoGravity = .resizeAspectFill // Картинка камеры заполняет всю область view с обрезкой по краям.
            previewView.previewLayer.session = session // Привязываем AVCaptureSession к preview layer, чтобы видеть картинку.

            startSessionIfAuthorized() // Не запускаем камеру, пока не проверили разрешение пользователя.
        }

        func stopSession() { // Останавливает камеру, когда ScannerPreviewView исчезает с экрана.
            isScanningEnabled = false // После ухода с экрана новые сканы принимать нельзя.
            didScanDuringCurrentPress = false // Сбрасываем защиту, чтобы следующий запуск начал чисто.
            setTorchEnabled(false) // На всякий случай гасим фонарик перед остановкой session.

            sessionQueue.async { [weak self] in // AVCaptureSession нужно останавливать не на main thread.
                guard let self, session.isRunning else { return }
                session.stopRunning() // Полностью останавливаем поток камеры.
            }
        }

        private func startSessionIfAuthorized() { // Проверяет, можно ли приложению пользоваться камерой.
            switch AVCaptureDevice.authorizationStatus(for: .video) { // Смотрим текущий статус доступа к камере.
            case .authorized:
                startSession() // Разрешение уже есть, можно запускать session.
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in // Первый запуск: система покажет permission dialog.
                    guard isGranted else { return } // Если пользователь отказал, просто не запускаем камеру.
                    self?.startSession() // Если разрешил, запускаем session после ответа системы.
                }
            case .denied, .restricted:
                print("Camera access is not available") // Сейчас только логируем; позже можно показать UI-заглушку.
            @unknown default:
                print("Unknown camera authorization status") // Защита на случай новых статусов в будущих iOS.
            }
        }

        private func startSession() { // Настраивает AVCaptureSession и запускает поток камеры.
            sessionQueue.async { [weak self] in // Вся тяжёлая работа с камерой идёт на отдельной очереди.
                guard let self else { return }
                configureSessionIfNeeded() // Добавляем input/output только один раз.
                guard !session.inputs.isEmpty,
                      !session.outputs.isEmpty,
                      !session.isRunning else { return } // Не запускаем пустую или уже работающую session.
                session.startRunning() // Запускаем live camera feed.
            }
        }

        private func configureSessionIfNeeded() { // Настраивает AVCaptureSession один раз.
            guard session.inputs.isEmpty, session.outputs.isEmpty else { return } // Если input/output уже добавлены, повторно ничего не делаем.

            session.beginConfiguration() // Начинаем пакетную настройку сессии.
            session.sessionPreset = .high // Ставим высокое качество захвата, чтобы штрихкоды читались лучше.

            guard let device = preferredVideoDevice(), // Берём ultra wide 0.5, если она есть, иначе обычную заднюю камеру.
                  let input = try? AVCaptureDeviceInput(device: device), // Создаём input из камеры.
                  session.canAddInput(input) else { // Проверяем, можно ли добавить этот input в сессию.
                session.commitConfiguration() // Завершаем конфигурацию даже при ошибке.
                return // Выходим: камера недоступна или input не удалось добавить.
            }
            captureDevice = device // Сохраняем камеру, чтобы потом включать и выключать фонарик.
            session.addInput(input) // Добавляем камеру как источник данных для сессии.

            let metadataOutput = AVCaptureMetadataOutput() // Создаём output, который умеет распознавать штрихкоды/QR.
            guard session.canAddOutput(metadataOutput) else { // Проверяем, можно ли добавить output в сессию.
                session.commitConfiguration() // Завершаем конфигурацию даже при ошибке.
                return // Выходим, если metadata output добавить нельзя.
            }

            session.addOutput(metadataOutput) // Добавляем output распознавания в сессию.
            self.metadataOutput = metadataOutput // Сохраняем output, чтобы позже обновлять rectOfInterest под размер preview.
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main) // Говорим output отправлять найденные коды в этот coordinator на main queue.
            metadataOutput.metadataObjectTypes = supportedMetadataObjectTypes(for: metadataOutput) // Включаем только складские штрихкоды и QR.

            if let pendingRectOfInterest { // Если область скана посчиталась раньше, чем output создался, применяем её сейчас.
                metadataOutput.rectOfInterest = pendingRectOfInterest
            }

            session.commitConfiguration() // Завершаем настройку сессии.
        }

        private func preferredVideoDevice() -> AVCaptureDevice? { // Выбирает физическую камеру для сканера.
            AVCaptureDevice.default(
                .builtInUltraWideCamera,
                for: .video,
                position: .back
            ) ?? AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ) ?? AVCaptureDevice.default(for: .video) // Сначала пробуем 0.5, потом обычную заднюю, потом любой video device.
        }

        private func supportedMetadataObjectTypes(
            for output: AVCaptureMetadataOutput
        ) -> [AVMetadataObject.ObjectType] { // Ограничивает распознавание нужными типами кодов.
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

            let supportedTypes = preferredTypes.filter { // Оставляем только те типы, которые реально поддерживает устройство/output.
                output.availableMetadataObjectTypes.contains($0)
            }

            return supportedTypes.isEmpty
                ? output.availableMetadataObjectTypes // Если фильтр внезапно пустой, лучше сканировать всё, чем сломать камеру.
                : supportedTypes // Обычно сюда попадут EAN/Code/QR/DataMatrix/PDF417.
        }

        func setScanAreaSize(_ size: CGSize?, for previewView: PreviewView) { // Переводит видимую SwiftUI-область в rectOfInterest AVFoundation.
            let visibleBounds = previewView.bounds // Это прямоугольник, который пользователь реально видит на экране.
            guard visibleBounds.width > 0, visibleBounds.height > 0 else { return } // До layout размер может быть нулевым.

            let scanRect: CGRect
            if let size { // Если передали конкретный размер, делаем центральную область внутри preview.
                let width = min(size.width, visibleBounds.width) // Не даём области скана выйти шире видимой камеры.
                let height = min(size.height, visibleBounds.height) // Не даём области скана выйти выше видимой камеры.
                scanRect = CGRect(
                    x: visibleBounds.midX - width / 2,
                    y: visibleBounds.midY - height / 2,
                    width: width,
                    height: height
                )
            } else {
                scanRect = visibleBounds // nil значит: сканируем всё, что видно внутри ScannerPreviewView.
            }

            let rectOfInterest = previewView.previewLayer
                .metadataOutputRectConverted(fromLayerRect: scanRect) // Конвертируем координаты layer в формат AVFoundation.

            sessionQueue.async { [weak self] in // rectOfInterest меняем в той же очереди, где живёт session.
                guard let self else { return }
                pendingRectOfInterest = rectOfInterest // Запоминаем область на случай, если output ещё не создан.
                metadataOutput?.rectOfInterest = rectOfInterest // Говорим scanner распознавать коды только в этой зоне.
            }
        }

        private func setTorchEnabled(_ isEnabled: Bool) { // Управляет фонариком камеры.
            sessionQueue.async { [weak self] in // Работаем с камерой в той же очереди, где настраивается AVCaptureSession.
                guard let device = self?.captureDevice, device.hasTorch else { return } // Проверяем, что камера существует и фонарик поддерживается.
                guard device.torchMode != (isEnabled ? .on : .off) else { return } // Если фонарик уже в нужном состоянии, ничего не делаем.

                do { // Пытаемся безопасно изменить настройки камеры.
                    try device.lockForConfiguration() // Блокируем конфигурацию камеры перед изменением torchMode.
                    defer { // Гарантируем выполнение кода ниже при любом выходе из do-блока.
                        device.unlockForConfiguration() // Всегда разблокируем конфигурацию камеры после попытки изменения.
                    }

                    device.torchMode = isEnabled ? .on : .off // Включаем фонарик при удержании и выключаем после отпускания.
                } catch { // Если доступ к конфигурации не получили, просто логируем ошибку.
                    print("Failed to change torch mode:", error) // Сообщение для отладки, чтобы понять, почему фонарик не включился.
                }
            }
        }

        func metadataOutput( // Delegate-метод, который вызывается, когда AVFoundation нашёл metadata object.
            _ output: AVCaptureMetadataOutput, // Output, который прислал событие.
            didOutput metadataObjects: [AVMetadataObject], // Массив найденных объектов: штрихкоды, QR и т.д.
            from connection: AVCaptureConnection // Соединение, через которое пришли данные.
        ) { // Начало обработки найденных metadata objects.
            guard isScanningEnabled, !didScanDuringCurrentPress else { return } // Игнорируем сканы, если кнопка не зажата или скан уже был принят в этом удержании.
            guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, // Берём первый найденный машинно-читаемый код.
                  let scannedCode = metadataObject.stringValue else { return } // Достаём строковое значение кода.

            didScanDuringCurrentPress = true // Помечаем, что в текущем удержании уже был принят скан.
            onScan(scannedCode) // Отдаём считанный код наружу в SwiftUI-экран.
        }
    }
}
