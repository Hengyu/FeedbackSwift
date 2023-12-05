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

func getMediaFromImagePickerInfo(_ info: [UIImagePickerController.InfoKey: Any]) -> Media? {
    let imageType: String
    let movieType: String
    if #available(iOS 14.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *) {
        imageType = UTType.image.identifier
        movieType = UTType.movie.identifier
    } else {
        imageType = kUTTypeImage as String
        movieType = kUTTypeMovie as String
    }

    switch info[.mediaType] as? String {
    case imageType?:
        guard let image = info[.originalImage] as? UIImage else { return nil }
        return .image(image)
    case movieType?:
        guard let url = info[.mediaURL] as? URL else { return nil }
        return getMediaFromURL(url)
    default: return nil
    }
}

func getMediaFromURL(_ url: URL) -> Media? {
    let asset = AVURLAsset(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let time = CMTimeMake(value: 1, timescale: 1)
    guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil)
    else { return nil }
    return .video(UIImage(cgImage: cgImage), url)
}

func push<Item>(_ item: Item?) -> (((Item) -> Void) -> Void)? {
    guard let item else { return nil }
    return { closure in closure(item) }
}
