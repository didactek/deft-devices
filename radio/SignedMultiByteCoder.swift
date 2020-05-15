//
//  SignedMultiByteCoder.swift
//  radio
//
//  Created by Kit Transue on 2020-05-14.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
//
//class SignedMultiByteCoder: ByteCoder {
//    let unsignedRepresentation: MultiByteCoder
//    let signMask: UInt
//    let signFill: UInt
//
//    var widenedToByte: UInt {
//        get {
//            var raw = unsignedRepresentation.widenedToByte
//            if raw & signMask != 0 {
//                raw |= signFill
//            }
//            return raw
//        }
//        set {
//            var raw = newValue
//            if raw & (1 << (UInt.bitWidth - 1)) != 0 {
//                assert(signFill & raw == signFill, "Raw value \(newValue) will not fit in field starting in byte \(unsignedRepresentation.startIndex + 1)")
//                raw &= ~signFill
//            }
//            unsignedRepresentation.widenedToByte = raw
//        }
//    }
//
//    init(significantByte: Int, msb: Int, minorByte: Int, lsb: Int, storedIn: AssembledMessage) throws {
//        unsignedRepresentation = try MultiByteCoder(significantByte: significantByte, msb: msb, minorByte: minorByte, lsb: lsb, storedIn: storedIn)
//        let width = 8 * (significantByte - minorByte) + msb - lsb
//        signMask = 1 << width
//        let valueMask = (signMask << 1) - 1
//        signFill = ~valueMask
//    }
//}
