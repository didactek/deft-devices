//
//  ShellTransport.swift
//  radio
//
//  Created by Kit Transue on 2020-05-17.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol ShellTransport {
    func send(_ command: String)
    func receive() -> String
}
