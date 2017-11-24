//
//  AbstractViewController.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import SwiftMessages
import AVKit
class AbstractViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // variables
    var activityIndicator : NVActivityIndicatorView!
    let activityIndicatorSize = CGSize.init(width: 60, height: 60)
    // MARK: Lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicator()
    }
    
    private func addActivityIndicator(){
        // Initialize Activity Indicator
        let viewFrame = self.view.bounds
        let frame = CGRect.init(origin: CGPoint.init(x: (viewFrame.width - activityIndicatorSize.width)/2.0, y: (viewFrame.height - activityIndicatorSize.height)/2.0), size: activityIndicatorSize)
        activityIndicator = NVActivityIndicatorView.init(frame: frame)
        activityIndicator.type = .ballClipRotateMultiple
        activityIndicator.color = UIColor.white
        activityIndicator.backgroundColor = UIColor.init(red: 236.0/255.0, green: 236.0/255.0, blue: 236.0/255.0, alpha: 0.7)
        
        view.addSubview(activityIndicator)
    }
    
    // MARK: Show Annoncements to user
    
    // Announcements
    func showErrorMessage(errorMessage : String){
        // TODO Show error messages
        SwiftMessages.sharedInstance.defaultConfig.presentationStyle = .bottom
        let view = MessageView.viewFromNib(layout: .CardView)
        
        // Theme message elements with the warning style.
        view.configureTheme(.error)
        
        view.configureContent(title: errorMessage, body: "", iconText: "")
        view.button?.setTitle("", for: UIControlState.normal)
        view.button?.setImage(UIImage.init(), for: .normal)
        view.button?.isHidden = true
        view.contentMode = .center
        // Show the message.
        SwiftMessages.show(view: view)
    }
    
    func showMessage(message: String){
        // TODO Show success, etc. messages
        SwiftMessages.sharedInstance.defaultConfig.presentationStyle = .bottom
        let view = MessageView.viewFromNib(layout: .CardView)
        
        // Theme message elements with the warning style.
        view.configureTheme(.success)
        
        view.configureContent(title: message, body: "", iconText: "")
        view.button?.setTitle("", for: UIControlState.normal)
        view.button?.setImage(UIImage.init(), for: .normal)
        view.button?.isHidden = true
        view.frame.origin.x = 0
        view.frame.size.width = self.view.frame.width
        // Show the message.
        SwiftMessages.show(view: view)
        

    }
    
    func showGBError(error : GBError){
        self.showErrorMessage(errorMessage: error.description)
    }
    func showError(error : Error) {
        // TODO Show error
        self.showErrorMessage(errorMessage: error.localizedDescription)
    }
    
    func startLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func endLoading(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    
    
    // MARK: Image Upload
    /*
     *  MARK: UIImagePickerController delegate function.
     */
    var selectedImageUrl: NSURL!
    var selectedImage : UIImage?
    var imagePickerVC: UIImagePickerController!

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePickerVC.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            if let url = info[UIImagePickerControllerReferenceURL] as? NSURL, let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.selectedImageUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
                self.selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage
            }else {
                self.selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            }
            self.startUploadImage()
        }
    }
    var imageUrl : String = ""
    var image_uploaded : Bool = false
    func updateUI(){
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize.init(width: size.width * heightRatio, height: size.height*heightRatio)
        } else {
            newSize = CGSize.init(width: size.width * widthRatio, height: size.height*widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    func startUploadImage()
    {
        if let _ = self.selectedImage, let resizedImage = resizeImage(image: self.selectedImage!, targetSize: CGSize.init(width: 100, height: 100)){
            if let imageData = UIImagePNGRepresentation(resizedImage){
                self.startLoading()
                ImageUploader().uploadImage(imageData: imageData, handler: { (response) in
                    self.endLoading()
                    if response.status {
                        self.showMessage(message: "Profile Picture uploaded")
                        if let stringURL = response.result as? URL {
                            self.imageUrl = stringURL.absoluteString
                        }
                        self.updateUI()
                    }else{
                        self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                    }
                })
            }else{
                self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                
            }
        }else{
            self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
        }
    }
    
    func generateImageUrl(fileName: String) throws -> NSURL
    {
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory().appendingFormat(fileName))
        let data = UIImageJPEGRepresentation(self.selectedImage!, 0.6)
        try data?.write(to: fileURL as URL)
        return fileURL
    }
    // MARK: Image handling
    func openImagePicker(){
        print("Capture Image")
        let alertVC = UIAlertController(title: "Update Profile Picture", message: "Choose your profile picture", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.openImagePickerViewCamera()
        }))
        alertVC.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action) in
            self.openImagePickerViewGallery()
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
        
    }
    
    
    /*
     *  private function that presents image picker from gallery controller
     */
    private func openImagePickerViewGallery()
    {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized:
            break
        case .denied:
            self.showErrorMessage(errorMessage: "Media Permission denied")
            return
        default:
            break
        }
        
        imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .savedPhotosAlbum
        imagePickerVC.allowsEditing = true
        present(imagePickerVC, animated: true, completion: nil)
        
    }
    
    /*
     *  private function that presents image picker from camera controller
     */
    private func openImagePickerViewCamera()
    {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized:
            break
        case .denied:
            self.showErrorMessage(errorMessage: "Camera permission denied")
            
            return
        default:
            break
        }
        
        imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .camera
        imagePickerVC.allowsEditing = true
        present(imagePickerVC, animated: true, completion: nil)
        
    }
    
    
    

}
