//
//  main.swift
//  radio
//
//  Created by Kit Transue on 2020-05-01.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

// work with an I2C TEA5767 FM radio module, initially on a Raspberry Pi,
// but potentially on the Mac using a USB MCP2221A breakout.


// rough strategy:
// initialize I2C communications using fopen and ioctl
// communicate using ioctl and fread/fwrite
// options for: tuning a station; (adjusting volume/mute?)

// datasheet at https://www.voti.nl/docs/TEA5767.pdf
// of note:
//  IC address: 110 0000b
//  Structure of the I2C-bus logic: slave transceiver
//  Subaddresses are not used
//  maximum clock frequency of 400 kHz

// Data sequence: address, byte 1, byte 2, byte 3, byte 4 and byte 5 (the data transfer has to be in this order). The Least Significant Bit (LSB) = 0 of the address indicates a WRITE operation to the TEA5767HN.

// standby...

// read/write take place in 5-byte messages. Semantics differ depending on direction

struct Radio {
    let standbyMode = false

    let frequency = 94.9  // to tune to, or starting point for search

    enum TuningMode {
        case search
        case direct
//        case preset  // documentation suggests presets, but is unclear on how they are set; and the computer probably is probably a nicer place to keep those anyway
    }

    enum SearchStopLevel {
        case low
        case medium
        case high
    }
    struct Tuner {
        enum DeemphasisTimeConstant {
            case μs75
            case μs50
        }
        let dtc: DeemphasisTimeConstant = .μs75

        enum PLLRef {
            case mHz6_5
            case disabled
        }
        enum Clock {  // combines PLLRef and XTAL
            case mHz13
            case kHz32_768
            case mHz6_5
        }
        let clock: Clock = .kHz32_768

        enum BandLimits {
            case japan
            case us_europe
        }
        let bandLimits: BandLimits = .us_europe
    }

    struct Audio {
        // byte 1
        let muted = false
        // byte 3
        let forcedMono = false
        let muteRight = false
        let muteLeft = false
        // byte 4
        let softMute = false
        let highCutControl = false
        let stereoNoiseCancelling = false
        let volume = 16 // Int4 "LEV0-3"
    }

    let tuningMode: TuningMode = .direct

    struct Status {  // data obtained with read
        let ready = false
        let bandLimitReached = false
        let stereoTuned = false

    }

}

func pll(mHz frequency: Double) -> (UInt8, UInt8) {
    let intermediateFrequency: Double = 225_000
    let referenceFrequency: Double = 32_768
    let highSideInjection = 4 * (frequency * 1e6 + intermediateFrequency) / referenceFrequency

    let n = Int(highSideInjection)
    let split = n.quotientAndRemainder(dividingBy: 256)
    return (UInt8(split.quotient), UInt8(split.remainder))
}

print(pll(mHz: 100.0))
print(pll(mHz: 94.9))

