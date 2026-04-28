import AVFoundation // Подключает AVFoundation: камеру, AVCaptureSession, metadata scanner и preview layer.
import SwiftUI // Подключает SwiftUI, чтобы использовать ScannerPreviewView как обычную SwiftUI-вью.

struct ScannerPreviewView: UIViewRepresentable { // SwiftUI-обёртка для UIKit-view с камерой.
    let isScanningEnabled: Bool // Флаг: сейчас сканы нужно принимать или игнорировать.
    let onScan: (String) -> Void // Callback, который вызывается, когда камера считала код.

    func makeUIView(context: Context) -> PreviewView { // Создаёт UIKit-view один раз при появлении SwiftUI-вью.
        let view = PreviewView() // Создаём view, внутри которой будет жить preview камеры.
        context.coordinator.configureSession(for: view) // Просим coordinator настроить камеру и привязать её к этой view.
        return view // Возвращаем UIKit-view в SwiftUI.
    }

    func updateUIView(_ uiView: PreviewView, context: Context) { // Вызывается SwiftUI при изменении входных данных view.
        context.coordinator.setScanningEnabled(isScanningEnabled) // Передаём coordinator актуальное состояние: сканировать или нет.
        context.coordinator.onScan = onScan // Обновляем callback на случай, если SwiftUI пересоздал замыкание.
    }

    func makeCoordinator() -> Coordinator { // Создаёт объект-посредник между SwiftUI и AVCaptureMetadataOutputDelegate.
        Coordinator(isScanningEnabled: isScanningEnabled, onScan: onScan) // Передаём стартовое состояние и callback в coordinator.
    }
}

final class PreviewView: UIView { // UIKit-view, которая умеет показывать camera preview.
    override class var layerClass: AnyClass { // Говорим UIKit, какой CALayer использовать как основной слой этой view.
        AVCaptureVideoPreviewLayer.self // Вместо обычного слоя используем слой, который показывает поток с камеры.
    }

    var previewLayer: AVCaptureVideoPreviewLayer { // Удобное свойство для доступа к layer как к AVCaptureVideoPreviewLayer.
        layer as! AVCaptureVideoPreviewLayer // Приводим базовый layer к нужному типу; безопасно, потому что layerClass задан выше.
    }
}

extension ScannerPreviewView { // Расширение, чтобы держать Coordinator рядом с ScannerPreviewView.
    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate { // Coordinator получает события распознавания штрихкодов от AVFoundation.
        var isScanningEnabled: Bool // Хранит текущее состояние: принимать сканы или игнорировать.
        var onScan: (String) -> Void // Хранит callback, который отдаёт считанный код наружу.

        private let session = AVCaptureSession() // Сессия камеры: объединяет input камеры и output распознавания.
        private let sessionQueue = DispatchQueue(label: "scanner.session.queue") // Очередь для настройки и запуска камеры не на main thread.
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

            sessionQueue.async { [weak self] in // Настраиваем и запускаем сессию в отдельной очереди.
                self?.configureSessionIfNeeded() // Настраиваем input/output, если это ещё не сделано.
                self?.session.startRunning() // Запускаем поток камеры.
            }
        }

        private func configureSessionIfNeeded() { // Настраивает AVCaptureSession один раз.
            guard session.inputs.isEmpty, session.outputs.isEmpty else { return } // Если input/output уже добавлены, повторно ничего не делаем.

            session.beginConfiguration() // Начинаем пакетную настройку сессии.
            session.sessionPreset = .high // Ставим высокое качество захвата, чтобы штрихкоды читались лучше.

            guard let device = AVCaptureDevice.default(for: .video), // Берём стандартную видеокамеру устройства.
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
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main) // Говорим output отправлять найденные коды в этот coordinator на main queue.
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes // Включаем все доступные типы кодов для распознавания.

            session.commitConfiguration() // Завершаем настройку сессии.
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
