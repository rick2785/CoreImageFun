//
//  ViewController.swift
//  CoreImageFun
//
//  Created by Rickey Hrabowskie on 5/2/17.
//  Copyright © 2017 Rickey Hrabowskie. All rights reserved.
//

import UIKit
import AssetsLibrary

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
                            
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var amountSlider: UISlider!
  
  var context: CIContext!
  var filter: CIFilter!
  var beginImage: CIImage!
  var orientation: UIImageOrientation = .up
  
  @IBAction func amountSliderValueChanged(_ sender: UISlider) {
    let sliderValue = sender.value
    
    let outputImage = self.oldPhoto(beginImage, withAmount: sliderValue)
    
    let cgimg = context.createCGImage(outputImage, from: outputImage.extent)
    
    let newImage = UIImage(cgImage: cgimg!, scale:1, orientation:orientation)
    self.imageView.image = newImage
  }
  
  @IBAction func loadPhoto(_ sender: AnyObject) {
    let pickerC = UIImagePickerController()
    pickerC.delegate = self
    self.present(pickerC, animated: true, completion: nil)
  }
  
  @IBAction func savePhoto(_ sender: AnyObject) {
    // 1
    let imageToSave = filter.outputImage
    
    // 2
    let softwareContext = CIContext(options:[kCIContextUseSoftwareRenderer: true])
    
    // 3
    let cgimg = softwareContext.createCGImage(imageToSave!, from:imageToSave!.extent)
    
    // 4
    let library = ALAssetsLibrary()
    library.writeImage(toSavedPhotosAlbum: cgimg,
      metadata:imageToSave!.properties,
      completionBlock:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // 1
    let fileURL = Bundle.main.url(forResource: "image", withExtension: "png")
    
    // 2
    beginImage = CIImage(contentsOf: fileURL!)
    
    // 3
    filter = CIFilter(name: "CISepiaTone")
    filter.setValue(beginImage, forKey: kCIInputImageKey)
    filter.setValue(0.5, forKey: kCIInputIntensityKey)
    let outputImage = filter.outputImage
    
    // 1
    context = CIContext(options:nil)
    let cgimg = context.createCGImage(outputImage!, from: outputImage!.extent)
    
    // 2
    let newImage = UIImage(cgImage: cgimg!)
    self.imageView.image = newImage
    
    self.logAllFilters()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
 
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    self.dismiss(animated: true, completion: nil);
    
    let gotImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    beginImage = CIImage(image:gotImage)
    orientation = gotImage.imageOrientation
    filter.setValue(beginImage, forKey: kCIInputImageKey)
    self.amountSliderValueChanged(amountSlider)
  }
  
  func logAllFilters() {
    
    let properties = CIFilter.filterNames(
      inCategory: kCICategoryBuiltIn)
    print(properties)
    
    for filterName: String in properties {
      let fltr = CIFilter(name:filterName as String)
      print(fltr!.attributes)
    }
  }
  
  func oldPhoto(_ img: CIImage, withAmount intensity: Float) -> CIImage {
    
    // 1
    let sepia = CIFilter(name:"CISepiaTone")
    sepia?.setValue(img, forKey:kCIInputImageKey)
    sepia?.setValue(intensity, forKey:"inputIntensity")
    
    // 2
    let random = CIFilter(name:"CIRandomGenerator")
    
    // 3
    let lighten = CIFilter(name:"CIColorControls")
    lighten?.setValue(random?.outputImage, forKey:kCIInputImageKey)
    lighten?.setValue(1 - intensity, forKey:"inputBrightness")
    lighten?.setValue(0, forKey:"inputSaturation")
    
    // 4
    let croppedImage = lighten?.outputImage?.cropping(to: beginImage.extent)
    
    // 5
    let composite = CIFilter(name:"CIHardLightBlendMode")
    composite?.setValue(sepia?.outputImage, forKey:kCIInputImageKey)
    composite?.setValue(croppedImage, forKey:kCIInputBackgroundImageKey)
    
    // 6
    let vignette = CIFilter(name:"CIVignette")
    vignette?.setValue(composite?.outputImage, forKey:kCIInputImageKey)
    vignette?.setValue(intensity * 2, forKey:"inputIntensity")
    vignette?.setValue(intensity * 30, forKey:"inputRadius")
    
    // 7
    return vignette!.outputImage!
  }
  
  
  
}

