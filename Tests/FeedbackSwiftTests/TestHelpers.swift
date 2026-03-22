@testable import FeedbackSwift
import XCTest

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum MockTopic: String, CaseIterable, Sendable {
    case alpha = "Alpha"
    case beta = "Beta"
}

extension MockTopic: TopicProtocol {
    var title: String { rawValue }
    var localizedTitle: String { rawValue }
}

func makeConfiguration(
    subject: String? = nil,
    additionalDiagnosticContent: String? = nil,
    topics: [any TopicProtocol] = Topic.allCases,
    toRecipients: [String] = ["to@example.com"],
    ccRecipients: [String] = [],
    bccRecipients: [String] = [],
    usesHTML: Bool = false,
    preference: FeedbackUnitPreference = .default
) -> FeedbackConfiguration {
    FeedbackConfiguration(
        subject: subject,
        additionalDiagnosticContent: additionalDiagnosticContent,
        topics: topics,
        toRecipients: toRecipients,
        ccRecipients: ccRecipients,
        bccRecipients: bccRecipients,
        usesHTML: usesHTML,
        preference: preference
    )
}

func makeTestImage() -> PlatformImage {
    #if canImport(UIKit)
    UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { ctx in
        UIColor.red.setFill()
        ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    #elseif canImport(AppKit)
    let image = NSImage(size: NSSize(width: 1, height: 1))
    image.lockFocus()
    NSColor.red.setFill()
    NSRect(x: 0, y: 0, width: 1, height: 1).fill()
    image.unlockFocus()
    return image
    #endif
}
