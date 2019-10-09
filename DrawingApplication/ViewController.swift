//
//  ViewController.swift
//  DrawingApplication
//
//  Created by gorgrigoryan on 9/23/19.
//  Copyright © 2019 gorgrigoryan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var drawingView: DrawingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawingView.clipsToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let settingsVC = segue.destination as! SettingsViewController
        settingsVC.delegate = drawingView
        drawingView.color.getRed(&settingsVC.red, green: &settingsVC.green, blue: &settingsVC.blue, alpha: &settingsVC.opacity)
        settingsVC.brushSize = drawingView.brushSize
    }
}
