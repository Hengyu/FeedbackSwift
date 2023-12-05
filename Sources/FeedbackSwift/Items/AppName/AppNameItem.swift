//
// Created by 和泉田 領一 on 2017/09/24.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

struct AppNameItem: FeedbackItemProtocol {
    let isHidden: Bool
    let name: String

    init(isHidden: Bool, name: String? = nil) {
        self.isHidden = isHidden
        self.name = name ?? AppNameItem.defaultName ?? ""
    }

    private static var defaultName: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
