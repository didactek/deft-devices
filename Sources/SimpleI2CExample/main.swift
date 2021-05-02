//
//  main.swift
//
//
//  Created by Kit Transue on 2020-09-01.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

// utilities
import DeftBus

// interfaces
#if canImport(FTDI)
import FTDI
import PortableUSB
extension FtdiI2CDevice : LinkI2C {
    // no work to do
}
#else
import LinuxI2C
#endif

// the device:
import PCA9685

do {
    #if canImport(FTDI)
    let usbSubsystem = PortableUSB.platformBus()
    let ftdiDevice = try! usbSubsystem
        .findDevice(idVendor: Ftdi.defaultIdVendor,
                    idProduct: Ftdi.defaultIdProduct)
    let bus = try! FtdiI2C(ftdiAdapter: ftdiDevice, overrideClockHz: 10_000)
    let i2c = try! FtdiI2CDevice(busHost: bus, nodeAddress: PCA9685.baseAddress)
    #else
    let i2c = try! LinuxI2C(busId: 0, nodeAddress: PCA9685.baseAddress)
    #endif

    let servos = PCA9685(link: i2c)

    let swingTime = 1.5
    #if true  // IMPORTANT: FIGURE SERVO LIMITS FIRST TO AVOID SERVO DAMAGE
    let servoSafeZoneMin = 0.3
    let servoSafeZoneMax = 0.7
    let channel = 15
    servos.set(channel: channel, value: servoSafeZoneMin)
    Thread.sleep(forTimeInterval: swingTime)

    servos.set(channel: channel, value: 0.5)
    Thread.sleep(forTimeInterval: swingTime)

    servos.set(channel: channel, value: servoSafeZoneMax)
    Thread.sleep(forTimeInterval: swingTime)

    servos.set(channel: channel, value: 0.5)
    Thread.sleep(forTimeInterval: swingTime)

    servos.set(channel: channel, value: servoSafeZoneMin)
    Thread.sleep(forTimeInterval: swingTime)

    servos.set(channel: channel, value: 0.5)
    #endif
}

