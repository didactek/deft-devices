//
//  LEDColor.swift
//
//
//  Created by Kit Transue on 2020-06-04.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct LEDColor {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// Initialize from HSL color model.
    ///
    /// hue: angle in degrees  between 0 and 360. Red = 0; Green = 120; Blue = 240.
    /// Algorithm from: https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB
    public init(hue: Double, saturation: Double, lightness: Double) {
        let a = saturation * min(lightness, 1 - lightness)
        func k(_ n: Double) -> Double {
            (n + hue / 30).truncatingRemainder(dividingBy: 12.0)
        }
        func f(_ n: Double) -> Double {
            return lightness - a * max(-1, min(k(n) - 3, 9 - k(n), 1))
        }
        self.init(red: f(0), green: f(8), blue: f(4))
    }

    public static func randomSaturated() -> LEDColor {
        let values = [Double.random(in: 0 ... 1.0), 1.0, 0.0,].shuffled()
        return LEDColor(values: values)
    }

    // predefined colors
    public static let white = Self(red: 1.0, green: 1.0, blue: 1.0)
    public static let black = Self(red: 0, green: 0, blue: 0)
    public static let red = Self(red: 1.0, green: 0, blue: 0)
    public static let orange = Self(red: 1.0, green: 0.20, blue: 0.0)
    public static let yellow = Self(red: 1.0, green: 0.5, blue: 0.0)
    public static let green = Self(red: 0, green: 0.8, blue: 0.0)
    public static let blue = Self(red: 0, green: 0, blue: 1.0)
    public static let purple = Self(red: 0.6, green: 0, blue: 0.8)
}

extension LEDColor {
    func values() -> [Double] {
        return [red, green, blue]
    }

    init(values: [Double]) {
        self.init(red: values[0], green: values[1], blue: values[2])
    }
}
