@testable import FeedbackSwift
import XCTest

final class FeedbackUnitPreferenceTests: XCTestCase {
    func testDefaultPreference() {
        let pref = FeedbackUnitPreference.default
        XCTAssertFalse(pref.enablesUserEmail)
        XCTAssertTrue(pref.enablesAttachment)
        XCTAssertFalse(pref.enablesCameraPicker)
        XCTAssertFalse(pref.showsAppInfo)
    }

    func testEquatable() {
        let a = FeedbackUnitPreference(enablesUserEmail: true)
        let b = FeedbackUnitPreference(enablesUserEmail: true)
        let c = FeedbackUnitPreference(enablesUserEmail: false)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testHashable() {
        let a = FeedbackUnitPreference(enablesUserEmail: true, showsAppInfo: true)
        let b = FeedbackUnitPreference(enablesUserEmail: true, showsAppInfo: true)
        XCTAssertEqual(a.hashValue, b.hashValue)

        var set = Set<FeedbackUnitPreference>()
        set.insert(a)
        set.insert(b)
        XCTAssertEqual(set.count, 1)
    }
}
