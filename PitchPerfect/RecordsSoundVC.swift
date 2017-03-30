//
//  RecordsSoundVC.swift
//  PitchPerfect
//
//  Created by Jarrod Parkes on 3/15/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - RecordsSoundVC: UIViewController

class RecordsSoundVC: UIViewController {

    // MARK: Properties
    
    var audioRecorder: AVAudioRecorder?
    
    // MARK: Outlets
    
    @IBOutlet weak var recordingLabel: UILabel!
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordingLabel.text = "Tap to start recording"
    }
    
    @IBAction func recordAudio(_ sender:  Any) {
        recordingLabel.text = "Tap to finish recording"
        
        if audioRecorder == nil || !(audioRecorder?.isRecording)! {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    func startRecording() {
        
        // create path for audio file
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        // create session and begin recording
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
    }
    
    func stopRecording() {
        // stop recording
        audioRecorder?.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlaySoundsVC" {
            let playSoundsVC = segue.destination as! PlaySoundsVC
            let recordedAudioURL = sender as! URL
            playSoundsVC.model = Model(audioURL: recordedAudioURL)
        }
    }
}

// MARK: - RecordsSoundVC: AVAudioRecorderDelegate

extension RecordsSoundVC: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "showPlaySoundsVC", sender: audioRecorder?.url)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print(error!)
    }    
}
