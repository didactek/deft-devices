//
//  BitStorageTests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-09.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest

class BitStorageTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBoolInit() throws {
        class BoolAndBit: BitStorageCore {
            @position(SubByte(ofByte: 1, bit: 7))
            var msb = true

            @position(SubByte(ofByte: 1, bit: 0))
            var lsb = false

            @position(SubByte(ofByte: 1, bit: 2))
            var mid = true
        }

        let coder = BoolAndBit()
        XCTAssert(coder.storage.bytes.count == 1, "described bits should fit in single byte")
        XCTAssert(coder.msb == true, "initial value preserved")
        XCTAssert(coder.lsb == false, "initial value preserved")
        XCTAssert(coder.mid == true, "initial value preserved")

        XCTAssert(coder.storage.bytes[0] == 0b1000_0100, "encoding positions")
    }
}
