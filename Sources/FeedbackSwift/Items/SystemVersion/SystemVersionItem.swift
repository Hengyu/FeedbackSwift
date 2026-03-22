//
// Created by 和泉田 領一 on 2017/09/24.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

struct SystemVersionItem {
    static var version: String {
        ProcessInfo.processInfo.operatingSystemVersionString
    }
}
