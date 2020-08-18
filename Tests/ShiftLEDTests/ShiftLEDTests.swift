//
//  ShiftLEDTests.swift
//
//
//  Created by Kit Transue on 2020-06-04.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest

import DeftBus
import LEDUtils
@testable import ShiftLED


class ShiftLEDTests: XCTestCase {
    class MockSPI: LinkSPI {
        var checkers = [ (data: Data) -> Void ]()

        func expectWrite(checking: @escaping (_ data: Data) -> Void) {
            checkers.append(checking)
        }

        func checkExpectedConsumed() {
            XCTAssert(checkers.isEmpty, "expected number of writes made")
        }

        func write(data: Data) {
            assert(!checkers.isEmpty)
            let expectation = checkers.removeFirst()
            expectation(data)
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testColorEncoding() throws {
        let link = MockSPI()
        let leds = ShiftLED(bus: link, stringLength: 3)

        link.expectWrite { data in
           let firstFrame = data[4]
                let frameStart = UInt8(0b1110_0000)
                XCTAssertEqual(firstFrame & frameStart, frameStart, "first three current bits always high")
                let current = firstFrame & ~frameStart

                XCTAssertEqual(Float(current), 32.0 * 0.75, accuracy: 2.0, "Current should be expressed in remaining 5 bits")

                XCTAssertEqual(Float(data[5]), 255.0, accuracy: 2.0, "blue in BGR encoding")
                XCTAssertEqual(Float(data[6]), 64.0, accuracy: 2.0, "green in BGR encoding")
                XCTAssertEqual(Float(data[7]), 127.0, accuracy: 2.0, "red in BGR encoding")
        }

        let testColor = LEDColor(red: 0.5, green: 0.25, blue: 1.0)
        leds.setCurrent(current: 0.75)
        leds.all(color: testColor)

        link.checkExpectedConsumed()
    }

    func testPrologueAndEpilogue() throws {
        let link = MockSPI()
        let leds = ShiftLED(bus: link, stringLength: 3)

        link.expectWrite { data in
            XCTAssertEqual(data.count, 5 * 4, "should have prologue and epilogue")
            XCTAssertEqual(data.prefix(upTo: 4), Data(repeating: 0, count: 4), "prefix of zeros")
            XCTAssertEqual(data.suffix(4), Data(repeating: 0xff, count: 4), "should end with block with all bits set")
        }

        let testColor = LEDColor(red: 0.5, green: 0.25, blue: 1.0)
        leds.all(color: testColor)

        link.checkExpectedConsumed()
    }

}
