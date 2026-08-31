import SwiftUI
import UIKit

struct CameraShot {
    let data: Data
    let thumbnail: Image
}

struct CameraPickerView: UIViewControllerRepresentable {
    var onFinish: (CameraShot?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
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

    final class Coordinator: NSObject, UIImagePickerControllerDelegate,
        UINavigationControllerDelegate
    {
        var onFinish: (CameraShot?) -> Void = { _ in }

        // 96 = квадрат 32pt в строке списка на экране ×3
        private let thumbnailSize = CGSize(width: 96, height: 96)
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
                let data = image.jpegData(compressionQuality: 0.6)
            else {
                return nil
            }
            let thumbnail = image.preparingThumbnail(of: thumbnailSize) ?? image
            return CameraShot(data: data, thumbnail: Image(uiImage: thumbnail))
        }
    }
}
