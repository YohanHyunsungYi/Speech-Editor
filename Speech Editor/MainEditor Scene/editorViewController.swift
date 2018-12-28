//
//  editorViewController.swift
//  Speech Editor
//
//  Created by Hyun sung Yi on 12/27/18.
//  Copyright © 2018 Yohan Hyunsung Yi. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import Photos

class EditorViewController: UIViewController, AAPlayerDelegate {
    
    @IBOutlet weak var videoPlayerView: AAPlayer!
    var audioPlayer = AVAudioPlayer()
    
    var videoURLOptional: URL?
    var audioURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videoURL = videoURLOptional else { return }

        // MARK: 1 - Pop UP Activity Indicator Start
        
        // MARK: 2 - Extract Audio from Video
        audioURL = extractAudio(videoURL: videoURL)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL!)
        }
        catch { print("ERROR") }
        audioPlayer.play()
        
        // MARK: 3 - Audio to Text
        getSpeechToText()
        
        // MARK: 4 - Pop UP Activity Indicator Stop
        
        // MARK: 5 - Setup View
        setupMainView(videoURL: videoURL)
    }
    
    private func extractAudio(videoURL: URL) -> URL? {
        
        // Create a composition
        let composition = AVMutableComposition()
        do {
            let sourceUrl = videoURL
            let asset = AVURLAsset(url: sourceUrl)
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return nil }
            let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try audioCompositionTrack?.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
        } catch {
            print(error)
        }
        
        // Get url for output
        let tempDocUrl: URL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)!
        let tempOutputUrl = tempDocUrl.appendingPathComponent("extractedAudio.m4a")
        if FileManager.default.fileExists(atPath: tempOutputUrl.path) {
            try? FileManager.default.removeItem(atPath: tempOutputUrl.path)
        }
        
        // Create an export session
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputFileType = AVFileType.m4a
        exportSession.outputURL = tempOutputUrl
        
        // Export file
        exportSession.exportAsynchronously {
            guard case exportSession.status = AVAssetExportSession.Status.completed else { return }
            DispatchQueue.main.async {
                // Present a UIActivityViewController to share audio file
                guard let outputURL = exportSession.outputURL else { return }
                let activityViewController = UIActivityViewController(activityItems: [outputURL], applicationActivities: [])
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        
//        // Convert to WAV filetype
//        let docUrl: URL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)!
//        let outputUrl = docUrl.appendingPathComponent("extractedAudio.m4a")
//        convertAudio(url: tempOutputUrl, outputURL: outputUrl)
        
        return tempOutputUrl
    }
    
    private func getSpeechToText() {

    }
    
    private func setupMainView(videoURL: URL) {
        // Set Up Player
        videoPlayerView.delegate = self
        videoPlayerView.playVideo(videoURL)
        
        // Set Up Collection View
        
        
        // Set Up Buttons
        
    }
}


//MARK: Edit Actions
extension EditorViewController {
    
}

//MARK: Helper
extension EditorViewController {
    
    
}
