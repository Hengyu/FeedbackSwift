//
//  CameraPickerView.swift
//  FeedbackSwift
//

#if os(iOS)
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct CameraPickerView: UIViewControllerRepresentable {
    let onMediaPicked: (Media) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onMediaPicked: onMediaPicked, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onMediaPicked: (Media) -> Void
        let dismiss: DismissAction

        init(onMediaPicked: @escaping (Media) -> Void, dismiss: DismissAction) {
            self.onMediaPicked = onMediaPicked
            self.dismiss = dismiss
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let imageType = UTType.image.identifier
            let movieType = UTType.movie.identifier

            switch info[.mediaType] as? String {
            case imageType:
                if let image = info[.originalImage] as? UIImage {
                    onMediaPicked(.image(image))
                }
            case movieType:
                if let url = info[.mediaURL] as? URL {
                    Task {
                        if let media = try? await getMediaFromURL(url) {
                            await MainActor.run {
                                onMediaPicked(media)
                            }
                        }
                    }
                }
            default:
                break
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
#endif
