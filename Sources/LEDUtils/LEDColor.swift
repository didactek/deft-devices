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

    public static func randomSaturated() -> LEDColor {
        let values = [Double.random(in: 0 ... 1.0), 1.0, 0.0,].shuffled()
        return LEDColor(values: values)
    }
}

extension LEDColor {
    func values() -> [Double] {
        return [red, green, blue]
    }

    init(values: [Double]) {
        self.init(red: values[0], green: values[1], blue: values[2])
    }
}
