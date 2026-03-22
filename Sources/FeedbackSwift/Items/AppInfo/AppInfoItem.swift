//
// Created by 和泉田 領一 on 2017/09/24.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

struct AppNameItem {
    static var name: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}

struct AppVersionItem {
    static var version: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

struct AppBuildItem {
    static var build: String? {
        Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
}
