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

    let motionManger: MotionManager

    required init(coder aDecoder: NSCoder) {
        motionManger = MotionManager()
        super.init(coder: aDecoder)!
        motionManger.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        motionManger.startMotionManger()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: MotionMangerDelegate {
    func updateWithSpeedAndAcceleration(speed: Speed, acceleration: CMAcceleration) {
        speedLabel.text = "\(speed.x)"
        accelerationLabel.text = "\(acceleration.x)"
    }
}
