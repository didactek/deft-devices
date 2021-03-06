//
//  SSHLink.swift
//  Deft -- DEvices from swiFT
//
//  Created by Kit Transue on 2020-05-16.
//  Copyright © 2020 Kit Transue.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Executes commands over an ssh session.
@available(OSX 10.15, *)
public class SSHTransport: ShellTransport {
    // FIXME: should have timeouts on read and close...

    var commandPipe: FileHandle
    var receivePipe: FileHandle
    var process: Process

    public init(destination: String) {
        let executable = URL(fileURLWithPath: "/usr/bin/ssh")

        process = Process()
        process.executableURL = executable
        process.arguments = [ destination ]

        let outgoing = Pipe()  // FIXME: hope that filehandles are not weak references to the pipe
        process.standardInput = outgoing.fileHandleForReading
        commandPipe = outgoing.fileHandleForWriting

        let incoming = Pipe()
        process.standardOutput = incoming.fileHandleForWriting
        receivePipe = incoming.fileHandleForReading

        try! process.run()

        // throw away the login/motd message
        let _ = receivePipe.availableData
    }

    // Documented in ShellTransport protocol
    public func send(_ command: String) {
        let terminatedCommand = command.appending("\n")
        commandPipe.write(terminatedCommand.data(using: .ascii)!)
    }

    /// Read whatever is available from the pipe. Will wait until sender has flushed *some* data.
    public func receive() -> String {
        return String(data: receivePipe.availableData, encoding: .ascii)!
    }

    deinit {
        try? commandPipe.close()
//        process.terminate() // should probably give a timeout for waitUntilExit and then call this
        process.waitUntilExit()
    }
}
