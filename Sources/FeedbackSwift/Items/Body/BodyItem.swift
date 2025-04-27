//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

struct BodyItem: FeedbackUnit {
    let display: Bool
    let bodyText: String?

    init(display: Bool = true, bodyText: String? = nil) {
        self.display = display
        self.bodyText = bodyText
    }
}
