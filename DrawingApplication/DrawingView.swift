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
    
    var selectedLayer: CAShapeLayer?
    var appMode = Mode.draw
    var undoPaths = [CAShapeLayer]()
    var isDrawing = true // draw or erase button
    var color = UIColor.black
    var brushSize: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var path = UIBezierPath()
    
    @IBAction func erase(_ sender: UIButton) {
        color = isDrawing ? UIColor.white : UIColor.black
        sender.setImage(isDrawing ? UIImage(named: "brush") : UIImage(named: "eraser"), for: .normal)
        isDrawing = !isDrawing
    }
    
    @IBAction func colorPicked(_ sender: UIButton) {
        if isDrawing {
            guard let pickedColor = sender.backgroundColor else {
                return
            }
            color = pickedColor
        }
    }
    
    @IBAction func undo(_ sender: UIButton) {
        guard var layers = self.layer.sublayers else {
            return
        }
        guard let removeLayer = layers.removeLast() as? CAShapeLayer else {
            return
        }
        
        removeLayer.removeFromSuperlayer()
        undoPaths.append(removeLayer)
        setNeedsDisplay()
    }
    
    @IBAction func redo(_ sender: UIButton) {
        guard !undoPaths.isEmpty else {
            return
        }
        
        self.layer.addSublayer(undoPaths.removeLast())
        setNeedsDisplay()
    }
    
    
    @IBAction func changeMode(_ sender: UIButton) {
        let condition = appMode == Mode.move
        appMode = condition ? .draw : .move
        setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupPath() {
        path = UIBezierPath()
        path.lineWidth = brushSize
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        switch appMode {
        case .draw:
            setupPath()
            path.move(to: touchLocation)
            undoPaths = []
        case .move:
            guard let layers = self.layer.sublayers else {
                return
            }
            
            for layer in layers {
                if let _ = layer.hitTest(touchLocation) {
                    selectedLayer = layer as? CAShapeLayer
                    break
                }
            }
        }
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        
        switch appMode {
        case .draw:
            path.addLine(to: touchLocation)
        case .move:
            guard let layer = selectedLayer else {
                return
            }
            
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            
            layer.position = touchLocation
            
            CATransaction.commit()
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch appMode {
        case .draw:
            let touch = touches.first!
            path.addLine(to: touch.location(in: self))
            appendNewShapeLayer()
            setNeedsDisplay()
        case .move:
            selectedLayer = nil
        }
    }
    
    private func appendNewShapeLayer() {
        let shapeLayer = CAShapeLayer()
        setShapeLayerProperties(shapeLayer)
        self.layer.addSublayer(shapeLayer)
        path.removeAllPoints()
    }
    
    private func setShapeLayerProperties(_ shapeLayer: CAShapeLayer) {
        
        let correctedBounds = CGRect(x: path.bounds.origin.x - brushSize / 2, y: path.bounds.origin.y - brushSize / 2, width: path.bounds.size.width + brushSize, height: path.bounds.size.height + brushSize)
        
        shapeLayer.bounds = correctedBounds
        shapeLayer.frame = shapeLayer.bounds
        shapeLayer.path = path.cgPath
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = brushSize
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        path.addLine(to: touch.location(in: self))
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        switch appMode {
        case .draw:
            color.setStroke()
            path.stroke()
        case .move:
            break
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
}
