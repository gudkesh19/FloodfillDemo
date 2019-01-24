//
//  ViewController.swift
//  FloodfillDemo
//
//  Created by Gudkesh Kumar on 22/11/18.
//  Copyright © 2018 Gudkesh Kumar. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraViewControllerDelegate {
    
    @IBOutlet weak var imageView: FFImageView!
    
    
    var gallaryTapped: (() -> Void)?
    var cameraTapped: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cameraBtnTapped(_ sender: UIButton) {
        // Launch the camera
        if let tapped = cameraTapped {
            tapped()
        }
    }
    
    @IBAction func gallaryBtnTapped(_ sender: UIButton) {
        // open Gallary
        if let tapped = gallaryTapped {
            tapped()
        }
    }
    
    @IBAction func colorBtnTapped(_ sender: UIButton) {
        var selectedColor = UIColor.red
        switch sender.tag {
        case 1:
            selectedColor = .purple
        case 2:
            selectedColor = .red
        case 3:
            selectedColor = .blue
        case 4:
            selectedColor = .green
        case 5:
            selectedColor = .orange
        default:
            selectedColor = .red
        }
        imageView.set(fillColor: selectedColor)
    }
}

extension ViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension ViewController {
    func didCapture(_ image: UIImage) {
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
    }
}

