//
//  ViewController.swift
//  AOT
//
//  Created by Hyun sung Yi on 11/23/18.
//  Copyright © 2018 Yohan Hyunsung Yi. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func videoPickerButtonAction(_ sender: Any) {
        self.galleryTapped()
    }
    
    // Handle the touch event on the gallery button
    private func galleryTapped() {
        let videoPickerController = UIImagePickerController()
        videoPickerController.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false { return }
        videoPickerController.allowsEditing = true
        videoPickerController.sourceType = .photoLibrary
        videoPickerController.mediaTypes = [kUTTypeMovie as String]
        videoPickerController.modalPresentationStyle = .custom
        self.present(videoPickerController, animated: true, completion: nil)
    }

    // After picking a video, we dismiss the picker view controller and present the editor view controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let videoURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL
        self.dismiss(animated: true, completion: nil)
        
        // We create a VideoEditorViewController to play video as well as for editing purpose
        let MainEditorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditorViewController") as! EditorViewController
        MainEditorVC.videoURLOptional = videoURL
        self.present(MainEditorVC, animated: false, completion: nil)
    }
}

