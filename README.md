# Deft: DEvices from swiFT

A collection of modules for connecting small hardware to computers using the Swift programming language.


## Goals
- provide a framework for connecting small hardware
- maximize call-site readability
- encourage discovery
  - minimize use of external libraries
- avoid any root/sudo access
- exemplify unit-testable design
- support development on Mac and Raspberry Pi devices


## Features

### DeftLayout for formatting messages

DeftLayout is the Deft framework for mapping values of Swift data types to the bit-level positions
used in device protocols. It performs the role of functions like pack/unpack in Ruby or Python, or of
bitwise boolean operations, bitfields, and unions in C.

The DeftLayout pattern tries to minimize the need for raw bit operations, hardcoded masks, and 
other "magic" constants. Its @Position wrappers aspire to adopt positional notation used in 
device datasheets.


### DeftBus I2C+SPI abstraction and hardware support

DeftBus defines protocols for communicating with devices over SPI and I2C.

Deft provides multiple implementations of these protocols:

Using native Linux SPI and native
Linux I2C interfaces.

DeftBus provides an ssh transport that can use command line tools on a remote machine
to perform I2C or SPI operations. Developers can compile and run code on a fast machine
(e.g.: a Mac running Xcode) while still exercising hardware connected to a smaller microcomputer
(e.g.: a Raspberry Pi Zero).


## Installation

On the Raspberry Pi:
1. Install Swift:
    https://github.com/uraimo/buildSwiftOnARM#prebuilt-binaries
1. Enable the I2C interface:
   https://www.raspberrypi.org/documentation/configuration/raspi-config.md
1. Clone this repository


It is possible to work with the codebase using Xcode on a Mac. Xcode provides fast compilation,
sophisticated code completion, and built-in documentation support. Xcode should identify the
directory structure as belonging to a Swift Package and be able to compile and run.


## Usage

Look at DeftExample/main.swift. Adapt as desired.

'swift build' 'swift test' 'swift run'

The tests do not assume any hardware, but use mock objects and data to test the codebase.


## Supporting a new device

### Describe messages

The underlying encoded bytes of the message are represented by an AssembledMessage.

The DeftLayout module provides support for mapping particular bits in AssembledMessage
Data to properties in a message object.


Typical hierarchy for a mapping class:

  BitStorageCore  // manages the AssembledMessage

  [ByteArray]Description // provides @Position wrappers that "make sense" for the representation

  [UserClass]Layout // uses @Position wrappers to add properties of the message


#### Example: a packed, 5-byte message

The TEA5767 radio tuner has only one command, consisting of a write of 5 bytes. Its datasheet
describes the bytes by byte index and bits within the 8-bit byte. The ByteArrayDescription best
supports this longer array with byte-oriented descriptions.

    class TEA5767_WriteLayout: ByteArrayDescription {
        enum SearchStopLevel: UInt8, BitEmbeddable {
            case low = 0b01
            case medium = 0b10
            case high = 0b11
        }
        @Position(ofByte: 3, msb: 6, lsb: 5)
        var searchStopLevel: SearchStopLevel = .high
        // ...
    }

#### Example: a 2-byte message as a big-endian word

The MCP9808 defines a number of different 1- or 2-byte messages. The 2-byte messages are
documented in the datasheet as big-endian words. The WordDescription @Position wrappers 
idiomatically handle positioning bits between 0 and 15 and encode them to bytes with the
expected endian-ness:

    class MCP9808_AmbientTemperatureRegister: WordDescription {
        enum LimitFlag: UInt8, BitEmbeddable {
            case withinLimit = 0
            case outsideLimit = 1
        }
        //...
        @Position(bit: 13)
        var AmbientVsLower: LimitFlag = .withinLimit
    
        @Position(msb: 12, lsb: 0, .extendNegativeBit)
        var temperatureSixteenthCelsius: Int = 0
    }

Because WordDescription describes precisely two bytes (or one word), its @Position structs
do not offer byte or word index/offset.

### Using Message Layouts

For messages to send, set the properties of your layout class to the desired values, then use
the assembled bytes via the `storage` property in the base class to the message to the device.

To read a message, populate the underlying AssembledMessage `storage` with bytes from the
device, then access the properties via the layout class.

### Reading/writing data

Objects typically keep a reference to a DeftBus Link object (I2C or SPI) to use to exchange
bytes with the device.

LinuxI2C and I2CToolsLink are options for provider of LinkI2C services.

Links can be mocked for testing.

### Present a consumer-friendly abstraction of the device

The user of the device class should pass its bus communication method into the object
during intialization. This [dependency injection](https://en.wikipedia.org/wiki/Dependency_injection) 
design pattern makes it easier to test with mock bus links, and makes it easier to use different
links in the future.

For an I2C device, your new class may adopt the `I2CTraits`  protocol, which setup code can
use to find the defaults for devices of this type (bus address, speed, etc.).

Provide a natural interface to the device. The implementation can communicate to the device
using its bus link, using messages transcoded using its Layout classes. The public interface to 
the device may choose to hide the details of this implementation.


## Sample Device Support

- MCP9808 temperature sensor
- TEA5767 FM tuner
- PCA9685 16-channel PWM LED/servo controller
- NormandLED SK9822, a shift-addressable string of RGB LEDs using SPI


## Remote I2C access

SSHTransport lets the library sent I2C commands to i2c-tools (specifically: i2ctransfer) over an
ssh session. This allows all the Swift code be be developed/run on a large computer while
talking to devices connected to the I2C bus on a Raspberry Pi.


## Issues

The Swift 5.1 compiler will crash if more than one property wrapper structure is defined in the application
with the same name, even when those structures are defined within the scope of different classes.

This appears fixed in 5.2, but Swift binaries are not yet available for the RPi.

There is a "swift-5.1" branch that pares down the sample application to a single BitStorageCore
subclass, and thus avoids this problem for demonstration purposes.


## Resources

The open-source [sigrok PulseView](https://sigrok.org/wiki/PulseView) with a low-cost USB
logic analyzer makes a very effective and very low-cost system for viewing and decoding bus
operations. Highly recommended.
