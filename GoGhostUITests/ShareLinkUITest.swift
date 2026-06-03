import XCTest

final class ShareLinkUITest: XCTestCase {

    /// Opens the weekly recap and taps the native ShareLink, then captures the
    /// system share sheet. With a Transferable PNG + SharePreview, the sheet shows
    /// the card thumbnail and "Save Image"/Photos actions.
    @MainActor
    func testWeeklyShareLink() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ggBypassGate", "1"]
        app.launch()

        app.buttons["DEV"].firstMatch.tap()

        let recapRow = app.staticTexts["Show weekly recap (mock data)"]
        XCTAssertTrue(recapRow.waitForExistence(timeout: 5), "weekly recap row not found")
        recapRow.tap()

        // The ShareLink renders as a tappable button only once the image is rendered.
        let shareBtn = app.buttons["SHARE THIS WEEK"]
        XCTAssertTrue(shareBtn.waitForExistence(timeout: 5), "ShareLink button not ready (image didn't render)")
        XCTAssertTrue(shareBtn.isHittable, "ShareLink button not hittable")
        shareBtn.tap()

        // Wait for the system share sheet to animate up, capture as evidence.
        // (The sheet runs in a separate process; asserting its internal elements is
        // brittle, so the screenshot is the verification artifact.)
        Thread.sleep(forTimeInterval: 2.5)
        let shot = XCUIScreen.main.screenshot()
        let attach = XCTAttachment(screenshot: shot)
        attach.name = "sharelink-sheet"
        attach.lifetime = .keepAlways
        add(attach)
    }
}
