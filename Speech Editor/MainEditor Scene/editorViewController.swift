//
//  editorViewController.swift
//  Speech Editor
//
//  Created by Yi, Yohan [GCB-OT NE] on 12/27/18.
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
    
    var videoURLOptional: URL?
    var audioURL: URL?
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videoURL = videoURLOptional else { return }
        videoPlayerView.delegate = self

        // Pop UP Activity Indicator Start
        
        ejectAudio(videoURL)
        getSpeechToText()
        
        // Pop UP Activity Indicator Stop
        setupMainView(videoURL)
    }
    
    private func ejectAudio(_ videoURL: URL) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        audioURL = url.appendingPathComponent("tempAudio.m4a")
        let asset = AVURLAsset(url: videoURL, options: nil)
        
//        ecjectAudioFile(asset, completion: <#(Data?) -> ()#>)

    }
    
    private func getSpeechToText() {

    }
    
    private func setupMainView(_ videoURL: URL) {
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

    
    func ecjectAudioFile(_ item: AVPlayerItem, completion: @escaping (Data?) -> ()) {
        guard item.asset.isExportable else {
            completion(nil)
            return
        }
        
        let composition = AVMutableComposition()
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        
        let sourceVideoTrack = item.asset.tracks(withMediaType: AVMediaType.video).first!
        let sourceAudioTrack = item.asset.tracks(withMediaType: AVMediaType.audio).first!
        do {
            try compositionVideoTrack!.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: item.duration), of: sourceVideoTrack, at: CMTime.zero)
            try compositionAudioTrack!.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: item.duration), of: sourceAudioTrack, at: CMTime.zero)
        } catch(_) {
            completion(nil)
            return
        }
        
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: composition)
        var preset: String = AVAssetExportPresetPassthrough
        if compatiblePresets.contains(AVAssetExportPreset1920x1080) { preset = AVAssetExportPreset1920x1080 }
        
        guard
            let exportSession = AVAssetExportSession(asset: composition, presetName: preset),
            exportSession.supportedFileTypes.contains(AVFileType.mp4) else {
                completion(nil)
                return
        }
        
        var tempFileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("temp_video_data.mp4", isDirectory: false)
        tempFileUrl = URL(fileURLWithPath: tempFileUrl.path)
        
        exportSession.outputURL = tempFileUrl
        exportSession.outputFileType = AVFileType.mp4
        let startTime = CMTimeMake(value: 0, timescale: 1)
        let timeRange = CMTimeRangeMake(start: startTime, duration: item.duration)
        exportSession.timeRange = timeRange
        
        exportSession.exportAsynchronously {
            print("\(tempFileUrl)")
            print("\(exportSession.error)")
            let data = try? Data(contentsOf: tempFileUrl)
            _ = try? FileManager.default.removeItem(at: tempFileUrl)
            completion(data)
        }
    }
}
