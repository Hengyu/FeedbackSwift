//
// Created by 和泉田 領一 on 2017/09/24.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

struct SystemVersionItem: FeedbackUnit {
    let display: Bool

    var version: String {
        ProcessInfo.processInfo.operatingSystemVersionString
    }

    init(display: Bool = true) {
        self.display = display
    }
}
