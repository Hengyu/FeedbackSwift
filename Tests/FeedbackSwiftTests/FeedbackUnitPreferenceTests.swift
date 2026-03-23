@testable import FeedbackSwift
import XCTest

final class FeedbackUnitPreferenceTests: XCTestCase {
    func testDefaultPreference() {
        let pref = FeedbackUnitPreference.default
        XCTAssertTrue(pref.enablesAttachment)
        XCTAssertFalse(pref.enablesCameraPicker)
        XCTAssertFalse(pref.showsAppInfo)
    }

    func testEquatable() {
        let a = FeedbackUnitPreference(enablesAttachment: true)
        let b = FeedbackUnitPreference(enablesAttachment: true)
        let c = FeedbackUnitPreference(enablesAttachment: false)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testHashable() {
        let a = FeedbackUnitPreference(enablesAttachment: true, showsAppInfo: true)
        let b = FeedbackUnitPreference(enablesAttachment: true, showsAppInfo: true)
        XCTAssertEqual(a.hashValue, b.hashValue)

        var set = Set<FeedbackUnitPreference>()
        set.insert(a)
        set.insert(b)
        XCTAssertEqual(set.count, 1)
    }
}
