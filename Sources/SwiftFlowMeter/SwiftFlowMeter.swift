//
//  SwiftFlowMeter.swift
//  SwiftFlowMeter
//
//  Created by Samuel Cornejo on 3/5/19.
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Foundation
import SwiftyGPIO

public enum MonitoringAction {
    case start
    case stop
}

public class SwiftFlowMeter {
    // MARK: Variables Declaration
    private let gpio: GPIO
    private let pulseCharacteristic: SensorCharacteristic
    private var currentAction: MonitoringAction = .stop
    private var pulseCount: Double = 0
    
    // MARK: Initializer
    public init(for board: SupportedBoard = .RaspberryPi3, pinName: GPIOName, pulseCharacteristic: SensorCharacteristic) {
        let gpios = SwiftyGPIO.GPIOs(for: board)
        
        guard gpios.contains(where: { $0.key == pinName }) else {
            fatalError("Please make sure the selected pin is available on the selected board.")
        }
        
        self.gpio = gpios[pinName]!
        self.pulseCharacteristic = pulseCharacteristic
        
        configurePin()
    }
    
    // MARK: Public Methods
    
    /// Changes the sensor's monitoring action.
    /// - Parameter newAction: The new action to be executed
    public func switchMonitoring(to newAction: MonitoringAction) {
        currentAction = newAction
    }
    
    /// Reads the sensor's current flow rate and reports it back every second.
    /// - Parameters:
    ///   - queue: The queue where the operation is going to take place
    ///   - onCalculation: The closure to be executed every second the flow rate is calculated
    public func readFlowRate(queue: DispatchQueue = DispatchQueue(label: "com.swiftflowmeter.readflowrate"), onCalculation: @escaping (FlowRate) -> Void) {
        currentAction = .start
        pulseCount = 0
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            var startTime = Date()
            while self.currentAction == .start {
                if abs(startTime.timeIntervalSinceNow) > 1 {
                    onCalculation(FlowRate(pulses: self.pulseCount, using: self.pulseCharacteristic))
                    
                    self.pulseCount = 0
                    startTime = Date()
                }
            }
        }
    }
    
    // MARK: Private Methods
    private func configurePin() {
        gpio.direction = .IN
        gpio.pull = .up
        
        gpio.onRaising { [weak self] _ in
            self?.pulseCount += 1
        }
    }
}
