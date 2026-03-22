//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

public struct FeedbackUnitPreference: Equatable, Hashable, Sendable {
    public let enablesUserEmail: Bool
    public let enablesAttachment: Bool
    public let enablesCameraPicker: Bool
    public let showsAppInfo: Bool

    public init(
        enablesUserEmail: Bool = false,
        enablesAttachment: Bool = true,
        enablesCameraPicker: Bool = false,
        showsAppInfo: Bool = false
    ) {
        self.enablesUserEmail = enablesUserEmail
        self.enablesAttachment = enablesAttachment
        self.enablesCameraPicker = enablesCameraPicker
        self.showsAppInfo = showsAppInfo
    }

    public static let `default`: FeedbackUnitPreference = .init()
}

public struct FeedbackConfiguration: Sendable {
    public let subject: String?
    public let additionalDiagnosticContent: String?
    public let topics: [any TopicProtocol]
    public let toRecipients: [String]
    public let ccRecipients: [String]
    public let bccRecipients: [String]
    public let usesHTML: Bool
    public let preference: FeedbackUnitPreference

    public init(
        subject: String? = .none,
        additionalDiagnosticContent: String? = nil,
        topics: [any TopicProtocol] = Topic.allCases,
        toRecipients: [String],
        ccRecipients: [String] = [],
        bccRecipients: [String] = [],
        usesHTML: Bool = false,
        preference: FeedbackUnitPreference = .default
    ) {
        self.subject = subject
        self.additionalDiagnosticContent = additionalDiagnosticContent
        self.topics = topics
        self.toRecipients = toRecipients
        self.ccRecipients = ccRecipients
        self.bccRecipients = bccRecipients
        self.usesHTML = usesHTML
        self.preference = preference
    }
}
