//
//  ViewController.swift
//  Dictionary
//
//  Created by Mani Batra on 11/3/17.
//  Copyright © 2017 Mani Batra. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var imagePicker: UIImagePickerController!     //main camera to take picture of words
    var boxCenter: CGPoint! //location of the registered tap
    var activityIndicator:UIActivityIndicatorView! //activity indicator to placate user when your code is lazy

    
    
    /**
     * Method name: tapLocation
     * Description: registers of the location of the tap on user tap on the preview window and takes the picture
     * Parameters: sender : UITapGestureRecognizer
     */
    func tapLocation(sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            
            
            self.boxCenter = sender.location(in: self.imagePicker.view)
//            NSLog("hello from : \(boxCenter.x) \(boxCenter.y)")
            self.imagePicker.takePicture()
            
        }
        
    }
    
    
    /**
     * Method name: addActivityIndicator
     * Description: shows the activity indicator in the view
     * Parameters:
     */

    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    
    /**
     * Method name: removeActivityIndicator
     * Description: removes the activity indicator from the view
     * Parameters:
     */

    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    
    
    /**
     * Method name: translateScreen
     * Description: translates the image picker preview window to the size of the phone screen
     * Parameters:
     */

    func translateScreen() {
        let screenSize = UIScreen.main.bounds.size
        let ratio: CGFloat = 4.0 / 3.0
        let cameraHeight: CGFloat = screenSize.width * ratio
        let scale: CGFloat = screenSize.height / cameraHeight
        
        self.imagePicker.cameraViewTransform = CGAffineTransform(translationX: 0, y: (screenSize.height - cameraHeight) / 2.0)
        self.imagePicker.cameraViewTransform = self.imagePicker.cameraViewTransform.scaledBy(x: scale, y: scale)
    }
    
    
    /**
     * Method name: scaleImage
     * Description: helper method to scale image to be used by tesserect
     * Parameters: (image: UIImage, maxDimension: CGFloat) -> UIImage
     */

    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        //redraw the image
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in:CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: scaledSize.width, height: scaledSize.height)))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    
    /**
     * Method name: performWordRecognition
     * Description: perorms word recognition from the image using tesseract
     * Parameters: image: UIImage, rectangle: CGRect
     */
    func performWordRecognition(image: UIImage, rectangle: CGRect) {
        
        let tesseract = G8Tesseract.init(language: "eng")

        tesseract?.image = image
        tesseract?.rect = rectangle
        tesseract?.recognize()
        

        print ("\(tesseract?.recognizedText)")
        removeActivityIndicator()
        
    }

    



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        self.imagePicker.showsCameraControls = false
        
        
        translateScreen()
        
        //creating a tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapLocation(sender:)))
        tapGesture.delegate = self
        
        //creating an overlay view and adding it as a subview to the image picker
        let overlayView = UIView.init(frame: self.view.frame)
        overlayView.isOpaque = false
        overlayView.isUserInteractionEnabled = true
        overlayView.backgroundColor = UIColor.clear
        
        //create the "how it works" label
        let label = UILabel.init()
        label.text = "Help"
        label.font = UIFont.init(name: "AppleSDGothicNeo-Light", size: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(label)
        label.textColor = UIColor.white
        label.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 20).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 20).isActive = true
        
        
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


/**
 * Extension name: UIImagePickerControllerDelegate
 * Description: handles the delegate methods for UIImagePickerController
 */

extension ViewController: UIImagePickerControllerDelegate {
    
    
    /**
     * Method name: imagePickerControler(:didFinishPIckingMediaWithInfo :)
     * Description: function called when the picutre is taken
     * Parameters: picker: UIImagePickerController,info: [String : Any]
     */

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //scale the image to the resolution usable by tesseract
        let scaledImage = scaleImage(image: selectedPhoto, maxDimension: 640)
        
        addActivityIndicator()
        
        
        //change the point of the tap to a point on the image
        let percentX = self.boxCenter.x / self.imagePicker.view.frame.size.width;
        let percentY = self.boxCenter.y / self.imagePicker.view.frame.size.height;
        let imagePoint = CGPoint.init(x: scaledImage.size.width * percentX, y: scaledImage.size.height * percentY)
        
        //the box representing the area to be used for OCR by tesseract
        let rectangle = CGRect.init(x: imagePoint.x - 100, y: imagePoint.y - 100, width: 350, height: 200)

        
        dismiss(animated: true, completion: {
            
            self.performWordRecognition(image: scaledImage, rectangle: rectangle)

        })
    }
    
}


