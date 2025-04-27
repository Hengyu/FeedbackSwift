//
//  FeedbackViewController.swift
//  CTFeedbackSwift
//
//  Created by 和泉田 領一 on 2017/09/07.
//  Copyright © 2017 CAPH TECH. All rights reserved.
//

import Dispatch
import MessageUI
import Photos
import PhotosUI
import UIKit

public final class FeedbackViewController: UITableViewController {
    public var mailComposeDelegate: MFMailComposeViewControllerDelegate?
    public var replacedFeedbackSendingAction: ((Feedback) -> Void)?
    public var feedbackDidFailed: ((MFMailComposeResult, NSError) -> Void)?
    public var configuration: FeedbackConfiguration {
        didSet { updateDataSource(configuration: configuration) }
    }

    internal lazy var wireframe: FeedbackWireframeProtocol = FeedbackWireframe(
        viewController: self,
        imagePickerDelegate: self,
        mailComposerDelegate: self,
        enablesCameraPicker: configuration.preference.enablesCameraPicker
    )

    private let cellFactories = [
        AnyCellFactory(UserEmailCell.self),
        AnyCellFactory(TopicCell.self),
        AnyCellFactory(BodyCell.self),
        AnyCellFactory(AttachmentCell.self),
        AnyCellFactory(DeviceNameCell.self),
        AnyCellFactory(SystemVersionCell.self),
        AnyCellFactory(AppNameCell.self),
        AnyCellFactory(AppVersionCell.self),
        AnyCellFactory(AppBuildCell.self),
    ]

    private lazy var feedbackEditingService: FeedbackEditingServiceProtocol = {
        FeedbackEditingService(
            editingItemsRepository: configuration.dataSource,
            feedbackEditingEventHandler: self
        )
    }()

    private var popNavigationBarHiddenState: (((Bool) -> Void) -> Void)?
    private var attachmentDeleteAction: (() -> Void)? {
        feedbackEditingService.hasAttachedMedia ? { self.feedbackEditingService.update(attachmentMedia: .none) } : .none
    }

    public init(configuration: FeedbackConfiguration) {
        self.configuration = configuration
        super.init(style: .insetGrouped)
    }

    public required init?(coder: NSCoder) {
        configuration = .init(toRecipients: [], preference: .default)
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        #if os(iOS)
        tableView.keyboardDismissMode = .onDrag
        #endif
        tableView.cellLayoutMarginsFollowReadableWidth = true

        cellFactories.forEach { factory in
            tableView.register(with: factory)
        }
        updateDataSource(configuration: configuration)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        popNavigationBarHiddenState = push(navigationController?.isNavigationBarHidden)
        navigationController?.isNavigationBarHidden = false

        configureLeftBarButtonItem()
        configureNavigationBar()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        popNavigationBarHiddenState?({ self.navigationController?.isNavigationBarHidden = $0 })
    }
}

extension FeedbackViewController {
    // MARK: - UITableViewDataSource

    override public func numberOfSections(in tableView: UITableView) -> Int {
        configuration.dataSource.numberOfSections
    }

    override public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        configuration.dataSource.section(at: section).count
    }

    override public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let item = configuration.dataSource.section(at: indexPath.section)[indexPath.row]
        return tableView.dequeueCell(
            to: item,
            from: cellFactories,
            for: indexPath,
            eventHandler: self
        )
    }

    override public func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        configuration.dataSource.section(at: section).title
    }
}

extension FeedbackViewController {
    // MARK: - UITableViewDelegate

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = configuration.dataSource.section(at: indexPath.section)[indexPath.row]
        switch item {
        case _ as AttachmentItem:
            guard let cell = tableView.cellForRow(at: indexPath) else {
                fatalError("Can't get cell")
            }
            wireframe.showAttachmentActionSheet(
                authorizePhotoLibrary: authorizePhotoLibrary(handler:),
                authorizeCamera: authorizeCamera(handler:),
                deleteAction: attachmentDeleteAction
            )
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func authorizePhotoLibrary(handler: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            Task {
                let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                handler(status == .authorized || status == .limited)
            }
        case .authorized, .limited:
            handler(true)
        case .restricted, .denied:
            handler(false)
        @unknown default:
            handler(false)
        }
    }

    private func authorizeCamera(handler: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { result in
                DispatchQueue.main.async {
                    handler(result)
                }
            }
        case .authorized:
            handler(true)
        case .restricted:
            handler(false)
        case .denied:
            handler(false)
        @unknown default:
            handler(false)
        }
    }
}

extension FeedbackViewController: FeedbackEditingEventProtocol {
    public func updated(at indexPath: IndexPath) {
        if #available(iOS 15.0, macCatalyst 15.0, *) {
            tableView.reconfigureRows(at: [indexPath])
        } else {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension FeedbackViewController: UserEmailCellEventProtocol {
    func userEmailTextDidChange(_ text: String?) {
        feedbackEditingService.update(userEmailText: text)
    }
}

extension FeedbackViewController: BodyCellEventProtocol {
    func bodyCellHeightChanged() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func bodyTextDidChange(_ text: String?) {
        feedbackEditingService.update(bodyText: text)
    }
}

extension FeedbackViewController: TopicCellProtocol {
    func topicCellOptionChanged(_ option: any TopicProtocol) {
        feedbackEditingService.update(selectedTopic: option)
    }
}

extension FeedbackViewController: AttachmentCellEventProtocol {
    func showImage(of item: AttachmentItem) {
        // Pending
    }
}

extension FeedbackViewController {
    private func configureNavigationBar() {
        if parent == navigationController?.topViewController {
            // the view is wrapped in the SwiftUI's container
            // https://stackoverflow.com/a/59317657/4402255
            parent?.title = localized("feedback.Feedback")
            parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: .init(systemName: "arrow.up.circle.fill"),
                style: .plain,
                target: self,
                action: #selector(mailButtonTapped(_:))
            )
        } else {
            title = localized("feedback.Feedback")
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: .init(systemName: "arrow.up.circle.fill"),
                style: .plain,
                target: self,
                action: #selector(mailButtonTapped(_:))
            )
        }
    }

    private func configureLeftBarButtonItem() {
        if let navigationController {
            if navigationController.viewControllers[0] === self {
                navigationItem.leftBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: .cancel,
                    target: self,
                    action: #selector(cancelButtonTapped(_:))
                )
            } else {
                // Keep the standard back button instead of "Cancel"
                navigationItem.leftBarButtonItem = .none
            }
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(cancelButtonTapped(_:))
            )
        }
    }

    private func updateDataSource(configuration: FeedbackConfiguration) {
        tableView.reloadData()
    }

    @objc
    func cancelButtonTapped(_ sender: Any) {
        if let navigationController {
            if navigationController.viewControllers.first === self {
                wireframe.dismiss(completion: .none)
            } else {
                wireframe.pop()
            }
        } else {
            wireframe.dismiss(completion: .none)
        }
    }

    @objc
    func mailButtonTapped(_ sender: Any) {
        let feedback = feedbackEditingService.generateFeedback(configuration: configuration)
        (replacedFeedbackSendingAction ?? wireframe.showMailComposer(with:))(feedback)
    }

    private func terminate(_ result: MFMailComposeResult, _ error: Error?) {
        if presentingViewController?.presentedViewController != .none {
            wireframe.dismiss(completion: .none)
        } else {
            navigationController?.popViewController(animated: true)
        }

        if result == .failed, let error = error as NSError? {
            feedbackDidFailed?(result, error)
        }
    }
}

extension FeedbackViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        Task {
            switch await getMediaFromImagePickerInfo(info) {
            case let media?:
                feedbackEditingService.update(attachmentMedia: media)
                wireframe.dismiss(completion: .none)
            case _:
                wireframe.dismiss(completion: .none)
                wireframe.showError(nil)
            }
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        wireframe.dismiss(completion: nil)
    }
}

extension FeedbackViewController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        guard let itemProvider = results.first?.itemProvider else { return }

        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                let uiImage = image as? UIImage
                DispatchQueue.main.async {
                    guard let self else { return }
                    if let uiImage {
                        self.feedbackEditingService.update(attachmentMedia: .image(uiImage))
                    } else if error != nil {
                        self.wireframe.showError(nil)
                    }
                }
            }
        }
    }
}

extension FeedbackViewController: @preconcurrency MFMailComposeViewControllerDelegate {
    public func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        if result == .failed, let error {
            wireframe.showError(error)
        }

        wireframe.dismiss(
            completion: result == .cancelled ? .none : { self.terminate(result, error) }
        )

        mailComposeDelegate?.mailComposeController?(controller, didFinishWith: result, error: error)
    }
}
