# SwiftFlowMeter
A Swift library for using Hall effect based water flow sensors.

<p>
<img src="https://img.shields.io/badge/Architecture%20-ARMv6%20%7C%20%20ARMv7%2F8-red.svg"/>
<img src="https://img.shields.io/badge/OS-Raspbian%20%7C%20Debian%20%7C%20Ubuntu-yellow.svg"/>
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Swift-5x-brightgreen.svg"/></a>
<a href="https://raw.githubusercontent.com/samco182/SwiftFlowMeter/master/LICENSE"><img src="https://img.shields.io/badge/Licence-MIT-blue.svg" /></a>
</p>
<img src="https://www.fluxworkshop.info/images/product/BDAA100184_1%20-%2030lpm%20Water%20Flow%20Black_1.JPG" height="300" width="300">

## Summary  
This is a [SwiftyGPIO](https://github.com/uraimo/SwiftyGPIO) built on library for using [Hall effect](https://en.wikipedia.org/wiki/Hall_effect) based water flow sensors.

You will be able to read, via GPIO pin, the current flow rate per second and read the total volume flowed per requested time.

## Working Principle
<p align="center">
<img src="http://www.theorycircuit.com/wp-content/uploads/2017/11/how-water-flow-sensor-works-1024x554.png" height="277" width="512">
</p>

The illustration above gives a detailed working explanation of Hall effect based water flow sensors: a turbine wheel embedded with a magnet is placed in a closed case along with a Hall effect sensor. When water flows through the pipe, it makes the turbine wheel rotate and hence the magnet flux interferes the Hall sensor. The rate of interference depends directly on water flow rate, so the Hall effect sensor produces a pulse signal output. This pulse output can be transformed to water volume passed through the pipe per minute.

Hall effect based water flow sensors can provided by different manufacturers, but they all follow the same working principle. So, what makes them different? The formula that describes the sensor's pulse frequency transformation to flow rate.

The formula usually follows the form of:

<p align="center">
<img src="https://render.githubusercontent.com/render/math?math=F=k*Q" height="20">
</p>

Where:
- **F**: Pulse frequency in *1/s*
- **k**: Pulses per second per unit of measure *(1/s)/(l/min)*
- **Q**: Flow rate in *l/min*

## Hardware Details  
The sensor should be powered using **5V**. 

The Raspberry Pi’s GPIO pins operate at **3.3V** :warning:, and since the output signal from the water flow sensor comes at 5V, you will need to use a voltage divider in order to bring it down to **3.3V**. If you don't do this, you might burn out the GPIO pin! :boom:.
<p align="center">
<img src="https://github.com/samco182/SwiftFlowMeter/blob/develop/VoltageDivider.jpg?raw=true" height="350" width="350">
</p>

## Supported Boards
Every board supported by [SwiftyGPIO](https://github.com/uraimo/SwiftyGPIO): RaspberryPis, BeagleBones, C.H.I.P., etc...

To use this library, you'll need a Linux ARM board running [Swift 5.x](https://github.com/uraimo/buildSwiftOnARM) 🚗.

The example below will use a Raspberry Pi 3B+  board, but you can easily modify the example to use one of the other supported boards. A full working demo project for the RaspberryPi3B+ is available in the **Example** directory.

## Installation
First of all, make sure your board is running **Swift 5.x** ⚠️!

Since Swift 5.x supports Swift Package Manager, you only need to add SwiftFlowMeter as a dependency in your project's `Package.swift` file:

```swift
let package = Package(
    name: "MyProject",
    dependencies: [
        .package(url: "https://github.com/samco182/SwiftFlowMeter", .branch("next-release")),
    ]
    targets: [
        .target(
            name: "MyProject", 
            dependencies: ["SwiftFlowMeter"]),
    ]
)
```
Then run `swift package update` to install the dependency.

## Usage
The first thing is to initialize an instance of `SwiftFlowMeter`. 

The `SwiftFlowMeter` initializer requires you to add a `SensorCharacteristic` instance. This object represents the formula that describes the sensor's pulse frequency transformation to flow rate. 

Once you have your `meter` object, you can start getting the total flow per minute, or request  flow rate readings per second, for example.
```swift
import Foundation
import SwiftFlowMeter

// Some sensors have an additional parameter, so their formula looks like F=k*Q+C. That is the `modifier` parameter for.
// If your sensor does not contains it, you can easily instantiate with SensorCharacteristic(kFactor: 10) instead.
let characteristic = SensorCharacteristic(kFactor: 10, modifier: .negative(4))

// You can also initialize the object without the .RaspberryPi3 parameter, since that is the default board.
let meter = SwiftFlowMeter(for: .RaspberryPi3, pinName: .pin27, pulseCharacteristic: characteristic)

meter.readTotalVolume(every: .minutes(1), onVolumeCalculation: { totalVolume in
    print("Total flow per minute: \(totalVolume)")
}, onFlowRateCalculation: { flowRate in
    print("Flow rate: \(flowRate.value) l/min")
})

RunLoop.main.run()
```

There is another method you can use to obtain flow rate calculations per second only:
```swift
meter.readFlowRate { flowRate in
    print("Flow rate: \(flowRate.value) l/min")
}
```
>:warning: You should **not**  call both methods at the same time, that is why `readTotalVolume` has an injectable closure to be executed every time the flow rate is calculated. If you call them both at the same time, you might start getting weird readings :warning:!

If for some reason you need to stop receiving readings for either total volume or flow rate, you can easily do it by calling the following:
```swift
meter.stopReadings()
```
