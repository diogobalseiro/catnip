//
//  CatnipUITests+Extensions.swift
//  catnipUITests
//
//  Created by Diogo Balseiro on 29/12/2025.
//

import Foundation
import XCTest

extension CatnipUITests {
        
    func listItems(in element: XCUIElement) -> XCUIElementQuery {
        
         element.buttons
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "ListItem_"))
    }
    
    func detailFavoriteButton(in element: XCUIElement) -> XCUIElementQuery {
        
        element.buttons
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "DetailFavoriteButton"))
    }
    
    func listFavoriteButton(in element: XCUIElement) -> XCUIElementQuery {
        
        element.buttons
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "FavoriteButton_"))
    }
    
    func goBack(in element: XCUIElement) {
        
        let backButton = element.navigationBars.buttons.firstMatch
        
        if backButton.exists {
            
            backButton.tap()
            
        } else {
            
            element.swipeRight()
        }
    }
    
    func searchFieldCloseButton(in element: XCUIElement) -> XCUIElement {
        
        element.buttons["Close"].firstMatch
    }

    func homeTab(in element: XCUIElement) -> XCUIElementQuery {
        
        tab(identifier: "infinity", in: element)
    }

    func favoritesTab(in element: XCUIElement) -> XCUIElementQuery {
        
        tab(identifier: "star.fill", in: element)
    }

    private func tab(identifier: String,
                     in element: XCUIElement) -> XCUIElementQuery {
        
        element.images
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", identifier))
    }
    
    func scrollToBottom(in element: XCUIElement) {
        
        for _ in 0..<4 {
            element.swipeUp(velocity: 7500)
            wait(for: 1.0)
        }
    }
    
    func scrollToTop(in element: XCUIElement) {
        
        for _ in 0..<3 {
            element.swipeDown(velocity: 7500)
            wait(for: 1.0)
        }
    }
}

extension XCTestCase {
    
    func tapAndWait(element: XCUIElement,
                    duration: TimeInterval = 1.0) {
        
        element.tap()
        wait(for: duration)
    }
    
    func wait(for duration: TimeInterval = 1.0) {
        
        let expectation = XCTestExpectation(description: "Wait")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: duration + 1)
    }
}

extension XCUIElementQuery {
    
    var secondItem: XCUIElement {
        
        element(boundBy: 1)
    }
}
