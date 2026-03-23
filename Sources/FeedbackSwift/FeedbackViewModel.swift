//
//  FeedbackViewModel.swift
//  FeedbackSwift
//

#if canImport(AppKit)
import AppKit
#endif
#if !os(tvOS)
import PhotosUI
#endif
import SwiftUI

@MainActor @Observable
final class FeedbackViewModel {
    var selectedTopic: (any TopicProtocol)?
    var bodyText: String = ""
    var attachmentMedia: Media?

    #if canImport(AppKit)
    var sharingServiceDelegate: SharingServiceDelegate?
    #endif

    // Presentation state
    var showingAttachmentOptions = false
    var showingMailComposer = false
    var showingPhotoPicker = false
    var showingCameraPicker = false
    var showingPermissionAlert = false
    var permissionAlertMessage: String = ""
    var showingError = false
    var errorMessage: String = ""

    #if !os(tvOS)
    var photosPickerItem: PhotosPickerItem? {
        didSet { handlePhotosPickerSelection() }
    }
    #endif

    let topics: [any TopicProtocol]
    let preference: FeedbackUnitPreference

    var hasAttachedMedia: Bool { attachmentMedia != nil }

    var deviceName: String { DeviceNameItem.name ?? "" }
    var systemVersion: String { SystemVersionItem.version }
    var appName: String { AppNameItem.name ?? "" }
    var appVersion: String { AppVersionItem.version ?? "" }
    var appBuild: String { AppBuildItem.build ?? "" }

    init(topics: [any TopicProtocol], preference: FeedbackUnitPreference) {
        self.topics = topics
        self.preference = preference
        if let first = topics.first {
            self.selectedTopic = first
        }
    }

    func generateFeedback(configuration: FeedbackConfiguration) -> Feedback {
        FeedbackGenerator.generate(
            configuration: configuration,
            topic: selectedTopic,
            body: bodyText,
            media: attachmentMedia,
            deviceName: deviceName,
            systemVersion: systemVersion,
            appName: appName,
            appVersion: appVersion,
            appBuild: appBuild
        )
    }

    func deleteAttachment() {
        attachmentMedia = nil
    }

    #if !os(tvOS)
    func handlePhotosPickerSelection() {
        guard let item = photosPickerItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = PlatformImage(data: data) {
                attachmentMedia = .image(image)
            }
            photosPickerItem = nil
        }
    }
    #endif

    func showMailConfigError() {
        errorMessage = localized("feedback.MailConfigurationErrorMessage")
        showingError = true
    }

    func showPermissionAlert(for message: String) {
        permissionAlertMessage = message
        showingPermissionAlert = true
    }
}

#if canImport(AppKit)
@MainActor
final class SharingServiceDelegate: NSObject, NSSharingServiceDelegate {
    let onFailure: (@MainActor (NSError) -> Void)?

    init(onFailure: (@MainActor (NSError) -> Void)?) {
        self.onFailure = onFailure
    }

    nonisolated func sharingService(
        _ sharingService: NSSharingService,
        didFailToShareItems items: [Any],
        error: Error
    ) {
        let onFailure = self.onFailure
        MainActor.assumeIsolated {
            onFailure?(error as NSError)
        }
    }
}
#endif
