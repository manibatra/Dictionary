//
//  ViewController.swift
//  Dictionary
//
//  Created by Mani Batra on 11/3/17.
//  Copyright © 2017 Mani Batra. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var imagePicker: UIImagePickerController!     //main camera to take picture of words
    var boxCenter: CGPoint! //location of the registered tap

    
    
    /**
     * Method name: tapLocation
     * Description: registers of the location of the tap on user tap on the preview window and takes the picture
     * Parameters: sender : UITapGestureRecognizer
     */
    func tapLocation(sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            
            
            self.boxCenter = sender.location(in: self.imagePicker.view)
            NSLog("hello from : \(boxCenter.x) \(boxCenter.y)")
            self.imagePicker.takePicture()
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        self.imagePicker.showsCameraControls = false
        
        let screenSize = UIScreen.main.bounds.size
        let ratio: CGFloat = 4.0 / 3.0
        let cameraHeight: CGFloat = screenSize.width * ratio
        let scale: CGFloat = screenSize.height / cameraHeight
        
        self.imagePicker.cameraViewTransform = CGAffineTransform(translationX: 0, y: (screenSize.height - cameraHeight) / 2.0)
        self.imagePicker.cameraViewTransform = self.imagePicker.cameraViewTransform.scaledBy(x: scale, y: scale)
        
        //creating a tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapLocation(sender:)))
        tapGesture.delegate = self
        
        //creating an overlay view and adding it as a subview to the image picker
        let overlayView = UIView.init(frame: self.view.frame)
        overlayView.isOpaque = false
        overlayView.isUserInteractionEnabled = true
        overlayView.backgroundColor = UIColor.clear
        overlayView.addGestureRecognizer(tapGesture)
        self.imagePicker.view.addSubview(overlayView)
        
        
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.present(self.imagePicker,
                     animated: false,
                     completion: nil )
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

