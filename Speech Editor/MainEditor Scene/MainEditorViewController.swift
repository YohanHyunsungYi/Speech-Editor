//
//  MainEditorViewController.swift
//  AOT
//
//  Created by Hyun sung Yi on 11/23/18.
//  Copyright © 2018 Yohan Hyunsung Yi. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import Photos

class MainEditorViewController: UIViewController {
    
    var videoURL: URL!
    var audioURL: URL?
    var videoAsset: AVAsset!
    
    private let mainView = UIView()
    var videoPlayerView: VideoPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pop UP Activity Indicator Start
        
        ejectAudio()
        getSpeechToText()
        
        // Pop UP Activity Indicator Stop
        setupMainView()
    }
    
    private func ejectAudio() {
        audioURL = getAudioFileDirPath()
        let asset = AVURLAsset(url: videoURL, options: nil)
        asset.writeAudioTrackToURL(audioURL!) { (success, error) -> () in
            if !success {
                print("Audio Ejecting Error : \(error as Any)")
            } else {
                print("Audio Ejecting Sucess")
            }
        }
    }
    
    private func getSpeechToText() {
        
    }
    
    private func setupMainView() {
        // Set Up Player
        guard let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top else { return }
        let videoPlayerFrame = CGRect(x: 0, y: topInset / 2, width: self.view.frame.width, height: self.view.frame.width * 9/16)
        videoPlayerView = VideoPlayerView(frame: videoPlayerFrame, url: videoURL)
        videoPlayerView.isUserInteractionEnabled = true
        self.view.backgroundColor = .white
        self.view.addSubview(videoPlayerView)
        
        // Set Up Text View
        
        
        // Set Up Buttons
        
    }
}

//MARK: Edit Actions
extension MainEditorViewController {
    
}

//MARK: Helper
extension MainEditorViewController {
    func pauseVideo() {
        videoPlayerView.player.pause()
        videoPlayerView.pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
        videoPlayerView.isPlaying = false
    }
    
    func getAudioFileDirPath() -> URL{
        
        let dirPathNoScheme = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        //add directory path file Scheme;  some operations fail w/out it
        let dirPath = "file://\(dirPathNoScheme)"
        //name your file, make sure you get the ext right .mp3/.wav/.m4a/.mov/.whatever
        let fileName = "tempAudio.m4a"
        let pathArray = [dirPath, fileName]
        let path = URL(string: pathArray.joined(separator: "/"))
        
        //use a guard since the result is an optional
        guard let filePath = path else {
            //if it fails do this stuff:
            return URL(string: "choose how to handle error here")!
        }
        //if it works return the filePath
        return filePath
    }
}
