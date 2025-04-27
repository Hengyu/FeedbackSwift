//
// Created by 和泉田 領一 on 2017/09/24.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

public protocol FeedbackUnit: Identifiable, Sendable {
    var display: Bool { get }
}

extension FeedbackUnit {
    public var id: String {
        String(describing: type(of: self)) + ".\(display ? "1" : "0")"
    }
}
