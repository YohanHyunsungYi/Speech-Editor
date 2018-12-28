//
//  AVAssetExtension.swift
//  Speech Editor
//
//  Created by Hyun sung Yi on 12/26/18.
//  Copyright © 2018 Yohan Hyunsung Yi. All rights reserved.
//

import AVFoundation

extension AVAsset {
    
    func writeAudioTrackToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
        do {
            let audioAsset = try self.audioAsset()
            audioAsset.writeToURL(url, completion: completion)
        } catch (let error as NSError){
            completion(false, error)
        }
    }
    
    func writeToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
        
        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetAppleM4A) else {
            completion(false, nil)
            return
        }
        
        exportSession.outputFileType = .m4a
        exportSession.outputURL      = url
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(true, nil)
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                completion(false, nil)
            }
        }
    }
    
    func audioAsset() throws -> AVAsset {
        
        let composition = AVMutableComposition()
        let audioTracks = tracks(withMediaType: .audio)
        
        for track in audioTracks {
            
            let compositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionTrack?.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
            compositionTrack?.preferredTransform = track.preferredTransform
        }
        return composition
    }
}

func convertAudio(url: URL, outputURL: URL) {
    var error : OSStatus = noErr
    var destinationFile: ExtAudioFileRef? = nil
    var sourceFile : ExtAudioFileRef? = nil
    
    var srcFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
    var dstFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
    
    ExtAudioFileOpenURL(url as CFURL, &sourceFile)
    
    var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: srcFormat))
    
    ExtAudioFileGetProperty(sourceFile!,
                            kExtAudioFileProperty_FileDataFormat,
                            &thePropertySize, &srcFormat)
    
    dstFormat.mSampleRate = 44100  //Set sample rate
    dstFormat.mFormatID = kAudioFormatLinearPCM
    dstFormat.mChannelsPerFrame = 1
    dstFormat.mBitsPerChannel = 16
    dstFormat.mBytesPerPacket = 2 * dstFormat.mChannelsPerFrame
    dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame
    dstFormat.mFramesPerPacket = 1
    dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger
    
    // Create destination file
    error = ExtAudioFileCreateWithURL(
        outputURL as CFURL,
        kAudioFileWAVEType,
        &dstFormat,
        nil,
        AudioFileFlags.eraseFile.rawValue,
        &destinationFile)
    print("Error 1 in convertAudio: \(error.description)")
    
    error = ExtAudioFileSetProperty(sourceFile!,
                                    kExtAudioFileProperty_ClientDataFormat,
                                    thePropertySize,
                                    &dstFormat)
    print("Error 2 in convertAudio: \(error.description)")
    
    error = ExtAudioFileSetProperty(destinationFile!,
                                    kExtAudioFileProperty_ClientDataFormat,
                                    thePropertySize,
                                    &dstFormat)
    print("Error 3 in convertAudio: \(error.description)")
    
    let bufferByteSize : UInt32 = 32768
    var srcBuffer = [UInt8](repeating: 0, count: 32768)
    var sourceFrameOffset : ULONG = 0
    
    while(true){
        var fillBufList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: AudioBuffer(
                mNumberChannels: 2,
                mDataByteSize: UInt32(srcBuffer.count),
                mData: &srcBuffer
            )
        )
        var numFrames : UInt32 = 0
        
        if(dstFormat.mBytesPerFrame > 0){
            numFrames = bufferByteSize / dstFormat.mBytesPerFrame
        }
        
        error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)
        print("Error 4 in convertAudio: \(error.description)")
        
        if(numFrames == 0){
            error = noErr;
            break;
        }
        
        sourceFrameOffset += numFrames
        error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
        print("Error 5 in convertAudio: \(error.description)")
    }
    
    error = ExtAudioFileDispose(destinationFile!)
    print("Error 6 in convertAudio: \(error.description)")
    error = ExtAudioFileDispose(sourceFile!)
    print("Error 7 in convertAudio: \(error.description)")
}
