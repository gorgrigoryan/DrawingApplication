//
//  SettingsViewController.swift
//  DrawingApplication
//
//  Created by 1 on 9/24/19.
//  Copyright © 2019 gorgrigoryan. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func settingsViewControllerDidFinish(_ settingsVC:SettingsViewController)
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var colorView: UIImageView!

    @IBOutlet weak var brushSizeLabel: UILabel!
    @IBOutlet weak var opacityLabel: UILabel!
    
    @IBOutlet weak var redColorLabel: UILabel!
    @IBOutlet weak var greenColorLabel: UILabel!
    @IBOutlet weak var blueColorLabel: UILabel!
    
    @IBOutlet weak var brushSizeSlider: UISlider!
    @IBOutlet weak var opacitySlider: UISlider!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    
    var brushSize: CGFloat = 1.0
    var opacity: CGFloat = 1.0
    
    var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        brushSizeSlider.value = Float(brushSize)
        brushSizeLabel.text = "\(Int(brushSize))"
        
        opacitySlider.value = Float(opacity)
        opacityLabel.text = "\(opacity)"
        
        redSlider.value = Float(red)
        redColorLabel.text = "\(Int(redSlider.value * 255))"
        
        greenSlider.value = Float(green)
        greenColorLabel.text = "\(Int(greenSlider.value * 255))"
        
        blueSlider.value = Float(blue)
        blueColorLabel.text = "\(Int(blueSlider.value * 255))"
        
        showColorPreview()
    }
    
    @IBAction func apply(_ sender: UIButton) {
        if delegate != nil {
            delegate?.settingsViewControllerDidFinish(self)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        delegate = nil
        apply(sender)
    }
    
    @IBAction func brushSizeChanged(_ sender: UISlider) {
        brushSize = CGFloat(sender.value)
        brushSizeLabel.text = "\(Int(sender.value))"
        showColorPreview()
    }
    
    @IBAction func opacityChanged(_ sender: UISlider) {
        opacity = CGFloat(sender.value)
        opacityLabel.text = String(format: "%.1f", sender.value)
        showColorPreview()
    }
    
    @IBAction func redSliderChanged(_ sender: UISlider) {
        redColorLabel.text = "\(Int(sender.value * 255))"
        red = CGFloat(sender.value)
        showColorPreview()
    }
    
    @IBAction func greenSliderChanged(_ sender: UISlider) {
        greenColorLabel.text = "\(Int(sender.value * 255))"
        green = CGFloat(sender.value)
        showColorPreview()
    }
    
    @IBAction func blueSliderChanged(_ sender: UISlider) {
        blueColorLabel.text = "\(Int(sender.value * 255))"
        blue = CGFloat(sender.value)
        showColorPreview()
    }
    
    func showColorPreview() {
        UIGraphicsBeginImageContext(colorView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setStrokeColor(UIColor(red: red, green: green, blue: blue, alpha: opacity).cgColor)
        context?.setLineWidth(brushSize)
        context?.setLineCap(CGLineCap.round)
        
        context?.move(to: CGPoint(x: 70, y: 70))
        context?.addLine(to: CGPoint(x: 70, y: 70))
        context?.strokePath()
        
        colorView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
