#if true
import Foundation
#if !os(macOS)
import Glibc
let systemWrite = SwiftGlibc.write
let systemRead = SwiftGlibc.read
#else
import Darwin
let systemWrite = Darwin.write
let systemRead = Darwin.read
#endif


import DeftBus
import LinuxI2CDev

/// An implementation of `DataLink` (I2C) using Linux's userland /dev/i2c-* interface.
///
/// This userland interface does not require any root/sudo permissions to use.
///
/// Most of the interface is documented in the header files included from LinuxI2CDev/I2CUmbrella.h. For additional discussion, see https://www.kernel.org/doc/Documentation/i2c/dev-interface
public class LinuxI2C: DataLink {
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

        fileDescriptor = open("/dev/i2c-\(busID)", O_RDWR)
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

    public func write(data: Data, count: Int) {
        let writtenCount = data.withUnsafeBytes() { ptr in
            systemWrite(fileDescriptor, ptr.baseAddress, count)
        }
        assert(writtenCount == count)
    }

    public func read(data: inout Data, count: Int) {
        let receivedCount = data.withUnsafeMutableBytes() { ptr in
            systemRead(fileDescriptor, ptr.baseAddress, count)
        }
        assert(receivedCount == count)
    }

    public func writeAndRead(sendFrom: Data, sendCount: Int, receiveInto: inout Data, receiveCount: Int) {
        var sendCopy = sendFrom  // won't be written to, but ioctl signature allows writing, and having semantics dependent on flags makes this hard to prove. Use a copy so the compiler is rightfully happy about safety.
        sendCopy.withUnsafeMutableBytes { sendRaw in
            receiveInto.withUnsafeMutableBytes { recvRaw in
                let sendBuffer = sendRaw.bindMemory(to: __u8.self)
                let sendMsg = i2c_msg(
                    addr: __u16(nodeAddress),
                    flags: __u16(0),   // write is the default (no flags set)
                    len: __u16(sendCount),
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
    }
}
#endif
