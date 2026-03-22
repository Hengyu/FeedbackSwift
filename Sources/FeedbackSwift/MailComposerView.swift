//
//  MailComposerView.swift
//  FeedbackSwift
//

#if canImport(MessageUI)
import MessageUI
import SwiftUI

struct MailComposerView: UIViewControllerRepresentable {
    let feedback: Feedback
    let onFinish: @MainActor (MFMailComposeResult, Error?) -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients(feedback.to)
        controller.setCcRecipients(feedback.cc)
        controller.setBccRecipients(feedback.bcc)
        controller.setSubject(feedback.subject)
        controller.setMessageBody(feedback.body, isHTML: feedback.isHTML)
        if let jpeg = feedback.jpeg {
            controller.addAttachmentData(jpeg, mimeType: "image/jpeg", fileName: "screenshot.jpg")
        } else if let mp4 = feedback.mp4 {
            controller.addAttachmentData(mp4, mimeType: "video/mp4", fileName: "screenshot.mp4")
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    @MainActor
    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onFinish: @MainActor (MFMailComposeResult, Error?) -> Void

        init(onFinish: @escaping @MainActor (MFMailComposeResult, Error?) -> Void) {
            self.onFinish = onFinish
        }

        nonisolated func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            let onFinish = self.onFinish
            MainActor.assumeIsolated {
                onFinish(result, error)
                controller.dismiss(animated: true)
            }
        }
    }
}
#endif
