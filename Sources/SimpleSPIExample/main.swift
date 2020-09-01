//
//  main.swift
//
//
//  Created by Kit Transue on 2020-08-14.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

// utilities
import DeftBus
import LEDUtils

// interfaces
#if canImport(FTDI)
import FTDI
import LibUSB
extension FtdiSPI : LinkSPI {
    // no work to do
}
#else
import LinuxSPI
#endif

// the device:
import ShiftLED

do {
    #if canImport(FTDI)
    let usbSubsystem = USBBus()
    let ftdiDevice = try! usbSubsystem
        .findDevice(idVendor: Ftdi.defaultIdVendor,
                    idProduct: Ftdi.defaultIdProduct)
    let spi = try! FtdiSPI(ftdiAdapter: ftdiDevice, speedHz: 1_000_000)
    #else
    let spi = try! LinuxSPI(busID: 0, speedHz: 30_500)
    #endif

    let ledCount = 73
    let leds = ShiftLED(bus: spi, stringLength: ledCount, current: 0.05)

    leds.clear()
    leds.all(color: .blue)
    leds[ledCount / 2] = .red
    leds.flushUpdates()

    sleep(5)
    leds.clear()
}

