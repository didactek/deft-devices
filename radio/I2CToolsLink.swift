//
//  I2CToolsLink.swift
//  radio
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

class I2CToolsLink: DataLink {
    let busID: Int
    let nodeAddress: Int
    let transport: ShellTransport

    enum RangeError: Error {
        case unsafeDeviceAddress  // potential system devices: RAM controllers and the like
    }
    init(transport: ShellTransport, busID: Int, nodeAddress: Int) throws {
        guard nodeAddress > 0x02 && nodeAddress < 0x78 else {
            throw RangeError.unsafeDeviceAddress
        }
        self.busID = busID
        self.nodeAddress = nodeAddress
        self.transport = transport
    }

    override func write(data: Data, count: Int) {
        assert(count >= 0)
        assert(count <= data.count)

        let hexFormattedBytes = data.prefix(count).map{ String(format: "0x%02x", $0) }.joined(separator: " ")
        let command = "/usr/sbin/i2ctransfer -y \(busID) w\(count)@\(nodeAddress) \(hexFormattedBytes)"
        transport.send(command)
    }

    override func read(data: inout Data, count: Int) {
        assert(count >= 0)
        if (data.count < count) {
            let shortfall = count - data.count
            data.append(contentsOf: [UInt8](repeating: 0, count: shortfall))
        }
        let command = "/usr/sbin/i2ctransfer -y \(busID) r\(count)@\(nodeAddress)"
        transport.send(command)

        var resultsText = transport.receive() // expected to be series of hex encoded bytes, e.g. "0xaf 0xca 0x3a 0x30"
        assert(resultsText.removeLast() == "\n")
        let hexEncoded = resultsText.split(separator: " ")
        assert(hexEncoded.count == count, "output \(resultsText) does not include expected \(count) items")

        for i in 0 ..< count {
            var hex = hexEncoded[i]
            assert(hex.removeFirst() == "0")
            assert(hex.removeFirst() == "x")
            data[i] = UInt8(hex, radix: 16)!
        }
    }
}
