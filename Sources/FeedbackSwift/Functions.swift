//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import AVFoundation
import Foundation

func localized(_ key: String) -> String {
    #if SWIFT_PACKAGE
    let bundles: [Bundle] = [Bundle.main, Bundle.feedbackBundle, Bundle.module]
    #else
    let bundles: [Bundle] = [Bundle.main, Bundle.feedbackBundle]
    #endif

    for bundle in bundles {
        let string = NSLocalizedString(
            key,
            tableName: "localizable",
            bundle: bundle,
            comment: ""
        )
        if key != string { return string }
    }
    return key
}

func getMediaFromURL(_ url: URL) async throws -> Media {
    let asset = AVURLAsset(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let time = CMTimeMake(value: 1, timescale: 1)
    let image = try await generator.image(at: time)
    return Media.video(PlatformImage(cgImage: image.image), url)
}
