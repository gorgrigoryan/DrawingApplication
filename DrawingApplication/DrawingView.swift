//
//  DrawingView.swift
//  DrawingApplication
//
//  Created by gorgrigoryan on 9/23/19.
//  Copyright © 2019 gorgrigoryan. All rights reserved.
//

import UIKit

class DrawingView: UIView {
    
    var tool: UIImageView!
    
    var undoPaths = [DrawingLine]()
    
    var pathArray = [DrawingLine]()
    
    var isDrawing = true // draw or erase button
    
    var color = UIColor.black
    
    var brushSize: CGFloat = 10.0
    
    var opacity: CGFloat = 1.0
    
    var path = UIBezierPath()
    
    @IBAction func erase(_ sender: UIButton) {
        if isDrawing {
            color = UIColor.white
            tool.image = UIImage(named: "EraserIcon")
            sender.setImage(UIImage(named: "paintBrush"), for: .normal)
        } else {
            color = UIColor.black
            tool.image = UIImage(named: "paintBrush")
            sender.setImage(UIImage(named: "EraserIcon"), for: .normal)
        }
        isDrawing = !isDrawing
    }
    
    @IBAction func colorPicked(_ sender: UIButton) {
        guard let pickedColor = sender.backgroundColor else {
            return
        }
        
        if isDrawing {
            color = pickedColor
        }
        
    }
    
    @IBAction func undo(_ sender: UIButton) {
        guard !pathArray.isEmpty else {
            return
        }
        
        undoPaths.append(pathArray.removeLast())
        setNeedsDisplay()
    }
    
    @IBAction func redo(_ sender: UIButton) {
        guard !undoPaths.isEmpty else {
            return
        }
        
        pathArray.append(undoPaths.removeLast())
        setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tool = UIImageView()
        
        tool.frame = CGRect(x: self.bounds.size.width, y: self.bounds.size.height, width: 30, height: 30)
        tool.image = UIImage(named: "paintBrush")
        self.addSubview(tool)
    }
    
    func setupPath() {
        path = UIBezierPath()
        path.lineWidth = brushSize
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setupPath()
        pathArray.append(DrawingLine(path: path, color: color))
        let touch = touches.first!
        path.move(to: touch.location(in: self))
        tool.center = touch.location(in: self)
        setNeedsDisplay()
        undoPaths = []
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        tool.center = touch.location(in: self)
        path.addLine(to: touch.location(in: self))
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        path.addLine(to: touch.location(in: self))
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        path.addLine(to: touch.location(in: self))
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        for line in pathArray {
            line.color.setStroke()
            line.path.stroke()
        }
    }
}

extension DrawingView: SettingsViewControllerDelegate {
    func settingsViewControllerDidFinish(_ settingsVC: SettingsViewController) {
        opacity = settingsVC.opacity
        brushSize = settingsVC.brushSize
        color = UIColor(red: settingsVC.red, green: settingsVC.green, blue: settingsVC.blue, alpha: opacity)
    }
}
