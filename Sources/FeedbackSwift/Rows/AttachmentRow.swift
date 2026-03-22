//
//  AttachmentRow.swift
//  FeedbackSwift
//

#if !os(tvOS)

#if canImport(UIKit)
import Photos
#endif
import PhotosUI
import SwiftUI

struct AttachmentRow: View {
    @Bindable var viewModel: FeedbackViewModel

    var body: some View {
        Button {
            viewModel.showingAttachmentOptions = true
        } label: {
            HStack {
                if let media = viewModel.attachmentMedia {
                    attachmentImage(for: media)
                } else {
                    Text(localized("feedback.AttachImageOrVideo"))
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .confirmationDialog(
            localized("feedback.AttachImageOrVideo"),
            isPresented: $viewModel.showingAttachmentOptions
        ) {
            Button(localized("feedback.PhotoLibrary")) {
                requestPhotoLibraryAccess()
            }
            #if os(iOS)
            if viewModel.preference.enablesCameraPicker {
                Button(localized("feedback.Camera")) {
                    authorizeCamera()
                }
            }
            #endif
            if viewModel.hasAttachedMedia {
                Button(localized("feedback.Delete"), role: .destructive) {
                    viewModel.deleteAttachment()
                }
            }
        }
        .photosPicker(
            isPresented: $viewModel.showingPhotoPicker,
            selection: $viewModel.photosPickerItem,
            matching: .images
        )
        #if os(iOS)
        .fullScreenCover(isPresented: $viewModel.showingCameraPicker) {
            CameraPickerView { media in
                viewModel.attachmentMedia = media
            }
            .ignoresSafeArea()
        }
        #endif
    }

    @ViewBuilder
    private func attachmentImage(for media: Media) -> some View {
        let image: PlatformImage = switch media {
        case .image(let img): img
        case .video(let thumb, _): thumb
        }
        Image(platformImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxHeight: 65)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func requestPhotoLibraryAccess() {
        #if canImport(UIKit) && !os(visionOS)
        // On iOS/macCatalyst, request photo library authorization before showing picker
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            Task {
                let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                if newStatus == .authorized || newStatus == .limited {
                    viewModel.showingPhotoPicker = true
                } else {
                    viewModel.showPermissionAlert(for: localized("feedback.requiredLibraryAccess"))
                }
            }
        case .authorized, .limited:
            viewModel.showingPhotoPicker = true
        case .restricted, .denied:
            viewModel.showPermissionAlert(for: localized("feedback.requiredLibraryAccess"))
        @unknown default:
            viewModel.showPermissionAlert(for: localized("feedback.requiredLibraryAccess"))
        }
        #else
        // On macOS and visionOS, PhotosPicker is out-of-process and handles permissions itself
        viewModel.showingPhotoPicker = true
        #endif
    }

    #if os(iOS)
    private func authorizeCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                if granted {
                    viewModel.showingCameraPicker = true
                } else {
                    viewModel.showPermissionAlert(for: localized("feedback.requiredCameraAccess"))
                }
            }
        case .authorized:
            viewModel.showingCameraPicker = true
        case .restricted, .denied:
            viewModel.showPermissionAlert(for: localized("feedback.requiredCameraAccess"))
        @unknown default:
            viewModel.showPermissionAlert(for: localized("feedback.requiredCameraAccess"))
        }
    }
    #endif
}

#endif
