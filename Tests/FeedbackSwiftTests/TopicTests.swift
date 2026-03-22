@testable import FeedbackSwift
import XCTest

final class TopicTests: XCTestCase {
    func testAllCases() {
        let cases = Topic.allCases
        XCTAssertEqual(cases.count, 4)
        XCTAssertEqual(cases[0], .question)
        XCTAssertEqual(cases[1], .request)
        XCTAssertEqual(cases[2], .bugReport)
        XCTAssertEqual(cases[3], .other)
    }

    func testTitle() {
        XCTAssertEqual(Topic.question.title, "Question")
        XCTAssertEqual(Topic.request.title, "Request")
        XCTAssertEqual(Topic.bugReport.title, "Bug Report")
        XCTAssertEqual(Topic.other.title, "Other")
    }

    func testLocalizedTitleFallsBackToTitle() {
        for topic in Topic.allCases {
            XCTAssertFalse(topic.localizedTitle.isEmpty)
        }
    }
}
