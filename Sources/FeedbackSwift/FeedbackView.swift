//
//  FeedbackView.swift
//  FeedbackSwift
//

#if canImport(MessageUI)
import MessageUI
#endif
import SwiftUI

public struct FeedbackView: View {
    @State private var viewModel: FeedbackViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let configuration: FeedbackConfiguration
    private var replacedFeedbackSendingAction: ((Feedback) -> Void)?
    private var feedbackSendingFailedAction: (@MainActor (NSError) -> Void)?

    public init(configuration: FeedbackConfiguration) {
        self.configuration = configuration
        self._viewModel = State(
            wrappedValue: FeedbackViewModel(
                topics: configuration.topics,
                preference: configuration.preference
            )
        )
    }

    public var body: some View {
        Form {
            if configuration.preference.enablesUserEmail {
                Section(localized("feedback.UserDetail")) {
                    UserEmailRow(viewModel: viewModel)
                }
            }

            Section {
                TopicRow(viewModel: viewModel)
                BodyRow(viewModel: viewModel)
            }

            #if !os(tvOS)
            if configuration.preference.enablesAttachment {
                Section(localized("feedback.AdditionalInfo")) {
                    AttachmentRow(viewModel: viewModel)
                }
            }
            #endif

            Section(localized("feedback.DeviceInfo")) {
                LabeledContent(localized("feedback.Device"), value: viewModel.deviceName)
                LabeledContent(platformLabel, value: viewModel.systemVersion)
            }

            if configuration.preference.showsAppInfo {
                Section(localized("feedback.AppInfo")) {
                    LabeledContent(localized("feedback.Name"), value: viewModel.appName)
                    LabeledContent(localized("feedback.Version"), value: viewModel.appVersion)
                    LabeledContent(localized("feedback.Build"), value: viewModel.appBuild)
                }
            }
        }
        .navigationTitle(localized("feedback.Feedback"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(localized("feedback.Cancel")) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    sendFeedback()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                }
            }
        }
        #if canImport(MessageUI)
        .sheet(isPresented: $viewModel.showingMailComposer) {
            let feedback = viewModel.generateFeedback(configuration: configuration)
            MailComposerView(feedback: feedback) { result, error in
                viewModel.showingMailComposer = false
                if result == .failed, let error = error as NSError? {
                    feedbackSendingFailedAction?(error)
                }
                if result != .cancelled {
                    dismiss()
                }
            }
            .ignoresSafeArea()
        }
        #endif
        .alert(
            localized("feedback.Error"),
            isPresented: $viewModel.showingError
        ) {
            Button(localized("feedback.Dismiss"), role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert(
            "",
            isPresented: $viewModel.showingPermissionAlert
        ) {
            Button(localized("feedback.Ok")) {
                openSettings()
            }
        } message: {
            Text(viewModel.permissionAlertMessage)
        }
    }

    private var platformLabel: String {
        #if targetEnvironment(macCatalyst) || os(macOS)
        "macOS"
        #elseif os(visionOS)
        "visionOS"
        #elseif os(tvOS)
        "tvOS"
        #else
        "iOS"
        #endif
    }

    private func sendFeedback() {
        let feedback = viewModel.generateFeedback(configuration: configuration)
        if let replacedFeedbackSendingAction {
            replacedFeedbackSendingAction(feedback)
        } else {
            #if canImport(MessageUI)
            guard MFMailComposeViewController.canSendMail() else {
                viewModel.showMailConfigError()
                return
            }
            viewModel.showingMailComposer = true
            #elseif canImport(AppKit)
            guard let service = NSSharingService(named: .composeEmail) else {
                viewModel.showMailConfigError()
                return
            }
            let delegate = SharingServiceDelegate(onFailure: feedbackSendingFailedAction)
            viewModel.sharingServiceDelegate = delegate
            service.delegate = delegate
            service.recipients = feedback.to
            service.subject = feedback.subject
            var items: [Any] = [feedback.body]
            if let jpeg = feedback.jpeg {
                items.append(jpeg)
            } else if let mp4 = feedback.mp4 {
                items.append(mp4)
            }
            service.perform(withItems: items)
            #else
            viewModel.showMailConfigError()
            #endif
        }
    }

    private func openSettings() {
        #if os(iOS) || os(visionOS) || os(tvOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
            openURL(url)
        }
        #endif
    }
}

// MARK: - Modifiers

extension FeedbackView {
    public func onReplacedFeedbackSending(_ action: @escaping (Feedback) -> Void) -> FeedbackView {
        var view = self
        view.replacedFeedbackSendingAction = action
        return view
    }

    public func onFeedbackFailed(_ action: @escaping @Sendable @MainActor (NSError) -> Void) -> FeedbackView {
        var view = self
        view.feedbackSendingFailedAction = action
        return view
    }
}
