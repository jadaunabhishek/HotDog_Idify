//
//  ViewController.swift
//  HotDog Idify
//
//  Created by Abhishek Jadaun on 16/11/23.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var clickedImage: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            clickedImage.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else{
                fatalError("Error converting UIImage to CIImage")
            }
            detectImage(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detectImage(image : CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model failed...")
        }
        let request = VNCoreMLRequest(model: model){ (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image... ")
            }
            if let firstResult = results.first{
                if firstResult.identifier.contains("hotdog"){
                    self.navigationItem.title = "Hotdog!"
                } else{
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    
    @IBAction func cameraClicked(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

