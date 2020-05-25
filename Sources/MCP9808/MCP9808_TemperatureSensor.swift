//
//  MCP9808_TemperatureSensor.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-21.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import DeftBus

public class MCP9808_TemperatureSensor: I2CTraits {
    public static var defaultNodeAddress = 0x18  // base; three lower bits hardware-settable

    let link: DataLink

    public init(link: DataLink) {
        self.link = link
    }

    // FIXME: should I be using UnitTemperature here? I have usability problems with it, since differences are not expressed in Kelvin and thus add badly.
    public func readTemperature() -> Double {
        let command = Data(repeating: 5, count: 1)

        let result = MCP9808_AmbientTemperatureRegister()

        link.writeAndRead(sendFrom: command, receiveInto: &result.storage.bytes)

        return Double(result.temperatureSixteenthCelsius) / 16.0
    }

}
