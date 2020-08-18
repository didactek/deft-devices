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
public protocol DataLink {
    /// Send count bytes to the devlce in a single message.
    func write(data: Data)

    /// Read count bytes from the device in a single STOP-terminated message.
    ///
    /// Note: reads via this interface are strictly a pull from the device with no mechanism for the clocking node to issue a request first.
    /// Simple conversations are usually highly typical, with only one format for read actions.
    func read(data: inout Data, count: Int)


    /// Send and receive bytes in a single I2C conversation.
    ///
    /// Commonly used in patterns like reading from a named register.
    func writeAndRead(sendFrom: Data, receiveInto: inout Data, receiveCount: Int)
}

public extension DataLink {
    /// Replace the existing bytes in data with bytes read from the device.
    func read(data: inout Data) {
        read(data: &data, count: data.count)
    }

    /// Send all bytes in sendFrom, then replace existing bytes of receiveInto with a read--all in a single I2C conversation.
    ///
    /// Count of bytes is inferred from the sizes of the passed-in Data blocks.
    ///
    /// Commonly used in patterns like reading from a named register.
    func writeAndRead(sendFrom: Data, receiveInto: inout Data) {
          writeAndRead(sendFrom: sendFrom, receiveInto: &receiveInto, receiveCount: receiveInto.count)
      }

}
