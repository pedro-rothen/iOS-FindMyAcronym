//
//  FindMyAcronymUITestsLaunchTests.swift
//  FindMyAcronymUITests
//
//  Created by Pedro on 15-07-24.
//

import XCTest

final class FindMyAcronymUITestsLaunchTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
