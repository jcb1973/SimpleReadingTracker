import XCTest

final class ScreenshotTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testGenerateAppStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-sample-data"]
        app.launch()

        // Wait for Home screen to load
        let homeTitle = app.staticTexts["Home"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 10))
        sleep(2)

        // Screenshot 1: Home Screen
        saveScreenshot(app, name: "01_Home")

        // Tap Library tab
        let libraryTab = app.buttons["Library"]
        XCTAssertTrue(libraryTab.waitForExistence(timeout: 5))
        libraryTab.tap()
        sleep(1)

        // Screenshot 2: Library Screen
        saveScreenshot(app, name: "02_Library")

        // Tap the first visible cell in the library
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
            sleep(1)

            // Screenshot 3: Book Detail
            saveScreenshot(app, name: "03_BookDetail")

            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }

        // Scroll down in library to show more books, then screenshot
        let libraryList = app.collectionViews.firstMatch
        if libraryList.exists {
            libraryList.swipeUp()
            sleep(1)
            saveScreenshot(app, name: "05_Library_Scrolled")
        }

        // Go to Home tab and tap a Currently Reading book
        let homeTab = app.buttons["Home"]
        homeTab.tap()
        sleep(1)

        let currentlyReadingCard = app.scrollViews.buttons.matching(
            NSPredicate(format: "label BEGINSWITH 'Quarantine'")
        ).firstMatch
        if currentlyReadingCard.waitForExistence(timeout: 5) {
            currentlyReadingCard.tap()
            sleep(1)
            saveScreenshot(app, name: "04_BookDetail_Reading")
        }
    }

    private func saveScreenshot(_ app: XCUIApplication, name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
