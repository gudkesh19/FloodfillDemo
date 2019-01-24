//
//  CameraManager.swift
//  FloodfillDemo
//
//  Created by Gudkesh Kumar on 23/11/18.
//  Copyright © 2018 Gudkesh Kumar. All rights reserved.
//

import UIKit
import AVFoundation

class CameraManager: NSObject {

    private var captureSession: AVCaptureSession?
    var cameraPosition: CameraPosition?
    
    private var frontCamera: AVCaptureDevice?
    private var frontCameraInput: AVCaptureDeviceInput?
    
    private var backCamera: AVCaptureDevice?
    private var backCameraInput: AVCaptureDeviceInput?
    
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    func prepareCamera(completionHandler: @escaping(Error?) -> Void) {
        DispatchQueue(label: "CameraPreparation").async {[weak self] in
            do {
                self?.createCaptureSession()
                try self?.configureCaptureDevices()
                try self?.configureDeviceInputs()
                try self?.configureCapturePhotoOutput()
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
}

//MARK: Camera configuration Methods
extension CameraManager {
    
    private func createCaptureSession() {
        self.captureSession = AVCaptureSession()
    }
    
    private func configureCaptureDevices() throws {
        let session = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInDualCamera], mediaType: .video, position: .unspecified)
        let cameras = session.devices.compactMap{$0}
        guard !cameras.isEmpty else { throw CameraManagerError.noCamerasAvailable}
        for camera in cameras {
            if camera.position == .front {
                self.frontCamera = camera
            }
            if camera.position == .back {
                self.backCamera = camera
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }
    }
    
    private func configureDeviceInputs() throws {
        guard let session = self.captureSession else { throw CameraManagerError.captureSessionIsMissing}
        
        if let bCamera = self.backCamera {
            self.backCameraInput = try AVCaptureDeviceInput(device: bCamera)
            if session.canAddInput(self.backCameraInput!) {
                session.addInput(self.backCameraInput!)
                self.cameraPosition = .back

            } else { throw CameraManagerError.inputsAreInvalid }
            
        } else if let fCamera = self.frontCamera {
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: fCamera)
            if session.canAddInput(frontCameraInput!) {
                session.addInput(frontCameraInput!)
                self.cameraPosition = .front

            } else {
                throw CameraManagerError.inputsAreInvalid
            }
        } else {
            throw CameraManagerError.noCamerasAvailable
        }
    }
    
    private func configureCapturePhotoOutput() throws {
        guard let session = captureSession else { throw CameraManagerError.captureSessionIsMissing}
        self.photoOutput = AVCapturePhotoOutput()
        self.photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
        if session.canAddOutput(photoOutput!) {
            session.addOutput(photoOutput!)
        } else { throw CameraManagerError.outputIsInvalid}
        session.startRunning()
    }
}

//MARK:
extension CameraManager {
    
    func addCameraPreview(on view: UIView) throws {
        guard let session = captureSession, session.isRunning else { throw CameraManagerError.captureSessionIsMissing }
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        view.layer.insertSublayer(previewLayer!, at: 0)
        previewLayer?.frame = view.bounds
    }
    
    func switchCamera() throws {
        guard let cameraPostion = cameraPosition, let session = captureSession, session.isRunning else { throw CameraManagerError.captureSessionIsMissing }
        session.beginConfiguration()
        
        func switchToFrontCamera() throws {
            guard let backCameraInput = backCameraInput, session.inputs.contains(backCameraInput), let frontCamera = frontCamera else {
                throw CameraManagerError.invalidOperation
            }
            
            frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            session.removeInput(backCameraInput)
            if session.canAddInput(frontCameraInput!) {
                session.addInput(frontCameraInput!)
                cameraPosition = .front
            } else {
                throw CameraManagerError.invalidOperation
            }
        }
        
        func switchToBackCamera() throws {
            guard let frontCameraInput = frontCameraInput, session.inputs.contains(frontCameraInput), let backCamera = backCamera else {
                throw CameraManagerError.invalidOperation
            }
            
            backCameraInput = try AVCaptureDeviceInput(device: backCamera)
            session.removeInput(frontCameraInput)
            if session.canAddInput(backCameraInput!) {
                session.addInput(backCameraInput!)
                cameraPosition = .back
            } else {
                throw CameraManagerError.invalidOperation
            }
        }
        
        switch cameraPostion {
        case .front:
            try switchToBackCamera()
        case .back:
            try switchToFrontCamera()
        }
        session.commitConfiguration()
    }
    
    func capturePhoto(completion: @escaping(UIImage?, Error?) -> Void)  {
        guard let session = captureSession, session.isRunning else { completion(nil, CameraManagerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
        settings.isAutoStillImageStabilizationEnabled = true
        photoOutput?.capturePhoto(with: settings, delegate: self)
        photoCaptureCompletionBlock = completion
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard  error == nil else {
            photoCaptureCompletionBlock?(nil, error)
            return
        }
        
        if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)
            photoCaptureCompletionBlock?(image,nil)
        }
        
    }
}

extension CameraManager {
    enum CameraManagerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case outputIsInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case back
    }
}
