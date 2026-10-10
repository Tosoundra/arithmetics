import XCTest

final class ArithmeticsUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    func testWrongAnswerRetryPauseResumeAndHistory() {
        XCTAssertTrue(app.buttons["startTraining"].waitForExistence(timeout: 10))
        attach("01-home")
        app.buttons["startTraining"].tap()
        XCTAssertTrue(app.staticTexts["problemExpression"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["problemExpression"].label, "2 + 3")
        app.buttons["digit-4"].tap()
        app.buttons["checkAnswer"].tap()
        XCTAssertTrue(app.staticTexts["incorrectFeedback"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["problemExpression"].label, "2 + 3")
        app.buttons["digit-5"].tap()
        app.buttons["checkAnswer"].tap()
        XCTAssertTrue(app.staticTexts["correctFeedback"].waitForExistence(timeout: 3))
        attach("02-practice")

        app.buttons["closeTraining"].tap()
        app.buttons["Pause and save"].tap()
        XCTAssertTrue(app.buttons["resumeTraining"].waitForExistence(timeout: 5))
        app.terminate()
        app.launchArguments.insert("--preserve-test-data", at: 0)
        app.launch()
        app.buttons["resumeTraining"].tap()
        XCTAssertTrue(app.buttons["nextProblem"].waitForExistence(timeout: 5))
        app.buttons["closeTraining"].tap()
        app.buttons["Finish training"].tap()
        XCTAssertTrue(app.buttons["backHome"].waitForExistence(timeout: 5))
        attach("03-results")
        app.buttons["backHome"].tap()
        app.tabBars.buttons["Progress"].tap()
        XCTAssertTrue(app.buttons["historyRow"].waitForExistence(timeout: 5))
        attach("04-progress")
        app.terminate()
        app.launch()
        app.tabBars.buttons["Progress"].tap()
        XCTAssertTrue(app.buttons["historyRow"].waitForExistence(timeout: 5))
    }

    func testAllOperationsHaveNativeInputAndRevealIsASkip() {
        let cases: [(String, String, String)] = [
            ("addition", "2 + 3", "5"), ("subtraction", "8 − 3", "5"),
            ("multiplication", "4 × 3", "12"), ("division", "12 ÷ 3", "4")
        ]
        for (operation, expression, answer) in cases {
            app.buttons["operation-\(operation)"].tap()
            app.buttons["startTraining"].tap()
            XCTAssertTrue(app.staticTexts["problemExpression"].waitForExistence(timeout: 5))
            XCTAssertEqual(app.staticTexts["problemExpression"].label, expression)
            for digit in answer { app.buttons["digit-\(digit)"].tap() }
            app.buttons["checkAnswer"].tap()
            XCTAssertTrue(app.staticTexts["correctFeedback"].waitForExistence(timeout: 3))
            app.buttons["nextProblem"].tap()
            app.buttons["revealAnswer"].tap()
            app.buttons["Show answer"].lastMatch.tap()
            XCTAssertTrue(app.staticTexts["revealedFeedback"].waitForExistence(timeout: 3))
            app.buttons["closeTraining"].tap()
            app.buttons["Finish training"].tap()
            app.buttons["backHome"].tap()
        }
    }

    func testRussianLocalizationAndLargeText() {
        app.terminate()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Арифметика"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["startTraining"].exists)
        attach("05-russian-large-text")
    }

    private func attach(_ name: String) {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
