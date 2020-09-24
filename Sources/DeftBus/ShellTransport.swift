//
//  ShellTransport.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-17.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Protocol for executing a command-line processes using a [possibly-remote] shell and reading its output.
public protocol ShellTransport {
    /// Submit a command to the shell for parsing arguments and executing.
    func send(_ command: String)
    /// Collect all the available command-line output.
    func receive() -> String
}
