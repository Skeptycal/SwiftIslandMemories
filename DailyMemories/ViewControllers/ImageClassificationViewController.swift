//
//  ViewController.swift
//  DailyMemories
//
//  Created by Meghan Kane on 9/3/17.
//  Copyright © 2017 Meghan Kane. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ImageClassificationViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var captionLabel: UILabel!
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 10
        imagePickerController.delegate = self
    }
    
    @IBAction func choosePhoto() {
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // 🤖 VISION + CORE ML
    func classifyImage(from image: UIImage) {
        
        // 1. Create Vision Core ML model
        let model = ArtistClassifier()
        guard let visionCoreMLModel = try? VNCoreMLModel(for: model.model) else { return }
        
        // 2. Create Vision Core ML request
        let request = VNCoreMLRequest(model: visionCoreMLModel,
                                      completionHandler: self.handleClassificationResults)

        // 3. Create request handler
        // *First convert image: UIImage to CGImage + get CGImagePropertyOrientation*
        guard let cgImage = image.cgImage else {
            fatalError("Unable to convert \(image) to CGImage.")
        }
        let cgImageOrientation = ImageHelper.convertToCGImageOrientation(from: image)
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgImageOrientation)
    
        // 4. Perform request on handler
        // Ensure that it is done on an appropriate queue (not main queue)
        self.captionLabel.text = "Classifying artist..."
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Error performing artist classification")
            }
        }
    }
    
    // 5. Do something with the results
    // - Update the caption label
    // - Ensure that it is dispatched on the main queue, because we are updating the UI
    private func handleClassificationResults(for request: VNRequest, error: Error?) {
        
        // 👨🏿‍💻 YOUR CODE GOES HERE
        DispatchQueue.main.async {
            guard let classifications = request.results as? [VNClassificationObservation],
                classifications.isEmpty != true else {
                    self.captionLabel.text = "Unable to classify scene.\n\(error!.localizedDescription)"
                    return
            }
            self.updateCaptionLabel(classifications)
        }
    }
    
    // MARK: Helper methods
    
    private func updateCaptionLabel(_ classifications: [VNClassificationObservation]) {
        let topTwoClassifications = classifications.prefix(2)
        let descriptions = topTwoClassifications.map { classification in
            return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
        }
        self.captionLabel.text = "Artist:\n" + descriptions.joined(separator: "\n")
    }
}

extension ImageClassificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageSelected = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = imageSelected
            
            // Kick off Vision + Core ML task with image as input 🚀
            classifyImage(from: imageSelected)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
