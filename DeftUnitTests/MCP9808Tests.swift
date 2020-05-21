//
//  MCP9808Tests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-21.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest

class MCP9808Tests: XCTestCase {
    class MockTransport: ShellTransport {
        enum Operation {
            case send(String)
            case receive(String)
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
            case .send(let expectedCommand) :
                XCTAssertEqual(command, expectedCommand)
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
        let link = try! I2CToolsLink(transport: commands, busID: 6, nodeAddress: 3)

        let sensor = MCP9808_TemperatureSensor(link: link)

        commands.expect(.send("i2ctools blah blah"))
        commands.expect(.receive("0x42"))

        let temp = sensor.readTemperature()

        XCTAssertEqual(3.9, temp, "expected temperature")
        commands.assertExpectedConsumed()
    }

}
