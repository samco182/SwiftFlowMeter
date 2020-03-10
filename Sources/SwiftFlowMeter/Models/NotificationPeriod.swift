//
//  NotificationPeriod.swift
//  SwiftFlowMeter
//
//  Created by Samuel Cornejo on 3/9/20.
//

import Foundation

public enum NotificationPeriod {
    case seconds(TimeInterval)
    case minutes(TimeInterval)
    case hours(TimeInterval)
    
    var seconds: TimeInterval {
        switch self {
        case .seconds(let seconds):
            return seconds
        case .minutes(let minutes):
            return minutes * 60
        case .hours(let hours):
            return hours * 3600
        }
    }
    
    var minutes: TimeInterval {
        switch self {
        case .seconds(let value), .hours(let value):
            return value / 60
        case .minutes(let minutes):
            return minutes
        }
    }
}
