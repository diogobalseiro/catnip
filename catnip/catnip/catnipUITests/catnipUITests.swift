//
//  catnipUITests.swift
//  catnipUITests
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import XCTest

final class CatnipUITests: XCTestCase {

    override func setUpWithError() throws {

        continueAfterFailure = false

        try super.setUpWithError()
    }

    func testHappyPath() throws {

        let app = XCUIApplication()
        app.launchArguments = ["-uitesting"]
        app.launch()
        app.activate()
        
        wait(for: 4)
                
        // Tap first cell, go to detail
        var firstCat = listItems(in: app).firstMatch
        XCTAssertTrue(firstCat.waitForExistence(timeout: 3))
        tapAndWait(element: firstCat)

        // Favorite the cat in detail
        var favButton = detailFavoriteButton(in: app).firstMatch
        XCTAssertTrue(favButton.waitForExistence(timeout: 1))
        tapAndWait(element: favButton)

        // Go back
        goBack(in: app)
        wait()

        // Go to favorites tab
        let favoritesTab = favoritesTab(in: app).firstMatch
        XCTAssertTrue(favoritesTab.waitForExistence(timeout: 1))
        tapAndWait(element: favoritesTab)

        // Assert two cats are favorited
        var favoriteItems = listItems(in: app.scrollViews.firstMatch)
        XCTAssertTrue(favoriteItems.buttons.count == 1)

        // Tap first cell, go to detail
        firstCat = listItems(in: app).firstMatch
        XCTAssertTrue(firstCat.waitForExistence(timeout: 1))
        tapAndWait(element: firstCat)

        // Unfavorite the cat
        favButton = detailFavoriteButton(in: app).firstMatch
        XCTAssertTrue(favButton.waitForExistence(timeout: 1))
        tapAndWait(element: favButton)

        // Go back
        goBack(in: app)
        wait()

        // Go to home tab
        let homeTab = homeTab(in: app).firstMatch
        XCTAssertTrue(homeTab.waitForExistence(timeout: 1))
        tapAndWait(element: homeTab)

        // Favorite the first cat
        favButton = listFavoriteButton(in: app).firstMatch
        XCTAssertTrue(favButton.waitForExistence(timeout: 1))
        tapAndWait(element: favButton)

        // Swipe down to reveal search bar
        app.scrollViews.firstMatch.swipeDown()
        wait()

        // Give focus to search field
        let searchField = app.searchFields.firstMatch.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 1))
        tapAndWait(element: searchField)

        // Write "rag"
        searchField.typeText("rag")
        wait(for: 3)
        
        // Favorite the first cat
        favButton = listFavoriteButton(in: app).firstMatch
        XCTAssertTrue(favButton.waitForExistence(timeout: 1))
        tapAndWait(element: favButton)

        // Favorite the second cat
        favButton = listFavoriteButton(in: app).secondItem
        XCTAssertTrue(favButton.waitForExistence(timeout: 1))
        tapAndWait(element: favButton)

        // Tap first cell, go to detail
        firstCat = listItems(in: app).firstMatch
        XCTAssertTrue(firstCat.waitForExistence(timeout: 1))
        tapAndWait(element: firstCat)

        // Favorite the cat in detail
        favButton = detailFavoriteButton(in: app).firstMatch
        XCTAssertTrue(favButton.waitForExistence(timeout: 1))
        tapAndWait(element: favButton)

        // Go back
        goBack(in: app)
        wait()

        // Go to favorites tab
        XCTAssertTrue(favoritesTab.waitForExistence(timeout: 1))
        tapAndWait(element: favoritesTab)

        // Assert two cats are favorited
        favoriteItems = listItems(in: app.scrollViews.firstMatch)
        XCTAssertTrue(favoriteItems.buttons.count == 2)
        
        // Go to home tab
        XCTAssertTrue(homeTab.waitForExistence(timeout: 1))
        tapAndWait(element: homeTab)

        // Take focus from the search field
        let closeButton = searchFieldCloseButton(in: app)
        XCTAssertTrue(closeButton.waitForExistence(timeout: 1))
        tapAndWait(element: closeButton)

        // Scroll to the bottom by swiping up multiple times
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 1))
        
        // Scroll to bottom
        scrollToBottom(in: scrollView)

        // Scroll back up
        scrollToTop(in: scrollView)
    }
}
