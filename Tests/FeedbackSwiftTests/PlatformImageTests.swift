@testable import FeedbackSwift
import XCTest

final class PlatformImageTests: XCTestCase {
    func testJpegDataFromPlatformImage() {
        let img = makeTestImage()
        XCTAssertNotNil(img.jpegData(compressionQuality: 1.0))
    }

    func testImageFromData() {
        let img = makeTestImage()
        guard let data = img.jpegData(compressionQuality: 1.0) else {
            XCTFail("Failed to create JPEG data")
            return
        }
        let restored = PlatformImage(data: data)
        XCTAssertNotNil(restored)
    }
}
