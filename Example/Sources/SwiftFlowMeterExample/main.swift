import Foundation
import SwiftFlowMeter

let sensorCharcteristic = SensorCharacteristic(kFactor: 10, modifier: .negative(4))
let meter = SwiftFlowMeter(pinName: .P27, pulseCharacteristic: sensorCharcteristic)
meter.readFlowRate { flowRate in
    print("FLOW RATE: \(flowRate.value) l/min")
}

RunLoop.main.run()
