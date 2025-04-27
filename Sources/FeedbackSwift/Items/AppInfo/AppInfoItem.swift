//
// Created by 和泉田 領一 on 2017/09/24.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

struct AppNameItem: FeedbackUnit {
    let display: Bool

    var name: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }

    init(display: Bool) {
        self.display = display
    }
}

struct AppVersionItem: FeedbackUnit {
    let display: Bool

    var version: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    init(display: Bool) {
        self.display = display
    }
}

struct AppBuildItem: FeedbackUnit {
    let display: Bool

    var build: String? {
        Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }

    init(display: Bool) {
        self.display = display
    }
}
