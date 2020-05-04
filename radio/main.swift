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



print(TEA5767_Radio.pll(mHz: 100.0))
print(TEA5767_Radio.pll(mHz: 94.9))

var printingLink = DataLink()
var radio = TEA5767_Radio(link: printingLink)
radio.flush()
