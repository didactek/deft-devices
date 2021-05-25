//
//  LinuxSPI.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-30.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

#if false  // Not compiled by default; see following note.
// - Note: Swift (as of 5.4) does not bridge macros in <linux/spi/spidev.h> that are needed
// for the ioctl operations to use the /dev/spi interface. The text of these macros
// in this file must be replaced with hardcoded values.
// The values may be obtained by compiling and running this short C program:

//    #include <stdio.h>
//    #include <linux/spi/spidev.h>
//
//    #define PRINT(x) printf("let %s = %lu\n", #x, x)
//
//    int main() {
//        PRINT(SPI_IOC_WR_MODE);
//        PRINT(SPI_IOC_WR_MAX_SPEED_HZ);
//        PRINT(SPI_IOC_MESSAGE(1));
//
//        return 0;
//    }


#if !os(macOS)
import Foundation

import DeftBus
import LinuxSPIDev

import Glibc  // or Darwin, if testing compilation on macOS


public class LinuxSPI: LinkSPI {
    let fileDescriptor: Int32

    enum SPIError: Error {
        case descriptorNotFound
        case clockSetupFailure
        case speedSetupFailure
    }

    public init(busID: Int, speedHz: Int) throws {
        let specialName = "/dev/spidev\(busID).1"
        fileDescriptor = open(specialName, O_RDWR)
        guard fileDescriptor >= 0 else {
            throw SPIError.descriptorNotFound
        }

        var mode: UInt8 = 0  // rising clock
        let modeResult = ioctl(fileDescriptor, UInt(SPI_IOC_WR_MODE), &mode)
        guard modeResult == 0 else {
            throw SPIError.clockSetupFailure
        }

        var speed: UInt32 = UInt32(speedHz)
        let speedResult = ioctl(fileDescriptor, UInt(SPI_IOC_WR_MAX_SPEED_HZ), &speed);
        guard speedResult == 0 else {
            throw SPIError.speedSetupFailure
        }
    }

    deinit {
        close(fileDescriptor)
    }

    // Documented in protocol
    public func write(data: Data) {
        var dataCopy = data
        dataCopy.withUnsafeMutableBytes { dataRaw in
            let addressAsInt = UInt(bitPattern: dataRaw.baseAddress)
            var message = spi_ioc_transfer(tx_buf: __u64(addressAsInt), rx_buf: 0, len: __u32(dataRaw.count), speed_hz: 0, delay_usecs: 0, bits_per_word: 0, cs_change: 0, tx_nbits: 0, rx_nbits: 0, pad: 0)
            let sendResult = ioctl(fileDescriptor, SPI_IOC_MESSAGE(1), &message)
            //assert(sendResult == 0)  // never a confirmation on send.
        }
    }

}
#endif
#endif
