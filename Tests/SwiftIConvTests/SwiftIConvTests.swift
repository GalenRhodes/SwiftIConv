//
//  SwiftIConvTests.swift
//  SwiftIConvTests
//
//  Created by Galen Rhodes on 5/16/22.
//

import XCTest
@testable import SwiftIConv

class SwiftIConvTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testList() throws {
        let list: [String] = SwiftIConv.allEncodings

        for s in list {
            print(s)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
