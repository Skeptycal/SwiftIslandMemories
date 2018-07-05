//
//  StyleTransferViewController.swift
//  SwiftIslandMemories
//
//  Created by Meghan Kane on 6/25/18.
//  Copyright © 2018 Meghan Kane. All rights reserved.
//

import UIKit
import CoreML
import Vision

class StyleTransferViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var captionLabel: UILabel!
    let imagePickerController = UIImagePickerController()
    let styleTransferModel = VanGoghStyleTransfer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 10
        imagePickerController.delegate = self
    }
    
    @IBAction func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            imagePickerController.cameraDevice = .front
        }
        
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func applyStyleTransfer(image: UIImage) {

        /* Create style array
           numStyles: # of styles network was trained on
           styleIndex: which style you'd like to apply
        */
        
        guard let styleArray = createStyleArray(numStyles: 375, styleIndex: 0) else {
            fatalError("Could not create style array")
        }
        
        // 1. Create Core ML model
        
        // ** YOUR CODE GOES HERE ** //
        
        // 2. Create Core ML prediction
        
        // ** YOUR CODE GOES HERE ** //
        
        // 3. Update UI with stylizedImage
        
        // ** YOUR CODE GOES HERE ** //
    }
    
    private func createStyleArray(numStyles: Int, styleIndex: Int) -> MLMultiArray? {
        guard let styleArray = try? MLMultiArray(shape: [numStyles] as [NSNumber], dataType: MLMultiArrayDataType.double) else {
            return nil
        }
        
        for i in 0..<styleArray.count {
            styleArray[i] = 0.0
        }
        
        styleArray[styleIndex] = 1.0
        
        return styleArray
    }
    
    private func updateUI(styleTransferredImage: UIImage) {
        self.imageView.image = styleTransferredImage
        self.captionLabel.text = ""
    }
}

extension StyleTransferViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageSelected = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            let startX = (imageSelected.size.width - 256)/2.0
            let startY = (imageSelected.size.height - 256)/2.0
            let croppedImageSelected = ImageHelper.cropImage(imageSelected, cropRect: CGRect(x: startX, y: startY, width: 256, height: 256))
            
            // Kick off Vision + Core ML task with image as input 🚀
            applyStyleTransfer(image: croppedImageSelected)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
