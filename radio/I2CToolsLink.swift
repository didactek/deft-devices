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

    func transferWriteFragment(data: Data, count: Int) -> String {
        assert(count >= 0)
        assert(count <= data.count)

        let hexFormattedBytes = data.prefix(count).map{ String(format: "0x%02x", $0) }.joined(separator: " ")
        return "w\(count)@\(nodeAddress) \(hexFormattedBytes)"
    }

    func transferPrologue() -> String {
        return "/usr/sbin/i2ctransfer -y \(busID)"
    }

    func prepareReadFragment(data: inout Data, count: Int) -> String {
        assert(count >= 0)
        if (data.count < count) {
            let shortfall = count - data.count
            data.append(contentsOf: [UInt8](repeating: 0, count: shortfall))
        }
        return "r\(count)@\(nodeAddress)"
    }

    func readResults(data: inout Data, count: Int) {
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

    func write(data: Data, count: Int) {
        let command = transferPrologue() + " " + transferWriteFragment(data: data, count: count)
        transport.send(command)
    }

    func read(data: inout Data, count: Int) {
        let command = transferPrologue() + " " + prepareReadFragment(data: &data, count: count)
        transport.send(command)
        readResults(data: &data, count: count)
    }

    func writeAndRead(sendFrom: Data, sendCount: Int, receiveInto: inout Data, receiveCount: Int) {
        let command = transferPrologue() + " " +
            transferWriteFragment(data: sendFrom, count: sendCount) + " " +
            prepareReadFragment(data: &receiveInto, count: receiveCount)
        transport.send(command)
        readResults(data: &receiveInto, count: receiveCount)
    }
}
