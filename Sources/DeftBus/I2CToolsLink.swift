//
//  I2CToolsLink.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// A class that executes I2C operations using Linux i2c-tools package commands from a shell.
public class I2CToolsLink: LinkI2C {

    let busID: Int
    let nodeAddress: Int
    let transport: ShellTransport

    enum RangeError: Error {
        case unsafeDeviceAddress  // potential system devices: RAM controllers and the like
    }

    /// Parameter transport: Connection to shell to use to issue commands and read their output.
    /// Parameter busID: the I2C bus to which the device is attached.
    /// Parameter nodeAddress: the device address of the node. Only 7-bit addresses are supported.
    public init(transport: ShellTransport, busID: Int, nodeAddress: Int) throws {
        guard nodeAddress > 0x02 && nodeAddress < 0x78 else {
            throw RangeError.unsafeDeviceAddress
        }
        self.busID = busID
        self.nodeAddress = nodeAddress
        self.transport = transport
    }

    func transferWriteFragment(data: Data) -> String {
        let hexFormattedBytes = data.map{ String(format: "0x%02x", $0) }.joined(separator: " ")
        return "w\(data.count)@\(nodeAddress) \(hexFormattedBytes)"
    }

    func transferPrologue() -> String {
        return "/usr/sbin/i2ctransfer -y \(busID)"
    }

    func readCommand(count: Int) -> String {
        assert(count >= 0)
        return "r\(count)@\(nodeAddress)"
    }

    func readResults(count: Int) -> Data {
        var data = Data()
        var resultsText = transport.receive() // expected to be series of hex encoded bytes, e.g. "0xaf 0xca 0x3a 0x30"
        assert(resultsText.removeLast() == "\n")
        let hexEncoded = resultsText.split(separator: " ")
        assert(hexEncoded.count == count, "output \(resultsText) does not include expected \(count) items")

        for hex in hexEncoded {
            assert(hex.count > 2)
            assert(hex.prefix(2) == "0x")
            data.append(UInt8(hex.dropFirst(2), radix: 16)!)
        }
        return data
    }

    public func write(data: Data) {
        let command = transferPrologue() + " " + transferWriteFragment(data: data)
        transport.send(command)
    }

    public func read(count: Int) -> Data {
        let command = transferPrologue() + " " + readCommand(count: count)
        transport.send(command)
        return readResults(count: count)
    }

    public func writeAndRead(sendFrom: Data, receiveCount: Int) -> Data {
        let command = transferPrologue() + " " +
            transferWriteFragment(data: sendFrom) + " " +
            readCommand(count: receiveCount)
        transport.send(command)
        return readResults(count: receiveCount)
    }
}
