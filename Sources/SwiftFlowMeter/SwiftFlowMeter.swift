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

public class SwiftFlowMeter {
    // MARK: Nested Types
    enum State {
        case idle
        case available
        case queuedWork
    }
    
    enum Constants {
        static let oneSecond: TimeInterval = 1
        static let oneMinuteInSeconds: TimeInterval = 60
    }
    
    // MARK: Variables Declaration
    private let gpio: GPIO
    private let sensorQueue: DispatchQueue
    private let pulseCharacteristic: SensorCharacteristic

    private var flowRateCalculationWorkItem: DispatchWorkItem?
    private var onFlowRateCalculation: ((FlowRate) -> Void)?
    private var pulseCount: Double
    private var currentFlowRate: FlowRate
    private var flowRateHistory: Atomic<[FlowRate]>
    
    private var state: SwiftFlowMeter.State {
        didSet {
            if state == .available {
                onFlowRateCalculation?(currentFlowRate)
                readFlowRate(onCalculation: onFlowRateCalculation)
            }
        }
    }
    
    // MARK: Initializer
    public init(for board: SupportedBoard = .RaspberryPi3,
                pinName: GPIOName,
                queue: DispatchQueue = DispatchQueue(label: "com.swiftflowmeter.queue"),
                pulseCharacteristic: SensorCharacteristic) {
        let gpios = SwiftyGPIO.GPIOs(for: board)
        
        guard gpios.contains(where: { $0.key == pinName }), let gpioPin = gpios[pinName] else {
            fatalError("Please make sure the selected pin is available on the selected board.")
        }
        
        self.gpio = gpioPin
        self.sensorQueue = queue
        self.pulseCharacteristic = pulseCharacteristic
        self.pulseCount = 0
        self.currentFlowRate = FlowRate(pulses: pulseCount, using: pulseCharacteristic)
        self.flowRateHistory = Atomic([])
        self.state = .idle
        
        configurePin()
    }
    
    // MARK: Public Methods
    
    /// Reads the sensor's current flow rate and reports it back every second.
    /// - Parameter onCalculation: The closure to be executed every second the flow rate is calculated
    public func readFlowRate(onCalculation: ((FlowRate) -> Void)? = nil) {
        onFlowRateCalculation = onCalculation
        
        flowRateCalculationWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            self.currentFlowRate = FlowRate(pulses: self.pulseCount, using: self.pulseCharacteristic)
            self.pulseCount = 0
            self.state = .available
        }
        
        sensorQueue.asyncAfter(deadline: .now() + .seconds(1), execute: flowRateCalculationWorkItem!)
        state = .queuedWork
    }
    
    /// Reads the sensor's total flowed volume during the specified time.
    /// - Parameters:
    ///   - timePeriod: The time period to calculate the total volume from
    ///   - onVolumeCalculation: The closure to be executed whenever the total volume is calculated
    ///   - onFlowRateCalculation: The closure to be executed every second the flow rate is calculated
    public func readTotalVolume(every timePeriod: NotificationPeriod, onVolumeCalculation: @escaping ((Double) -> Void), onFlowRateCalculation: ((FlowRate) -> Void)? = nil) {
        readFlowRate { [weak self] flowRate in
            guard let self = self else { return }
            
            self.flowRateHistory.mutate{( $0.append(flowRate) )}
            
            if self.flowRateHistory.value.count == timePeriod.seconds.intValue {
                let totalFlow = self.flowRateHistory.value.map({ ($0.value / Constants.oneMinuteInSeconds) * Constants.oneSecond }).reduce(0, +)
                self.flowRateHistory = Atomic([])
                onVolumeCalculation(totalFlow)
            } else {
                onFlowRateCalculation?(flowRate)
            }
        }
    }
    
    /// Stops any of the ongoing readings.
    public func stopReadings() {
        flowRateCalculationWorkItem?.cancel()
        flowRateCalculationWorkItem = nil
        onFlowRateCalculation = nil
        pulseCount = 0
        currentFlowRate = FlowRate(pulses: pulseCount, using: pulseCharacteristic)
        flowRateHistory = Atomic([])
        state = .idle
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
