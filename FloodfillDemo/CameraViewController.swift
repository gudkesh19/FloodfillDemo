//
//  CameraViewController.swift
//  FloodfillDemo
//
//  Created by Gudkesh Kumar on 22/11/18.
//  Copyright © 2018 Gudkesh Kumar. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate: class {
    func didCapture(_ image: UIImage)
}

class CameraViewController: ViewController {
    let cameraManager = CameraManager()
    weak var delegate: CameraViewControllerDelegate?
    
    @IBOutlet fileprivate var captureButton: UIButton!
    
    @IBOutlet fileprivate var capturePreviewView: UIView!
    @IBOutlet fileprivate var toggleCameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleCaptureButton()
        requestCameraAccess()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func requestCameraAccess() {
       let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {[weak self] (granted) in
                if granted {
                    self?.configureCameraManager()
                } else {
                    print("Permission denied")
                }
            }
        case .restricted, .denied:
            print("Enable camera access in settings to capture photos")
        case .authorized:
            configureCameraManager()
        }
    }
    
    deinit {
        print("Camera viewController deallocated")
    }

}

extension CameraViewController {
    
    private func styleCaptureButton() {
        captureButton.layer.borderColor = UIColor.black.cgColor
        captureButton.layer.borderWidth = 2
        
        captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
    }
    
   private func configureCameraManager() {
        cameraManager.prepareCamera {[weak self](error) in
            if let error = error {
                print(error)
            }
            try? self?.cameraManager.addCameraPreview(on: (self?.capturePreviewView)!)
        }
    }
}

extension CameraViewController {
    
    @IBAction func closeCamera() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchCameras(_ sender: UIButton) {
        do {
            try cameraManager.switchCamera()
        }
            
        catch {
            print(error)
        }
        
    }
    
     @IBAction func captureImage(_ sender: UIButton) {
        cameraManager.capturePhoto {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            if let delegate = self.delegate {
                delegate.didCapture(image)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

