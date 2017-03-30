//
//  PlaySoundsVC.swift
//  PitchPerfect
//
//  Created by Jarrod Parkes on 3/29/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

// MARK: - PlaySoundsVC: UIViewController

class PlaySoundsVC: UIViewController {

    // MARK: Properties
    
    var model = Model(audioURL: URL(fileURLWithPath: ""))
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
    }
    
    @IBAction func playRecording(_ sender: Any) {
        playSound()
    }
    
    func setupAudio() {
        // initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: model.audioURL)
        } catch {
            print("could not create audio file from \(model.audioURL)")
        }
    }
    
    func playSound(slowRate: Bool = false) {
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        if slowRate {
            // node for adjusting rate/pitch
            let changeRatePitchNode = AVAudioUnitTimePitch()
            changeRatePitchNode.rate = 0.5
            audioEngine.attach(changeRatePitchNode)
            
            audioEngine.connect(audioPlayerNode, to: changeRatePitchNode, format: audioFile.processingFormat)
            audioEngine.connect(changeRatePitchNode, to: audioEngine.outputNode, format: audioFile.processingFormat)
        } else {
            audioEngine.connect(audioPlayerNode, to: audioEngine.outputNode, format: audioFile.processingFormat)
        }
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                // determine how long until the stop timer is trigged based on the length of the audio (adjusted for rate, if necessary)
                if slowRate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(0.5)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            // schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsVC.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
        do {
            try audioEngine.start()
        } catch {
            return
        }
        
        // play the recording!
        audioPlayerNode.play()
    }
    
    func stopAudio() {
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
}
