//
//  MCP9808Tests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-21.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
import DeftBus
@testable import MCP9808

class MCP9808Tests: XCTestCase {
    class MockTransport: ShellTransport {
        enum Operation {
            case receive(String)
            case i2ctransfer(String)
        }
        var expected: [Operation] = []
        func assertExpectedConsumed() {
            XCTAssertTrue(expected.isEmpty, "all scripted operations consumed")
        }
        func expect(_ operation: Operation) {
            expected.append(operation)
        }

        func send(_ command: String) {
            let operation = expected.removeFirst()
            switch operation {
            case .i2ctransfer(let args) :
                let extendedExpected = "/usr/sbin/i2ctransfer -y " + args
                XCTAssertEqual(command, extendedExpected)
            default:
                XCTFail("Unexpected operation \(command)")
            }
        }

        func receive() -> String {
            let operation = expected.removeFirst()
            switch operation {
            case .receive(let scriptedResult) :
                return scriptedResult
            default:
                XCTFail("Unexpected receive operation")
                return "" // FIXME: is there a testcase abort that could mark this unreachable?
            }
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNegativeTemperature() throws {
        let commands = MockTransport()
        let link = try! I2CToolsLink(transport: commands, busID: 6, nodeAddress: 3)  // ID and Address not for real

        let sensor = MCP9808_TemperatureSensor(link: link)

        commands.expect(.i2ctransfer("6 w1@3 0x05 r2@3"))
        commands.expect(.receive("0x1f 0xde\n"))

        let temp = sensor.readTemperature()

        commands.assertExpectedConsumed()
        XCTAssertEqual(temp, -2.125, "expected temperature")
    }

}
