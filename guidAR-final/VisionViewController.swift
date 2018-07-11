// VisionViewController.swift
//  guidAR-final
//
//  Created by Geri Elise Madanguit on 5/5/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import Foundation
import UIKit
import CoreMedia
import Vision
import Firebase
import AVFoundation


class VisionViewController: UIViewController, UIImagePickerControllerDelegate{
    var searchKey : String?
    var searchHistoryController: SearchHistoryController?
    var image : UIImage?
    
    
    let previewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let visionLabel: UILabel = {
        let label = UILabel()
        label.text = "Vision"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let predictLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let visionSwitch: UISwitch = {
        let vs = UISwitch()
        vs.translatesAutoresizingMaskIntoConstraints = false
        return vs
    }()
    
    // some properties used to control the app and store appropriate values
    
    let inceptionv3model = Inceptionv3()
    private var videoCapture: VideoCapture!
    private var requests = [VNRequest]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 255, g: 255, b: 255)
        
        view.addSubview(previewView)
        view.addSubview(predictLabel)
        view.addSubview(visionLabel)
        view.addSubview(visionSwitch)
        
        setupViews()
        setupVision()
        
    
        let spec = VideoSpec(fps: 5, size: CGSize(width: 299, height: 299))
        videoCapture = VideoCapture(cameraType: .back,
                                    preferredSpec: spec,
                                    previewContainer: previewView.layer)
        
        videoCapture.imageBufferHandler = {[unowned self] (imageBuffer) in
            if self.visionSwitch.isOn {
                // Use Vision
                self.handleImageBufferWithVision(imageBuffer: imageBuffer)
            }
            else {
                // Use Core ML
                self.handleImageBufferWithCoreML(imageBuffer: imageBuffer)
            }
        }
        
    }
    
    func handleImageBufferWithCoreML(imageBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(imageBuffer) else {
            return
        }
        do {
            let prediction = try self.inceptionv3model.prediction(image: self.resize(pixelBuffer: pixelBuffer)!)
            DispatchQueue.main.async {
                if let prob = prediction.classLabelProbs[prediction.classLabel] {
                    self.predictLabel.text = "\(prediction.classLabel) \(String(describing: prob))"
                    //print(self.predictLabel.text!)
                    print(self.searchKey!)
                    print(prediction.classLabel)
                    if (prediction.classLabel == self.searchKey!){
                        print("IT'S A SUCCESS!!")
                        let ciimage : CIImage = CIImage(cvPixelBuffer: pixelBuffer)
                        self.image = self.convert(cmage: ciimage)
                        UIImageWriteToSavedPhotosAlbum(self.image!, nil, nil, nil)
                        guard let uid = Auth.auth().currentUser?.uid else{
                            return
                        }
                        self.registerUserIntoDatabaseWithUID(uid, label:prediction.classLabel, probability:String(describing: prob))
                    }
                }
            }
        }
        catch let error as NSError {
            fatalError("Unexpected error ocurred: \(error.localizedDescription).")
        }
    }
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, label:String, probability:String) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid).child("search_history").child(searchKey!)
        
        let imageName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("model_images").child("\(imageName).jpg")
            
        // Compress Image into JPEG type
        //self.registerUserIntoDatabaseWithUID(uid)
        if let modelImage = self.image, let uploadData = UIImageJPEGRepresentation(modelImage, 0.1) {
            _ = storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("Error when uploading profile image")
                    return
                }
              let values = ["label": label, "score": probability, "image": metadata.downloadURL()?.absoluteString]
                
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                
                if err != nil {
                    print(err ?? "")
                    return
                }
            })
            }
        }
        self.viewDidDisappear(true)
        self.searchHistoryController?.fetchUserAndSetupNavBarTitle()
        self.searchHistoryController?.navigationController?.popViewController(animated: true)
    }
    
    open func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return screenshotImage
    }
    
    func takeScreenshot2(view: UIView) -> UIImageView {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        return UIImageView(image: image)
    }
    
    func captureScreen() -> UIImage? {
        var theScreenshot = UIImage()
        if let window = UIApplication.shared.keyWindow {
            UIGraphicsBeginImageContextWithOptions(window.frame.size, false,
                                                   UIScreen.main.scale)
            view.layer.render(in: UIGraphicsGetCurrentContext()!)
            theScreenshot = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(theScreenshot, nil, nil, nil)
        }
        return theScreenshot
    }
    
    func screenshot4(){
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
            
        layer.render(in: UIGraphicsGetCurrentContext()!)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
    
    }
  
    func handleImageBufferWithVision(imageBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(imageBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let cameraIntrinsicData = CMGetAttachment(imageBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: UInt32(self.exifOrientationFromDeviceOrientation))!, options: requestOptions)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func setupViews() {
        previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
        previewView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        previewView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.8).isActive = true
        previewView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1.0).isActive = true
        
        predictLabel.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 8).isActive = true
        predictLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        predictLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1).isActive = true
        predictLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
        
        visionLabel.topAnchor.constraint(equalTo: predictLabel.bottomAnchor).isActive = true
        visionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        visionLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1).isActive = true
        visionLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3).isActive = true
        
        visionSwitch.topAnchor.constraint(equalTo: predictLabel.bottomAnchor, constant: 11).isActive = true
        visionSwitch.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 85).isActive = true
        visionSwitch.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2).isActive = true
        visionSwitch.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3).isActive = true
    }

    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: inceptionv3model.model) else {
            fatalError("can't load Vision ML model")
        }
        let classificationRequest = VNCoreMLRequest(model: visionModel) { (request: VNRequest, error: Error?) in
            guard let observations = request.results else {
                print("no results:\(error!)")
                return
            }
            
            let classifications = observations[0...4]
                .flatMap({ $0 as? VNClassificationObservation })
                .filter({ $0.confidence > 0.2 })
                .map({ "\($0.identifier) \($0.confidence)" })
            DispatchQueue.main.async {
                self.predictLabel.text = classifications.joined(separator: "\n")
            }
        }
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        
        self.requests = [classificationRequest]
    }
    
    
    /// only support back camera
    var exifOrientationFromDeviceOrientation: Int32 {
        let exifOrientation: DeviceOrientation
        enum DeviceOrientation: Int32 {
            case top0ColLeft = 1
            case top0ColRight = 2
            case bottom0ColRight = 3
            case bottom0ColLeft = 4
            case left0ColTop = 5
            case right0ColTop = 6
            case right0ColBottom = 7
            case left0ColBottom = 8
        }
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            exifOrientation = .left0ColBottom
        case .landscapeLeft:
            exifOrientation = .top0ColLeft
        case .landscapeRight:
            exifOrientation = .bottom0ColRight
        default:
            exifOrientation = .right0ColTop
        }
        return exifOrientation.rawValue
    }
    
    
    /// resize CVPixelBuffer
    ///
    /// - Parameter pixelBuffer: CVPixelBuffer by camera output
    /// - Returns: CVPixelBuffer with size (299, 299)
    func resize(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let imageSide = 299
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        let transform = CGAffineTransform(scaleX: CGFloat(imageSide) / CGFloat(CVPixelBufferGetWidth(pixelBuffer)), y: CGFloat(imageSide) / CGFloat(CVPixelBufferGetHeight(pixelBuffer)))
        ciImage = ciImage.transformed(by: transform).cropped(to: CGRect(x: 0, y: 0, width: imageSide, height: imageSide))
        let ciContext = CIContext()
        var resizeBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, imageSide, imageSide, CVPixelBufferGetPixelFormatType(pixelBuffer), nil, &resizeBuffer)
        ciContext.render(ciImage, to: resizeBuffer!)
        return resizeBuffer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let videoCapture = videoCapture else {return}
        videoCapture.startCapture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let videoCapture = videoCapture else {return}
        videoCapture.resizePreview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let videoCapture = videoCapture else {return}
        videoCapture.stopCapture()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
