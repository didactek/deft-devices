#if true
import Foundation
#if !os(macOS)
import Glibc
#else
import Darwin
#endif
let systemWrite = write
let systemRead = read


import DeftBus
import LinuxI2CDev

/// See: https://www.kernel.org/doc/Documentation/i2c/dev-interface
public class LinuxI2C: DataLink {
    let file: Int32
    let nodeAddress: Int

    enum RangeError: Error {
        case unsafeDeviceAddress  // potential system devices: RAM controllers and the like
    }

    public init(busID: Int, nodeAddress: Int) throws {
        guard nodeAddress > 0x02 && nodeAddress < 0x78 else {
            throw RangeError.unsafeDeviceAddress
        }
        file = open("/dev/i2c-\(busID)", O_RDWR)
        ioctl(file, UInt(I2C_SLAVE), CInt(nodeAddress))

        self.nodeAddress = nodeAddress
    }

    deinit {
        close(file)
    }

    public func write(data: Data, count: Int) {
        data.withUnsafeBytes() { ptr in
            systemWrite(file, ptr.baseAddress, count)
        }
    }

    public func read(data: inout Data, count: Int) {
        data.withUnsafeMutableBytes() { ptr in
            let bytes_read = systemRead(file, ptr.baseAddress, count)
            assert(bytes_read == count) // FIXME: more elegant...
        }
    }

    public func writeAndRead(sendFrom: Data, sendCount: Int, receiveInto: inout Data, receiveCount: Int) {
        var sendCopy = sendFrom  // won't be written, but ioctl flags make this hard to prove. Use a copy.
        sendCopy.withContiguousMutableStorageIfAvailable { sendBuffer in
            receiveInto.withContiguousMutableStorageIfAvailable { recvBuffer in
                var sendMsg = i2c_msg()
                sendMsg.addr = __u16(nodeAddress)
                sendMsg.buf = sendBuffer.baseAddress
                sendMsg.flags = 0 // write
                sendMsg.len = __u16(sendCount)

                var recvMsg = i2c_msg()
                recvMsg.addr = __u16(nodeAddress)
                recvMsg.buf  = recvBuffer.baseAddress
                recvMsg.flags = __u16(I2C_M_RD)
                recvMsg.len = __u16(receiveCount)

                var conversation = [sendMsg, recvMsg]
                conversation.withContiguousMutableStorageIfAvailable { messages in
                    var callInfo = i2c_rdwr_ioctl_data(msgs: messages.baseAddress, nmsgs: __u32(messages.count))
                    ioctl(file, UInt(I2C_RDWR), &callInfo)
                }

            }
        }
    }
}
#endif
