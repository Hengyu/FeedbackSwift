//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation
import Dispatch

var storedFeedbackBundle: Bundle?

extension Bundle {
    static var feedbackBundle: Bundle {
        if let bundle = storedFeedbackBundle { return bundle }

        let bundle = Bundle(for: FeedbackViewController.self)
        storedFeedbackBundle = bundle
        return bundle
    }

    static var platformNamesPlistPath: String? {
        #if SWIFT_PACKAGE && swift(>=5.3)
        let bundles: [Bundle] = [Bundle.main, Bundle.feedbackBundle, Bundle.module]
        #else
        let bundles: [Bundle] = [Bundle.main, Bundle.feedbackBundle]
        #endif

        for bundle in bundles {
            guard let path = bundle.path(forResource: "PlatformNames", ofType: "plist")
            else { continue }
            return path
        }
        if let path = Bundle.main.path(forResource: "PlatformNames", ofType: "plist") {
            return path
        }
        return nil
    }
}
