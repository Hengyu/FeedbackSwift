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
import UIKit

open class FeedbackViewController: UITableViewController {
    public var mailComposeDelegate: MFMailComposeViewControllerDelegate?
    public var replacedFeedbackSendingAction: ((Feedback) -> Void)?
    public var feedbackDidFailed: ((MFMailComposeResult, NSError) -> Void)?
    public var configuration: FeedbackConfiguration {
        didSet { updateDataSource(configuration: configuration) }
    }

    internal var wireframe: FeedbackWireframeProtocol!

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

        wireframe = FeedbackWireframe(
            viewController: self,
            imagePickerDelegate: self,
            mailComposerDelegate: self
        )
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        #if os(iOS)
        tableView.keyboardDismissMode = .onDrag
        #endif
        tableView.cellLayoutMarginsFollowReadableWidth = true

        cellFactories.forEach(tableView.register(with:))
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
                cellRect: cell.superview!.convert(cell.frame, to: view),
                authorizePhotoLibrary: { completion in
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                        DispatchQueue.main.async {
                            completion(status == .authorized)
                        }
                    }
                },
                authorizeCamera: { completion in
                    AVCaptureDevice.requestAccess(for: .video) { result in
                        DispatchQueue.main.async {
                            completion(result)
                        }
                    }
                },
                deleteAction: attachmentDeleteAction
            )
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
    func topicCellOptionChanged(_ option: TopicProtocol) {
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
        do {
            let feedback = try feedbackEditingService.generateFeedback(configuration: configuration)
            (replacedFeedbackSendingAction ?? wireframe.showMailComposer(with:))(feedback)
        } catch {
            wireframe.showFeedbackGenerationError()
        }
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
                wireframe.showUnknownErrorAlert()
            }
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        wireframe.dismiss(completion: .none)
    }
}

extension FeedbackViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        if result == .failed, let error = error as NSError? {
            wireframe.showMailComposingError(error)
        }

        wireframe.dismiss(
            completion: result == .cancelled ? .none : { self.terminate(result, error) }
        )

        mailComposeDelegate?.mailComposeController?(controller, didFinishWith: result, error: error)
    }
}
