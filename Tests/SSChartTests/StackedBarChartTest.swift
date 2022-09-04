//
//  StackedBarChartTest.swift
//  SSChartTests
//
//  Created by NHN on 2022/09/05.
//

import XCTest
import SSChart

class StackedBarChartTest: XCTestCase {
    
    var sut: StackedBarChart!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = StackedBarChart()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

}
