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

/// Class for communicating with a Microchip MCP 9808 temperature sensor.
public class MCP9808_TemperatureSensor: I2CTraits {
    public static var defaultNodeAddress = 0x18  // base; three lower bits hardware-settable
    public static var presenceStrategy: PresenceQuery = .readByte

    let link: LinkI2C

    public init(link: LinkI2C) {
        self.link = link
    }

    /// Read the current temperature in degrees Celsius.
    public var temperature: Double { get {
        // Foundation provides a UnitTemperature that could have been returned instead.
        // It has the great advantage that it values include their units, which would
        // be more self-documenting. But for units that don't start at zero (Celsius
        // and Farenheit, unlike Kelvin), differences are encoded from nominally
        // zero which makes for lots of bugs. Surprisingly, a unit-less Double seems safer.
        let command = MCP9808_PointerRegister()
        command.command = .temperature

        let result = MCP9808_AmbientTemperatureRegister()

        try! link.writeAndRead(sendFrom: command.storage.bytes, receiveInto: &result.storage.bytes)

        return Double(result.temperatureSixteenthCelsius) / 16.0
        }
    }

}
