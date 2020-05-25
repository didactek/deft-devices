import Foundation
import Glibc

import DeftBus
import LinuxI2CDev

/// See: https://www.kernel.org/doc/Documentation/i2c/dev-interface
public class LinuxI2C: DataLink {
    let file: Int32

    enum RangeError: Error {
        case unsafeDeviceAddress  // potential system devices: RAM controllers and the like
    }

    public init(busID: Int, nodeAddress: Int) throws {
        guard nodeAddress > 0x02 && nodeAddress < 0x78 else {
            throw RangeError.unsafeDeviceAddress
        }
        file = open("/dev/i2c-\(busID)", O_RDWR)
        ioctl(file, UInt(I2C_SLAVE), CInt(nodeAddress))
    }

    public func write(data: Data, count: Int) {
        data.withUnsafeBytes() { ptr in
	    SwiftGlibc.write(file, ptr.baseAddress, count)
	}
    }

    public func read(data: inout Data, count: Int) {
        data.withUnsafeMutableBytes() { ptr in
	    let bytes_read = SwiftGlibc.read(file, ptr.baseAddress, count)
	    assert(bytes_read == count) // FIXME: more elegant...
        }
    }

    public func writeAndRead(sendFrom: Data, sendCount: Int, receiveInto: inout Data, receiveCount: Int) {
    // FIXME:
    //ioctl(file, I2C_RDWR, struct i2c_rdwr_ioctl_data *msgset)...
    }
}

