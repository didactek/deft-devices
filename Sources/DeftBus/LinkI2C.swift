//
//  LinkI2C.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Interface to support talking to a connected I^2C device.
///
/// I^2C devices typically reset their parsing state at the beginning of a conversation; state is discarded
/// when the STOP signal indicates the end of the exchange.
///
/// Each operation here finishes by terminating the conversation with a STOP.
///
/// `BitStorageCore`-derived objects may assist in coding and decoding `Data` arguments.
public protocol LinkI2C {
    /// Send  bytes to the devlce in a single message.
    ///
    /// - Parameter data: The body of the message.
    ///
    /// - Note: The control byte is added by the transport; it should not be part of `data`.
    /// - Note: This terminates the conversation with a STOP.
    func write(data: Data) throws

    /// Read from the device in a single STOP-terminated conversation.
    ///
    /// - Parameter count: number of bytes to read from the device.
    ///
    /// - Note: Reads via this interface are strictly a pull from the device with no mechanism for the clocking node to issue a request first.
    /// Simple conversations are usually highly typical, with only one format for read actions.
    func read(count: Int) throws -> Data


    /// Send and receive bytes in a single I2C conversation.
    ///
    /// Commonly used in patterns like reading from a named register.
    /// - Parameter sendFrom: Data to be sent.
    /// - Parameter receiveCount: Number of bytes to read from the bus after sending.
    /// - Returns: Bytes read from the device.
    func writeAndRead(sendFrom: Data, receiveCount: Int) throws -> Data

    /// Report whether the bus adapter and software driver support clock stretching.
    ///
    /// See [UM10204: I2C-bus specification and user manual](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)
    /// Section 3.1.9  Clock stretching.
    ///
    /// In its ready state, the I2C clock is held low by the coordinator. When the coordinator is ready to send
    /// data, it releases the clock line, which would normally get pulled high by the bias resistors on the bus.
    /// If a device is not ready to process input, it may hold the clock line low until it is ready, preventing the
    /// clock signal from appearing on the bus and signalling to the coordinator that data is not being transferred.
    ///
    /// If a driver that does not support clock stretching is talking with a device that uses it for flow control,
    /// a few techniques might reduce the application of clock stretching to the point the device is usable:
    /// - reduce bus speed
    /// - add delays after operations (like configuration, reset) that will take time for the device to complete
    func supportsClockStretching() -> Bool
}

public extension LinkI2C {
    /// Replace the existing bytes in data with bytes read from the device.
    ///
    /// - Parameter data: Existing bytes that should be replaced with new data from the device.
    func read(data: inout Data) throws {
        data = try read(count: data.count)
    }

    /// Send all bytes in sendFrom, then replace existing bytes of receiveInto with a read--all in a single I2C conversation.
    ///
    /// Count of bytes is inferred from the sizes of the passed-in Data blocks.
    ///
    /// Commonly used in patterns like reading from a named register.
    func writeAndRead(sendFrom: Data, receiveInto: inout Data) throws {
        let count = receiveInto.count
        receiveInto = try writeAndRead(sendFrom: sendFrom, receiveCount: count)
    }

    /// Check that the device is on the bus and responding.
    /// - parameter strategy: Pattern to use for checking device presence
    /// - throws If device is not responsing
    func ping(strategy: PresenceQuery) throws -> Self {
        switch strategy {
        case .doNotPing:
            break
//            fatalError("Ping requested, but ping should not be used with this device")
        case .quickWrite:
            try write(data: Data())
        case .readByte:
            let _ = try read(count: 1)
        }
        return self
    }
}
