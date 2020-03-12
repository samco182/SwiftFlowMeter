//
//  FlowRate.swift
//  SwiftFlowMeter
//
//  Created by Samuel Cornejo on 3/9/20.
//

import Foundation

public struct FlowRate {
    // MARK: Variables Declaration
    
    /// The actual value in (l/min)
    public let value: Double
    
    // MARK: Initializer
    public init(pulses: Double, using pulseCharacteristic: SensorCharacteristic) {
        self.value = pulses != 0 ? (pulses - pulseCharacteristic.modifer.value) / pulseCharacteristic.kFactor : 0
    }
}
