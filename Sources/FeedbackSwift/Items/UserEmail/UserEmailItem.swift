//
// Created by 和泉田 領一 on 2017/09/24.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

struct UserEmailItem: FeedbackUnit {
    let display: Bool
    var email: String?

    init(display: Bool) {
        self.display = display
    }
}
