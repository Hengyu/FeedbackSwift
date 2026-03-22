@testable import FeedbackSwift
import XCTest

final class FeedbackConfigurationTests: XCTestCase {
    func testDefaultConfiguration() {
        let config = makeConfiguration()
        XCTAssertNil(config.subject)
        XCTAssertNil(config.additionalDiagnosticContent)
        XCTAssertEqual(config.toRecipients, ["to@example.com"])
        XCTAssertEqual(config.ccRecipients, [])
        XCTAssertEqual(config.bccRecipients, [])
        XCTAssertFalse(config.usesHTML)
        XCTAssertEqual(config.preference, .default)
        XCTAssertEqual(config.topics.count, Topic.allCases.count)
    }

    func testCustomConfiguration() {
        let config = makeConfiguration(
            subject: "Bug",
            additionalDiagnosticContent: "extra",
            topics: [Topic.bugReport],
            toRecipients: ["a@b.com"],
            ccRecipients: ["cc@b.com"],
            bccRecipients: ["bcc@b.com"],
            usesHTML: true,
            preference: FeedbackUnitPreference(
                enablesUserEmail: true,
                enablesAttachment: false,
                enablesCameraPicker: true,
                showsAppInfo: true
            )
        )
        XCTAssertEqual(config.subject, "Bug")
        XCTAssertEqual(config.additionalDiagnosticContent, "extra")
        XCTAssertEqual(config.topics.count, 1)
        XCTAssertEqual(config.toRecipients, ["a@b.com"])
        XCTAssertEqual(config.ccRecipients, ["cc@b.com"])
        XCTAssertEqual(config.bccRecipients, ["bcc@b.com"])
        XCTAssertTrue(config.usesHTML)
        XCTAssertTrue(config.preference.enablesUserEmail)
        XCTAssertFalse(config.preference.enablesAttachment)
        XCTAssertTrue(config.preference.enablesCameraPicker)
        XCTAssertTrue(config.preference.showsAppInfo)
    }

    func testCustomTopics() {
        let config = makeConfiguration(topics: MockTopic.allCases)
        XCTAssertEqual(config.topics.count, 2)
        XCTAssertEqual(config.topics.first?.title, "Alpha")
    }
}
