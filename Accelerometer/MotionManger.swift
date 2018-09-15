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
class Speed {
    var x: Double = 0

    var y: Double = 0

    var z: Double = 0
    
    func reset() {
        self.x = 0
        self.y = 0
        self.z = 0
    }
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
    /// the current speed, default value is 0
    let speed: Speed = Speed()
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
        cmMotionManager.startDeviceMotionUpdates(to: internalQueue, withHandler: { data, error in
            if let error = error {
                // handle error here
                print("\(error.localizedDescription)")
                return
            }

            if let data = data {
                self.updateSpeed(with: self.denoise(acceleration: data.userAcceleration))
                DispatchQueue.main.async {
                    self.delegate?.updateWithSpeedAndAcceleration(speed: self.speed, acceleration: self.denoise(acceleration: data.userAcceleration))
                }
            }
        })
    }
    
    func switchState() {
        if cmMotionManager.isDeviceMotionActive {
            stopMotionManger()
        } else {
            startMotionManger()
        }
    }

    public func stopMotionManger() {
        cmMotionManager.stopDeviceMotionUpdates()
    }
    
    func clear() {
        internalQueue.cancelAllOperations()
        self.speed.reset()
        self.delegate?.updateWithSpeedAndAcceleration(speed: self.speed, acceleration: CMAcceleration())
    }

    private func configureInternalQueue() {
        // we want a serial queue
        internalQueue.maxConcurrentOperationCount = 1
    }

    private func configureCMMotionManger() {
        cmMotionManager.accelerometerUpdateInterval = MotionManager.kUpdateInterval
    }

    private func updateSpeed(with acceleration: CMAcceleration) {
        speed.x = speed.x + acceleration.x * MotionManager.kUpdateInterval
        speed.y = speed.y + acceleration.y * MotionManager.kUpdateInterval
        speed.z = speed.z + acceleration.z * MotionManager.kUpdateInterval
    }
    
    private func denoise(acceleration: CMAcceleration) -> CMAcceleration {
        return CMAcceleration(
            x: acceleration.x - acceleration.x.truncatingRemainder(dividingBy: 0.1),
            y: acceleration.y - acceleration.y.truncatingRemainder(dividingBy: 0.1),
            z: acceleration.z - acceleration.z.truncatingRemainder(dividingBy: 0.1))
    }
}
