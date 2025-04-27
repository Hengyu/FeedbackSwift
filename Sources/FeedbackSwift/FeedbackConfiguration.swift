//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

public struct FeedbackConfiguration: Equatable, Sendable {
    public let subject: String?
    public let additionalDiagnosticContent: String?
    public let toRecipients: [String]
    public let ccRecipients: [String]
    public let bccRecipients: [String]
    public let usesHTML: Bool
    public let preference: FeedbackUnitPreference
    public var dataSource: FeedbackItemsDataSource

    public init(
        subject: String? = .none,
        additionalDiagnosticContent: String? = nil,
        topics: [any TopicProtocol] = Topic.allCases,
        toRecipients: [String],
        ccRecipients: [String] = [],
        bccRecipients: [String] = [],
        usesHTML: Bool = false,
        preference: FeedbackUnitPreference
    ) {
        self.subject = subject
        self.additionalDiagnosticContent = additionalDiagnosticContent
        self.toRecipients = toRecipients
        self.ccRecipients = ccRecipients
        self.bccRecipients = bccRecipients
        self.usesHTML = usesHTML
        self.preference = preference
        self.dataSource = FeedbackItemsDataSource(
            topics: topics,
            preference: preference
        )
    }
}
