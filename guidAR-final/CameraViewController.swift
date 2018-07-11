//
//  CameraViewController.swift
//  guidAR-final
//
//  Created by Geri Elise Madanguit on 5/6/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

/*
class CameraViewController : UIViewController{
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    
    //output deive
    var stillImageOutput: AVCaptureStillImageOutput?
    var stillImage: UIImage?
    
    //camera preview later
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaType) as! [AVCaptureDevice]
        for device in devices{
            if device.position == .back {
                backCamera = device
            }
            else if device.position == .front {
                frontCamera = device
            }
        }
        
        //default device
        currentDevice = frontCamera
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings[AVVideoCodecKey : AVVideoCodecJPEG]
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
        }
        catch let error {
            print(error)
        }
        
    }
}
*/
