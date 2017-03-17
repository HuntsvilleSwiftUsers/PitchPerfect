//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Jarrod Parkes on 3/15/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var recordingLabel: UILabel!
    
    let model = Model(name: "James")
    
    @IBAction func recordAudio(_ sender:  Any) {
        recordingLabel.text = "Tap to finish recording"        
    }
}






