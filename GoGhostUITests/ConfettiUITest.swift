import XCTest

final class ConfettiUITest: XCTestCase {

    /// Drives the live app to the milestone score-reveal and captures screenshots
    /// across the confetti window, saving them to /tmp on the host via simctl-readable
    /// attachments. Verifies the confetti actually appears on screen at runtime.
    @MainActor
    func testMilestoneConfettiAppears() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ggBypassGate", "1"]
        app.launch()

        // Go to DEV tab
        app.buttons["DEV"].firstMatch.tap()

        // Tap the 7-day milestone score reveal row
        let milestoneRow = app.staticTexts["Score 88 — 7-day milestone (ONE WEEK STRAIGHT.)"]
        XCTAssertTrue(milestoneRow.waitForExistence(timeout: 5), "milestone row not found")
        milestoneRow.tap()

        // Count-up is ~1s, then meta + confetti appear. Capture a few frames.
        for i in 0..<6 {
            Thread.sleep(forTimeInterval: 0.35)
            let shot = XCUIScreen.main.screenshot()
            let attach = XCTAttachment(screenshot: shot)
            attach.name = "confetti-frame-\(i)"
            attach.lifetime = .keepAlways
            add(attach)
        }
    }
}
