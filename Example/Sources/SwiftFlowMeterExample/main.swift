import Foundation
import SwiftFlowMeter

// Some sensors have an additional parameter, so their formula looks like F=k*Q+C. That is the `modifier` parameter for.
// If your sensor does not need it, you can easily instantiate with SensorCharacteristic(kFactor: 10)
let characteristic = SensorCharacteristic(kFactor: 10, modifier: .negative(4))

// You can also initialize the object without the .RaspberryPi3 parameter. That is the default board.
let meter = SwiftFlowMeter(for: .RaspberryPi3, pinName: .P27, pulseCharacteristic: characteristic)

meter.readTotalVolume(every: .minutes(1), onVolumeCalculation: { totalVolume in
    print("Total flow per minute: \(totalVolume)")
}, onFlowRateCalculation: { flowRate in
    print("Flow rate: \(flowRate.value) l/min")
})

RunLoop.main.run()
