//
//  DataLink.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-04.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Interface to support talking to a connected I^2C device using simple, unidirectional, non-composed reads or writes.
///
/// I^2C devices typically reset their parsing state at the beginning of a conversation; state is discarded
/// when the STOP signal indicates the end of the exchange.
/// Notably, reads are strictly a pull from the device with no mechanism for the clocking node to issue a request first.
///
/// Simple conversations are usually highly typical, with only one format for read actions and one format for writes.
///
/// All reads/writes finish by terminating the message with a STOP.
///
/// `BitStorageCore`-derived objects may assist in coding and decoding.
public protocol DataLink {
    /// Send count bytes to the devlce in a single message.
    func write(data: Data, count: Int)

    /// Read count bytes from the device in a single message.
    func read(data: inout Data, count: Int)


    /// Send and receive bytes in a single I2C conversation.
    ///
    /// Commonly used in patterns like reading from a named register.
    func writeAndRead(sendFrom: Data, sendCount: Int, receiveInto: inout Data, receiveCount: Int)
}

public extension DataLink {
    /// Send all the bytes in data to the device.
    func write(data: Data) {
        write(data: data, count: data.count)
    }

    /// Replace the existing bytes in data with bytes read from the device.
    func read(data: inout Data) {
        read(data: &data, count: data.count)
    }

    func writeAndRead(sendFrom: Data, receiveInto: inout Data) {
          writeAndRead(sendFrom: sendFrom, sendCount: sendFrom.count, receiveInto: &receiveInto, receiveCount: receiveInto.count)
      }

}
