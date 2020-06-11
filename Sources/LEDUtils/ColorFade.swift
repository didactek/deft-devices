//
//  ColorFade.swift
//
//
//  Created by Kit Transue on 2020-06-04.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation


extension LEDColor {
    public func fade(to: LEDColor, count: Int) -> [LEDColor] {
        let start = self.values()
        let goal = to.values()
        let steps = Double(count)
        let delta = zip(start, goal).map { ($0.1 - $0.0) / steps }

        return (0 ..< count).map { index in
            let step = Double(index)
            // modulate results a little
            let rampLevel = sin(2.0 * .pi * step / steps ) / 4 + 0.75
            let vector = zip(start, delta).map { ($0.0 + step * $0.1) * rampLevel }
            return LEDColor(values: vector)
        }
    }
}
