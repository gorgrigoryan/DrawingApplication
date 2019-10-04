//
//  DrawingView.swift
//  DrawingApplication
//
//  Created by gorgrigoryan on 9/23/19.
//  Copyright © 2019 gorgrigoryan. All rights reserved.
//

import UIKit

class DrawingView: UIView {
    
    enum Mode {
        case draw
        case move
    }
    
    var isExistPoint = false
    
    var appMode = Mode.draw
    
    var initialCenter = CGPoint()
    
    var tool: UIImageView!
    
    var undoPaths = [DrawingLine]()
    
    var pathArray = [DrawingLine]()
    
    var shapeLayerArray = [CAShapeLayer]()
    
    var lastShapeLayer = CAShapeLayer()
    
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
    
    
    @IBAction func modeChange(_ sender: UIButton) {
        if appMode == Mode.move {
            for shapeLayer in shapeLayerArray {
                shapeLayer.isHidden = true
            }
            appMode = Mode.draw
            setNeedsDisplay()
        } else {
            for shapeLayer in shapeLayerArray {
                shapeLayer.isHidden = false
            }
            appMode = Mode.move
                
        }
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
        if appMode == .draw {
        setupPath()
        pathArray.append(DrawingLine(path: path, color: color))
        let touch = touches.first!
        path.move(to: touch.location(in: self))
        tool.center = touch.location(in: self)
        setNeedsDisplay()
        undoPaths = []
        } else {
            let touch = touches.first!
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
            
            
            if lastShapeLayer.contains(touch.location(in: self)) {
                isExistPoint = true
//                lastShapeLayer.position = touch.location(in: self)
            }
//            CATransaction.commit()
//            setNeedsDisplay()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if appMode == .draw {
        let touch = touches.first!
        tool.center = touch.location(in: self)
        path.addLine(to: touch.location(in: self))
        setNeedsDisplay()
            } else {
            if isExistPoint {
                let touch = touches.first!
            lastShapeLayer.position = touch.location(in: self)
                
            }
            
            setNeedsDisplay()
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if appMode == .draw {
        let touch = touches.first!
        path.addLine(to: touch.location(in: self))
        appendNewShapeLayer()
        setNeedsDisplay()
        } else {
            isExistPoint = false
        }
    }
    
    private func appendNewShapeLayer() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.frame = bounds
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = brushSize
        layer.addSublayer(shapeLayer)
        
//        shapeLayer.position = CGPoint(x: bounds.minX, y: bounds.minY)
        shapeLayerArray.append(shapeLayer)
        let newActions = [
            "onOrderIn": NSNull(),
            "onOrderOut": NSNull(),
            "sublayers": NSNull(),
            "contents": NSNull(),
            "bounds": NSNull(),
        ]
        
        shapeLayer.actions = newActions
        
        lastShapeLayer = shapeLayer
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        path.addLine(to: touch.location(in: self))
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if appMode == .draw {
        for line in pathArray {
            line.color.setStroke()
            line.path.stroke()
        }
        } else {
        
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        self.addGestureRecognizer(panGesture)
            
//        for shapeLayer in shapeLayerArray {
//
//            self.layer.addSublayer(shapeLayer)
//        }
    }
    }
}

extension DrawingView: SettingsViewControllerDelegate {
    func settingsViewControllerDidFinish(_ settingsVC: SettingsViewController) {
        if isDrawing {
            opacity = settingsVC.opacity
            brushSize = settingsVC.brushSize
            color = UIColor(red: settingsVC.red, green: settingsVC.green, blue: settingsVC.blue, alpha: opacity)
        }
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        if appMode == .move {
            let location = recognizer.location(in: self)
            
            if lastShapeLayer.hitTest(location) != nil {
                print("pan")
                lastShapeLayer.position = location
            }
        
//        if recognizer.state == .began {
//            self.initialCenter = recognizerView.center
//        }
        
//        if recognizer.state != .cancelled {
//            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
//            recognizerView.center = newCenter
//        } else {
//            recognizerView.center = initialCenter
//        }
        }
    }
}
