//
//  LEDColor.swift
//
//
//  Created by Kit Transue on 2020-06-04.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Model a color as a set of RGB values, each (0.0...1.0).
public struct LEDColor {
    public let red: Double
    public let green: Double
    public let blue: Double

    /// - Parameter red: red value, (0.0...1.0)
    /// - Parameter green: green value, (0.0...1.0)
    /// - Parameter blue: blue value, (0.0...1.0)
    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// Initialize from HSL color model.
    ///
    /// - Parameter hue: Angle in degrees  between 0 and 360. Red = 0; Green = 120; Blue = 240.
    /// - Parameter saturation: Saturation (0.0...1.0).
    /// - Parameter lightness: Lightness, between 0.0 (black) and 1.0 (full brightness).
    ///
    /// Algorithm from: [Wikipedia HSL and HSV](https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB)
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

    /// Factory pattern that returns a random but fully-staturated color.
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
