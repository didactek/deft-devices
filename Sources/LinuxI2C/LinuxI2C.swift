//
//  LinuxI2C.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-26.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

#if !os(macOS) // **For the whole file** (Use 'true' if using stubs below to use macOS to check compilation only.)

import Foundation
#if !os(macOS)
import Glibc
let systemWrite = SwiftGlibc.write
let systemRead = SwiftGlibc.read
#else
// macOS only for compile-time checks:
import Darwin
let systemWrite = Darwin.write
let systemRead = Darwin.read
// stubs of ioctl pieces. Can add something like this in the macOS section of I2CUmbrella.h...
//   #include "linux-stubs/include/linux/types.h"
//   #include "linux-stubs/include/linux/i2c.h"
//   #include "linux-stubs/include/linux/i2c-dev.h"
// ... or provide equivalent dummy definitions here:
#if false // these are stubs and won't work, but can be enabled for checking compile:
let I2C_SLAVE = 44
let I2C_M_RD = 1
let I2C_RDWR = 3
typealias __u32 = UInt32
typealias __u16 = UInt16
typealias __u8 = UInt8
struct i2c_msg {
    var addr: __u16
    var flags: __u16
    var len: __u16
    var buf: UnsafePointer<__u8>?
}
struct i2c_rdwr_ioctl_data {
    var msgs: UnsafePointer<i2c_msg>?
    var nmsgs: __u32
}
#endif // stubs
#endif


import DeftBus
import LinuxI2CDev

/// An implementation of `LinkI2C` (I2C) using Linux's userland /dev/i2c-* interface.
///
/// This userland interface does not require any root/sudo permissions to use.
///
/// Most of the interface is documented in the header files included from LinuxI2CDev/I2CUmbrella.h.
/// See [kernel.org I2C dev interface](https://www.kernel.org/doc/Documentation/i2c/dev-interface)
public class LinuxI2C: LinkI2C {
    let fileDescriptor: Int32
    let nodeAddress: Int

    enum I2CError: Error {
        case unsafeDeviceAddress  // potential system devices: RAM controllers and the like
        case descriptorNotFound
        case addressBindingFailed
    }

    public init(busID: Int, nodeAddress: Int) throws {
        guard nodeAddress > 0x02 && nodeAddress < 0x78 else {
            throw I2CError.unsafeDeviceAddress
        }
        self.nodeAddress = nodeAddress

        fileDescriptor = open("/dev/i2c-\(busID)", O_RDWR) // released in deinit
        guard fileDescriptor >= 0 else {
            throw I2CError.descriptorNotFound
        }

        let resultCode = ioctl(fileDescriptor, UInt(I2C_SLAVE), CInt(nodeAddress))
        guard resultCode == 0 else {
            throw I2CError.addressBindingFailed
        }
    }

    deinit {
        close(fileDescriptor)
    }

    // Documented in protocol
    public func supportsClockStretching() -> Bool {
        return true
    }

    // Documented in protocol
    public func write(data: Data) {
        let count = data.count
        let writtenCount = data.withUnsafeBytes() { ptr in
            systemWrite(fileDescriptor, ptr.baseAddress, count)
        }
        assert(writtenCount == count)
    }

    // Documented in protocol
    public func read(count: Int) -> Data {
        var data = Data(repeating: 0, count: count)
        let receivedCount = data.withUnsafeMutableBytes() { ptr in
            systemRead(fileDescriptor, ptr.baseAddress, count)
        }
        assert(receivedCount == count)
        return data
    }

    // Documented in protocol
    public func writeAndRead(sendFrom: Data, receiveCount: Int) -> Data {
        var receiveInto = Data(repeating: 0, count: receiveCount)
        var sendCopy = sendFrom  // won't be written to, but ioctl signature allows writing, and having semantics dependent on flags makes this hard to prove. Use a copy so the compiler is rightfully happy about safety.
        sendCopy.withUnsafeMutableBytes { sendRaw in
            receiveInto.withUnsafeMutableBytes { recvRaw in
                let sendBuffer = sendRaw.bindMemory(to: __u8.self)
                let sendMsg = i2c_msg(
                    addr: __u16(nodeAddress),
                    flags: __u16(0),   // write is the default (no flags set)
                    len: __u16(sendFrom.count),
                    buf: sendBuffer.baseAddress)

                let recvBuffer = recvRaw.bindMemory(to: __u8.self)
                let recvMsg = i2c_msg(
                    addr: __u16(nodeAddress),
                    flags: __u16(I2C_M_RD),
                    len: __u16(receiveCount),
                    buf: recvBuffer.baseAddress)

                var conversation = [sendMsg, recvMsg]
                conversation.withUnsafeMutableBufferPointer { messages in
                    var callInfo = i2c_rdwr_ioctl_data(msgs: messages.baseAddress, nmsgs: __u32(messages.count))
                    let receivedCount = ioctl(fileDescriptor, UInt(I2C_RDWR), &callInfo)
                    assert(receivedCount == receiveCount)
                }
            }
        }
        return receiveInto
    }
}
#endif
