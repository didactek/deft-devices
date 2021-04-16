//
//  PlatformSPI.swift
//
//
//  Created by Kit Transue on 2021-04-12.
//  Copyright © 2021 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import DeftBus

// Use an interface based on what Package.swift is configured to use.
#if canImport(FTDI)
import FTDI
import LibUSB
extension FtdiSPI : LinkSPI {
    // no work to do
}
#else
import LinuxSPI
#endif

// FIXME: maybe make this not a global function?
public func platformSPI(speedHz: Int) throws -> LinkSPI {
    #if canImport(FTDI)
    let usbSubsystem = USBBus()
    let ftdiDevice = try usbSubsystem
        .findDevice(idVendor: Ftdi.defaultIdVendor,
                    idProduct: Ftdi.defaultIdProduct)
    let spi = try FtdiSPI(ftdiAdapter: ftdiDevice, speedHz: speedHz)
    print("have SPI")
    #else
    let spi = try LinuxSPI(busID: 0, speedHz: speedHz)
    #endif

    return spi
}
