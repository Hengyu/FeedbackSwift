//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import AVFoundation
import MobileCoreServices
import UIKit
import UniformTypeIdentifiers

func localized(_ key: String) -> String {
    #if SWIFT_PACKAGE
    let bundles: [Bundle] = [Bundle.main, Bundle.feedbackBundle, Bundle.module]
    #else
    let bundles: [Bundle] = [Bundle.main, Bundle.feedbackBundle]
    #endif

    for bundle in bundles {
        let string = NSLocalizedString(
            key,
            tableName: "FeedbackLocalizable",
            bundle: bundle,
            comment: ""
        )
        if key != string { return string }
    }
    return key
}

func getMediaFromImagePickerInfo(_ info: [UIImagePickerController.InfoKey: Any]) async -> Media? {
    let imageType = UTType.image.identifier
    let movieType = UTType.movie.identifier

    switch info[.mediaType] as? String {
    case imageType?:
        guard let image = info[.originalImage] as? UIImage else { return nil }
        return .image(image)
    case movieType?:
        guard let url = info[.mediaURL] as? URL else { return nil }
        let image = try? await getMediaFromURL(url)
        return image
    default: return nil
    }
}

func getMediaFromURL(_ url: URL) async throws -> Media {
    let asset = AVURLAsset(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let time = CMTimeMake(value: 1, timescale: 1)
    #if os(visionOS)
    let image = try await generator.image(at: time)
    return Media.video(.init(cgImage: image.image), url)
    #else
    if #available(iOS 16.0, macCatalyst 16.0, *) {
        let image = try await generator.image(at: time)
        return Media.video(.init(cgImage: image.image), url)
    } else {
        let image = try generator.copyCGImage(at: time, actualTime: nil)
        return .video(UIImage(cgImage: image), url)
    }
    #endif
}

func push<Item>(_ item: Item?) -> (((Item) -> Void) -> Void)? {
    guard let item else { return nil }
    return { closure in closure(item) }
}
