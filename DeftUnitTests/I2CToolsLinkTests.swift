//
//  I2CToolsLinkTests.swift
//  DeftUnitTests
//
//  Created by Kit Transue on 2020-05-14.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest

class DummyTransport: ShellTransport {
    func send(_ command: String) {
        abort()
    }

    func receive() -> String {
        abort()
    }
}

class I2CToolsLinkTests: XCTestCase {
    let transport = DummyTransport()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDeviceAddressRangeSafety() throws {
        XCTAssertThrowsError(try I2CToolsLink.init(transport: transport, busID: 1, nodeAddress: 0x00) , "unsafe I2C address")
        XCTAssertThrowsError(try I2CToolsLink.init(transport: transport, busID: 1, nodeAddress: 0x01) , "unsafe I2C address")
        XCTAssertThrowsError(try I2CToolsLink.init(transport: transport, busID: 1, nodeAddress: 0x02) , "unsafe I2C address")
        XCTAssertThrowsError(try I2CToolsLink.init(transport: transport, busID: 1, nodeAddress: 0x78) , "unsafe I2C address")
        XCTAssertThrowsError(try I2CToolsLink.init(transport: transport, busID: 1, nodeAddress: 0x79) , "unsafe I2C address")
        XCTAssertThrowsError(try I2CToolsLink.init(transport: transport, busID: 1, nodeAddress: -1) , "unsafe I2C address")
        XCTAssertThrowsError(try I2CToolsLink.init(transport: transport, busID: 1, nodeAddress: 65537) , "unsafe I2C address")


        XCTAssertNoThrow(try I2CToolsLink.init(transport: transport, busID: 1, nodeAddress: 0x03) , "safe I2C address")
        XCTAssertNoThrow(try I2CToolsLink.init(transport: transport, busID: 1, nodeAddress: 0x77) , "safe I2C address")

    }
}
