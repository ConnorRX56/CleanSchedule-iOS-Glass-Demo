import XCTest

final class GlassDemoUITests: XCTestCase {
    private var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
    }
    private func node(_ id: String) -> XCUIElement { app.descendants(matching: .any)[id].firstMatch }

    func testTapWeekSelectAndReturn() {
        let week = node("weekControl")
        XCTAssertTrue(week.waitForExistence(timeout: 8))
        week.tap()
        let option = node("week-option-2")
        XCTAssertTrue(option.waitForExistence(timeout: 4))
        option.tap()
        XCTAssertTrue(week.waitForExistence(timeout: 3))
        XCTAssertEqual(week.value as? String, "W02")
    }
    func testHorizontalSwipeChangesWeekWithoutOpeningThePanel() {
        let week = node("weekControl")
        XCTAssertTrue(week.waitForExistence(timeout: 8))
        let start = week.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        let end = week.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: end)
        XCTAssertEqual(week.value as? String, "W02")
        XCTAssertFalse(node("week-option-2").exists)
    }
    func testPullSplitsControlsAndDateReturns() {
        let week = node("weekControl")
        XCTAssertTrue(week.waitForExistence(timeout: 8))
        let start = week.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = start.withOffset(CGVector(dx: 0, dy: 100))
        start.press(forDuration: 0.05, thenDragTo: end)
        let date = node("dateControl")
        XCTAssertTrue(date.waitForExistence(timeout: 4))
        date.tap()
        XCTAssertTrue(node("datePanel").waitForExistence(timeout: 4))
        // SwiftUI containers can propagate their identifier to children. The
        // visible, accessible close action is the user-facing contract here.
        let close = app.buttons["关闭"].firstMatch
        if !close.waitForExistence(timeout: 4) { print(app.debugDescription) }
        XCTAssertTrue(close.exists)
        XCTAssertTrue(close.isHittable)
        close.tap()
        XCTAssertTrue(date.waitForExistence(timeout: 4))
        let gone = NSPredicate(format: "exists == false")
        expectation(for: gone, evaluatedWith: node("datePanel"))
        waitForExpectations(timeout: 4)
        XCTAssertEqual(week.value as? String, "W01")
    }
}
