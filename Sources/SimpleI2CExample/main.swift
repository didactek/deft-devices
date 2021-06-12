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
import DeftLog
import PlatformSPI
//import DeftBus

// the device:
import PCA9685

do {
    DeftLog.settings = [
        ("com.didactek", .debug),
    ]

    let i2c = try! PlatformDeviceBroker.shared.findI2C(usingDefaultsFor: PCA9685.self)

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

