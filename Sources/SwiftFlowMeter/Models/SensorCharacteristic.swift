//
//  SensorCharacteristic.swift
//  SwiftFlowMeter
//
//  Created by Samuel Cornejo on 3/8/20.
//

import Foundation

/// Structure that holds essential information about the sensor's flow pulse characteristics.
/// - Note:
/// Each individual Hall effect based flow sensor has a straight line function that describes its flow pulse characteristics.
/// It usually follows the form of **F = k * Q**, but there are some instances where the sensor is described by the form of **F = k * Q + m**, where:
/// - **F**: Pulse frequency (1/s).
/// - **k**: Pulses per second per unit of measure (1/s) / (l/min).
/// - **Q**: Flow rate (l/min).
/// - **m**: An either positive or negative modifier (1/s).
public struct SensorCharacteristic {
    public enum Modifier {
        case positive(Double)
        case negative(Double)
        
        var value: Double {
            switch self {
            case .positive(let value):
                return +value
            case .negative(let value):
                return -value
            }
        }
    }
    
    // MARK: Variables Declaration
    
    /// Pulses per second per unit of measure: (1/s) / (l/min)
    public let kFactor: Double
    
    /// An either positive or negative modifier: (1/s)
    public let modifer: Modifier
    
    // MARK: Initializer
    public init(kFactor: Double, modifier: Modifier = .positive(0)) {
        self.kFactor = kFactor
        self.modifer = modifier
    }
}
