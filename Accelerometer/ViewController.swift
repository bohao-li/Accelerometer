//
//  ViewController.swift
//  Accelerometer
//
//  Created by Bohao Li on 6/17/16.
//  Copyright © 2016 Bohao Li. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var accelerationLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    let motionManger: MotionManager

    required init(coder aDecoder: NSCoder) {
        motionManger = MotionManager()
        super.init(coder: aDecoder)!
        motionManger.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        motionManger.startMotionManger()
        
        resetButton.addTarget(self, action: #selector(didTapReset(sender:)), for: .touchDown)
        pauseButton.addTarget(self, action: #selector(didTapPause(sender:)), for: .touchDown)
    }
    
    @objc
    private func didTapReset(sender: UIButton) {
        motionManger.clear()
    }
    
    @objc
    private func didTapPause(sender: UIButton) {
        motionManger.switchState()
    }
}

extension ViewController: MotionMangerDelegate {
    func updateWithSpeedAndAcceleration(speed: Speed, acceleration: CMAcceleration) {
        let speedabs = sqrt(speed.x * speed.x + speed.y * speed.y + speed.z * speed.z)
        let accelerationabs = sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z)
        
        self.speedLabel.text = String(format: "%.4f", speedabs)
        self.accelerationLabel.text = String(format: "%.2f", accelerationabs)
    }
}
