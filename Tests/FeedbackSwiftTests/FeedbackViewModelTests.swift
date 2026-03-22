@testable import FeedbackSwift
import XCTest

@MainActor
final class FeedbackViewModelTests: XCTestCase {
    func testInitialState() {
        let vm = FeedbackViewModel(topics: Topic.allCases, preference: .default)
        XCTAssertEqual(vm.userEmail, "")
        XCTAssertEqual(vm.bodyText, "")
        XCTAssertNil(vm.attachmentMedia)
        XCTAssertFalse(vm.hasAttachedMedia)
        XCTAssertEqual(vm.topics.count, 4)
        XCTAssertEqual(vm.selectedTopic?.title, Topic.question.title)
    }

    func testInitWithEmptyTopics() {
        let vm = FeedbackViewModel(topics: [], preference: .default)
        XCTAssertTrue(vm.topics.isEmpty)
        XCTAssertNil(vm.selectedTopic)
    }

    func testInitWithCustomTopics() {
        let vm = FeedbackViewModel(topics: MockTopic.allCases, preference: .default)
        XCTAssertEqual(vm.topics.count, 2)
        XCTAssertEqual(vm.selectedTopic?.title, "Alpha")
    }

    func testUserEmailUpdate() {
        let vm = FeedbackViewModel(topics: Topic.allCases, preference: .default)
        vm.userEmail = "test@example.com"
        XCTAssertEqual(vm.userEmail, "test@example.com")
    }

    func testBodyTextUpdate() {
        let vm = FeedbackViewModel(topics: Topic.allCases, preference: .default)
        vm.bodyText = "Some feedback"
        XCTAssertEqual(vm.bodyText, "Some feedback")
    }

    func testTopicSelection() {
        let vm = FeedbackViewModel(topics: Topic.allCases, preference: .default)
        vm.selectedTopic = Topic.bugReport
        XCTAssertEqual(vm.selectedTopic?.title, "Bug Report")
    }

    func testDeleteAttachment() {
        let vm = FeedbackViewModel(topics: Topic.allCases, preference: .default)
        let img = makeTestImage()
        vm.attachmentMedia = .image(img)
        XCTAssertTrue(vm.hasAttachedMedia)

        vm.deleteAttachment()
        XCTAssertNil(vm.attachmentMedia)
        XCTAssertFalse(vm.hasAttachedMedia)
    }

    func testShowMailConfigError() {
        let vm = FeedbackViewModel(topics: Topic.allCases, preference: .default)
        XCTAssertFalse(vm.showingError)

        vm.showMailConfigError()
        XCTAssertTrue(vm.showingError)
        XCTAssertFalse(vm.errorMessage.isEmpty)
    }

    func testShowPermissionAlert() {
        let vm = FeedbackViewModel(topics: Topic.allCases, preference: .default)
        XCTAssertFalse(vm.showingPermissionAlert)

        vm.showPermissionAlert(for: "Need camera access")
        XCTAssertTrue(vm.showingPermissionAlert)
        XCTAssertEqual(vm.permissionAlertMessage, "Need camera access")
    }

    func testPresentationStateDefaults() {
        let vm = FeedbackViewModel(topics: Topic.allCases, preference: .default)
        XCTAssertFalse(vm.showingAttachmentOptions)
        XCTAssertFalse(vm.showingMailComposer)
        XCTAssertFalse(vm.showingPhotoPicker)
        XCTAssertFalse(vm.showingCameraPicker)
        XCTAssertFalse(vm.showingPermissionAlert)
        XCTAssertFalse(vm.showingError)
    }

    func testSystemInfoProperties() {
        let vm = FeedbackViewModel(topics: Topic.allCases, preference: .default)
        XCTAssertFalse(vm.systemVersion.isEmpty)
    }

    func testGenerateFeedbackIntegration() {
        let config = makeConfiguration(toRecipients: ["to@test.com"])
        let vm = FeedbackViewModel(topics: config.topics, preference: config.preference)
        vm.userEmail = "user@test.com"
        vm.bodyText = "Great app!"
        vm.selectedTopic = Topic.request

        let feedback = vm.generateFeedback(configuration: config)
        XCTAssertEqual(feedback.email, "user@test.com")
        XCTAssertEqual(feedback.to, ["to@test.com"])
        XCTAssertTrue(feedback.body.contains("Great app!"))
        XCTAssertFalse(feedback.isHTML)
    }

    func testGenerateFeedbackEmptyEmailIsNil() {
        let config = makeConfiguration()
        let vm = FeedbackViewModel(topics: config.topics, preference: config.preference)
        vm.userEmail = ""

        let feedback = vm.generateFeedback(configuration: config)
        XCTAssertNil(feedback.email)
    }

    func testGenerateFeedbackWithAttachment() {
        let config = makeConfiguration()
        let vm = FeedbackViewModel(topics: config.topics, preference: config.preference)
        let img = makeTestImage()
        vm.attachmentMedia = .image(img)

        let feedback = vm.generateFeedback(configuration: config)
        XCTAssertNotNil(feedback.jpeg)
        XCTAssertNil(feedback.mp4)
    }

    func testPreferenceStoredCorrectly() {
        let pref = FeedbackUnitPreference(
            enablesUserEmail: true,
            enablesAttachment: false,
            enablesCameraPicker: true,
            showsAppInfo: true
        )
        let vm = FeedbackViewModel(topics: Topic.allCases, preference: pref)
        XCTAssertEqual(vm.preference, pref)
    }
}
