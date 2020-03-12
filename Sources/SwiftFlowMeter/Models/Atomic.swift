//
//  Atomic.swift
//  SwiftFlowMeter
//
//  Created by Samuel Cornejo on 3/10/20.
//

import Foundation

public class Atomic<A> {
    // MARK: Variables Declaration
    private let queue = DispatchQueue(label: "com.swiftflowmeter.atomicserialqueue")
    private var _value: A
    
    /// The actual value of the instance
    var value: A {
        get { return queue.sync { self._value } }
    }

    // MARK: Initializer
    init(_ value: A) {
        self._value = value
    }

    // MARK: Public Methods
    
    /// Safely mutates the instance's value.
    /// - Parameter transform: The mutation closure to be executed
    func mutate(_ transform: (inout A) -> ()) {
        queue.sync(flags: .barrier) { transform(&self._value) }
    }
}
