//
//  MotionManger.swift
//  Accelerometer
//
//  Created by Bohao Li on 6/17/16.
//  Copyright © 2016 Bohao Li. All rights reserved.
//

import Foundation
import CoreMotion

/**
 * Speed representing
 * 
 *  Fields:
 *    x:
 *      X-axis speed in G * s's.
 *    y:
 *      Y-axis speed in G * s's.
 *	  z:
 *		Z-axis speed in G * s's.
 */
struct Speed {
    var x: Double = 0

    var y: Double = 0

    var z: Double = 0
}

protocol MotionMangerDelegate: class {
    func updateWithSpeedAndAcceleration(speed: Speed, acceleration: CMAcceleration)
}

public class MotionManager {

    // MARK: constants

    static let kUpdateInterval: TimeInterval = 0.1

    // MARK: manager fields

    /// internal queue to wait for acceleration updates
    let internalQueue = OperationQueue()
    /// the underlying motion manger
    let cmMotionManager = CMMotionManager()
    /// the current acceleration, its default value is 0
    var acceleration: CMAcceleration = CMAcceleration()
    /// the current speed, default value is 0
    var speed = Speed()
    /// delegate responsible for consuming the latest speed and acceleration
    weak var delegate: MotionMangerDelegate?

    public init() {
        configureInternalQueue()
        configureCMMotionManger()
    }

    /**
     * Starts the accelerameter.
     */
    public func startMotionManger() {
        cmMotionManager.startAccelerometerUpdates(to: internalQueue, withHandler: { data, error in
            if let error = error {
                // handle error here
                print("\(error.description)")
                return
            }

            if let data = data {
                self.acceleration = data.acceleration
                self.updateSpeed()
                self.delegate?.updateWithSpeedAndAcceleration(speed: self.speed, acceleration: self.acceleration)
            }
        })
    }

    public func stopMotionManger() {
        cmMotionManager.stopAccelerometerUpdates()
    }

    private func configureInternalQueue() {
        // we want a serial queue
        internalQueue.maxConcurrentOperationCount = 1
    }

    private func configureCMMotionManger() {
        cmMotionManager.accelerometerUpdateInterval = MotionManager.kUpdateInterval
    }

    private func updateSpeed() {
        speed.x = acceleration.x * MotionManager.kUpdateInterval
        speed.y = acceleration.y * MotionManager.kUpdateInterval
        speed.z = acceleration.z * MotionManager.kUpdateInterval
    }
}
