@testable import FeedbackSwift
import XCTest

final class DeviceNameItemTests: XCTestCase {
    func testDeviceNameDoesNotCrash() {
        _ = DeviceNameItem.name
    }
}
