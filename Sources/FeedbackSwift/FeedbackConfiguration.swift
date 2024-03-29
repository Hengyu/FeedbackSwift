//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

public class FeedbackConfiguration {
    public var subject: String?
    public var additionalDiagnosticContent: String?
    public var toRecipients: [String]
    public var ccRecipients: [String]
    public var bccRecipients: [String]
    public var usesHTML: Bool
    public var dataSource: FeedbackItemsDataSource

    /// - Note: `hidesAttachmentCell` only takes effect on macCatalyst 14.0+.
    public init(
        subject: String? = .none,
        additionalDiagnosticContent: String? = .none,
        topics: [TopicProtocol] = TopicItem.defaultTopics,
        toRecipients: [String],
        ccRecipients: [String] = [],
        bccRecipients: [String] = [],
        hidesUserEmailCell: Bool = true,
        hidesAttachmentCell: Bool = false,
        hidesAppInfoSection: Bool = false,
        usesHTML: Bool = false,
        appName: String? = nil
    ) {
        self.subject = subject
        self.additionalDiagnosticContent = additionalDiagnosticContent
        self.toRecipients = toRecipients
        self.ccRecipients = ccRecipients
        self.bccRecipients = bccRecipients
        self.usesHTML = usesHTML
        self.dataSource = FeedbackItemsDataSource(
            topics: topics,
            hidesUserEmailCell: hidesUserEmailCell,
            hidesAttachmentCell: hidesAttachmentCell,
            hidesAppInfoSection: hidesAppInfoSection,
            appName: appName
        )
    }
}
