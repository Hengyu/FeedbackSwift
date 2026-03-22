@testable import FeedbackSwift
import XCTest

final class MediaTests: XCTestCase {
    func testImageEquality() {
        let img = makeTestImage()
        let a = Media.image(img)
        let b = Media.image(img)
        XCTAssertEqual(a, b)
    }

    func testImageInequalityWithVideo() {
        let img = makeTestImage()
        let url = URL(fileURLWithPath: "/tmp/test.mp4")
        let a = Media.image(img)
        let b = Media.video(img, url)
        XCTAssertNotEqual(a, b)
    }

    func testVideoEqualityByURL() {
        let img1 = makeTestImage()
        let img2 = makeTestImage()
        let url = URL(fileURLWithPath: "/tmp/test.mp4")
        let a = Media.video(img1, url)
        let b = Media.video(img2, url)
        XCTAssertEqual(a, b)
    }

    func testVideoInequalityByURL() {
        let img = makeTestImage()
        let a = Media.video(img, URL(fileURLWithPath: "/tmp/a.mp4"))
        let b = Media.video(img, URL(fileURLWithPath: "/tmp/b.mp4"))
        XCTAssertNotEqual(a, b)
    }

    func testJpegDataForImage() {
        let img = makeTestImage()
        let media = Media.image(img)
        XCTAssertNotNil(media.jpegData)
    }

    func testJpegDataNilForVideo() {
        let img = makeTestImage()
        let media = Media.video(img, URL(fileURLWithPath: "/tmp/test.mp4"))
        XCTAssertNil(media.jpegData)
    }

    func testVideoDataNilForImage() {
        let img = makeTestImage()
        let media = Media.image(img)
        XCTAssertNil(media.videoData)
    }

    func testVideoDataNilForNonexistentFile() {
        let img = makeTestImage()
        let media = Media.video(img, URL(fileURLWithPath: "/nonexistent/path.mp4"))
        XCTAssertNil(media.videoData)
    }
}
