//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

public protocol TopicProtocol: Equatable, Sendable {
    var title: String { get }
    var localizedTitle: String { get }
}

public enum Topic: String, CaseIterable, Sendable {
    case question = "Question"
    case request = "Request"
    case bugReport = "Bug Report"
    case other = "Other"

    public static var allCases: [Topic] {
        [.question, .request, .bugReport, .other]
    }
}

extension Topic: TopicProtocol {
    public var title: String {
        rawValue
    }

    public var localizedTitle: String {
        localized(title)
    }
}
