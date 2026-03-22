@testable import FeedbackSwift
import XCTest

final class SystemVersionItemTests: XCTestCase {
    func testVersionNotEmpty() {
        XCTAssertFalse(SystemVersionItem.version.isEmpty)
    }

    func testVersionMatchesProcessInfo() {
        XCTAssertEqual(
            SystemVersionItem.version,
            ProcessInfo.processInfo.operatingSystemVersionString
        )
    }
}
