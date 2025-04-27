//
// Created by 和泉田 領一 on 2017/09/25.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import MessageUI
import MobileCoreServices
import PhotosUI
import UIKit
import UniformTypeIdentifiers

@MainActor protocol FeedbackWireframeProtocol {
    func showMailComposer(with feedback: Feedback)
    func showAttachmentActionSheet(
        authorizePhotoLibrary: @escaping (@escaping (Bool) -> Void) -> Void,
        authorizeCamera: @escaping (@escaping (Bool) -> Void) -> Void,
        deleteAction: (() -> Void)?
    )
    func showError(_ error: Error?)
    func dismiss(completion: (() -> Void)?)
    func pop()
}

@MainActor final class FeedbackWireframe {
    private weak var viewController: UIViewController?
    private weak var imagePickerDelegate: (UIImagePickerControllerDelegate
                                           & PHPickerViewControllerDelegate
                                           & UINavigationControllerDelegate)?
    private weak var mailComposerDelegate: MFMailComposeViewControllerDelegate?
    private let enablesCameraPicker: Bool

    init(
        viewController: UIViewController,
        imagePickerDelegate: UIImagePickerControllerDelegate
        & PHPickerViewControllerDelegate
        & UINavigationControllerDelegate,
        mailComposerDelegate: MFMailComposeViewControllerDelegate,
        enablesCameraPicker: Bool
    ) {
        self.viewController = viewController
        self.imagePickerDelegate = imagePickerDelegate
        self.mailComposerDelegate = mailComposerDelegate
        self.enablesCameraPicker = enablesCameraPicker
    }
}

extension FeedbackWireframe: FeedbackWireframeProtocol {

    func showMailComposer(with feedback: Feedback) {
        guard MFMailComposeViewController.canSendMail() else { return showMailConfigurationError() }
        let controller: MFMailComposeViewController = MFMailComposeViewController()
        controller.mailComposeDelegate = mailComposerDelegate
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
        viewController?.present(controller, animated: true)
    }

    func showAttachmentActionSheet(
        authorizePhotoLibrary: @escaping (@escaping (Bool) -> Void) -> Void,
        authorizeCamera: @escaping (@escaping (Bool) -> Void) -> Void,
        deleteAction: (() -> Void)?
    ) {
        let alertController = UIAlertController(
            title: .none,
            message: localized("feedback.AttachImageOrVideo"),
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: localized("feedback.PhotoLibrary"),
                style: .default
            ) { _ in
                authorizePhotoLibrary { granted in
                    if granted {
                        self.showPhotoPicker()
                    } else {
                        self.showPhotoLibraryAuthorizingAlert()
                    }
                }
            }
        )
        #if os(iOS)
        if UIImagePickerController.isSourceTypeAvailable(.camera), enablesCameraPicker {
            alertController.addAction(
                UIAlertAction(title: localized("feedback.Camera"), style: .default) { _ in
                    authorizeCamera { granted in
                        if granted {
                            self.showImagePicker(sourceType: .camera)
                        } else {
                            self.showCameraAuthorizingAlert()
                        }
                    }
                }
            )
        }
        #endif

        if let deleteAction {
            alertController.addAction(
                UIAlertAction(title: localized("feedback.Delete"), style: .destructive) { _ in
                    deleteAction()
                }
            )
        }

        alertController.addAction(UIAlertAction(title: localized("feedback.Cancel"), style: .cancel))

        viewController?.present(alertController, animated: true)
    }

    func showError(_ error: Error?) {
        let alertController = UIAlertController(
            title: error == nil ? localized("feedback.UnknownError") : localized("feedback.Error"),
            message: error?.localizedDescription,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(title: localized("feedback.Dismiss"), style: .cancel)
        )
        viewController?.present(alertController, animated: true)
    }

    func dismiss(completion: (() -> Void)?) {
        viewController?.dismiss(animated: true, completion: completion)
    }

    func pop() { viewController?.navigationController?.popViewController(animated: true) }
}

private extension FeedbackWireframe {
    func showMailConfigurationError() {
        let alert = UIAlertController(
            title: localized("feedback.Error"),
            message:
                localized("feedback.MailConfigurationErrorMessage"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: localized("feedback.Dismiss"), style: .cancel))
        viewController?.present(alert, animated: true)
    }

    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        #if os(macOS) || targetEnvironment(macCatalyst)
        imagePicker.cameraDevice = .front
        #endif
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        imagePicker.allowsEditing = false
        imagePicker.delegate = imagePickerDelegate
        imagePicker.modalPresentationStyle = .formSheet
        viewController?.present(imagePicker, animated: true)
    }

    func showPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = imagePickerDelegate
        viewController?.present(picker, animated: true)
    }

    func showPhotoLibraryAuthorizingAlert() {
        let alert = UIAlertController(
            title: .none,
            message: localized("feedback.requiredLibraryAccess"),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: localized("feedback.Ok"), style: .default) { [unowned self] _ in
                openSettings()
            }
        )
        viewController?.present(alert, animated: true)
    }

    func showCameraAuthorizingAlert() {
        let alert = UIAlertController(
            title: .none,
            message: localized("feedback.requiredCameraAccess"),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: localized("feedback.Ok"), style: .default) { [unowned self] _ in
                openSettings()
            }
        )
        viewController?.present(alert, animated: true)
    }

    private func openSettings() {
        #if os(macOS) || targetEnvironment(macCatalyst)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
            UIApplication.shared.open(url)
        }
        #elseif os(iOS) || os(visionOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }
}
