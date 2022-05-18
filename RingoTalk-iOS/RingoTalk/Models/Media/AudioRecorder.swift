//
//  AudioRecorder.swift
//  Message
//
//  Created by Yoo on 2022/05/15.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    static let shared = AudioRecorder()
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    
    private override init() {
        super.init()
        
        checkForRecordPermission()
    }
    
    func checkForRecordPermission() {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            isAudioRecordingGranted = true
        case .denied:
            isAudioRecordingGranted = false
        case .undetermined:
            session.requestRecordPermission { [weak self] isAllowed in
                self?.isAudioRecordingGranted = isAllowed
            }
        @unknown default: break
        }
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted {
            recordingSession = AVAudioSession.sharedInstance()
            
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            } catch {
                print("Error setting up audio recording session", error.localizedDescription)
            }
        }
    }
    
    func startRecording(fileName: String) {
        let audioFileName = getDocumentURL().appendingPathComponent(fileName + ".m4a",
                                                                    isDirectory:  false)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print("Error recording", error.localizedDescription)
            finishRecording()
        }
    }
    
    func finishRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
}
