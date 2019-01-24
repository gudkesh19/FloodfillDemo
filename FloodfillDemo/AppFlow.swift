//
//  AppFlow.swift
//  FloodfillDemo
//
//  Created by Gudkesh Kumar on 26/11/18.
//  Copyright © 2018 Gudkesh Kumar. All rights reserved.
//

import UIKit

class AppFlow: NSObject {
    
    private let window: UIWindow
    
    init(withWindow window: UIWindow) {
        self.window = window
        super.init()
        let rootVC = window.rootViewController as! ViewController
        rootVC.gallaryTapped = { [weak self] in
         
            self?.gallaryButtonTapped(inController: rootVC)
        }
        
        rootVC.cameraTapped = {[weak self] in
            self?.cameraButtonTapped(inController: rootVC)
        }
    }
    
    private func gallaryButtonTapped(inController controller: ViewController) -> Void {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = controller
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            controller.present(imagePicker, animated: true, completion: nil)
        }
    }

    private func cameraButtonTapped(inController controller: ViewController) -> Void {
        if let cameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController {
            cameraVC.delegate = controller
            controller.present(cameraVC, animated: true, completion: nil)
        }
    }
}
