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
    
    var selectedLayer: Int?
    var appMode = Mode.draw
    var tool: UIImageView!
    var undoPaths = [DrawingLine]()
    var shapeLayerArray = [CAShapeLayer]()
    var isDrawing = true // draw or erase button
    var color = UIColor.black
    var brushSize: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var path = UIBezierPath()
    
    @IBAction func erase(_ sender: UIButton) {
        color = isDrawing ? UIColor.white : UIColor.black
        tool.image = isDrawing ? UIImage(named: "EraserIcon") : UIImage(named: "paintBrush")
        sender.setImage(isDrawing ? UIImage(named: "paintBrush") : UIImage(named: "EraserIcon"), for: .normal)
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
//        guard !pathArray.isEmpty else {
//            return
//        }
//        undoPaths.append(pathArray.removeLast())
        setNeedsDisplay()
    }
    
    @IBAction func redo(_ sender: UIButton) {
        guard !undoPaths.isEmpty else {
            return
        }
//        pathArray.append(undoPaths.removeLast())
        setNeedsDisplay()
    }
    
    
    @IBAction func modeChange(_ sender: UIButton) {
        let condition = appMode == Mode.move
        tool.isHidden = !condition
        appMode = condition ? .draw : .move
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
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        switch appMode {
        case .draw:
            setupPath()
            path.move(to: touchLocation)
            tool.center = touchLocation
            undoPaths = []
        case .move:
            for index in shapeLayerArray.indices {
                if let _ = shapeLayerArray[index].hitTest(touchLocation) {
                    selectedLayer = index
                }
            }
            // TODO: write for cycle for finding needed layer
            break
            
        }
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        
        switch appMode {
        case .draw:
            tool.center = touchLocation
            path.addLine(to: touchLocation)
        case .move:
            guard let index = selectedLayer else {
                return
            }
            guard index < shapeLayerArray.count, index >= 0 else {
                return
            }
            
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            shapeLayerArray[index].position = touchLocation
            
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
    
    private func setShapeLayerProperties(_ shapeLayer: CAShapeLayer) {
        shapeLayer.frame = path.bounds
        path.apply(CGAffineTransform(translationX: -path.bounds.origin.x, y: -path.bounds.origin.y))
        shapeLayer.path = path.cgPath
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = brushSize
        shapeLayer.backgroundColor = UIColor.red.cgColor
        path.removeAllPoints()
    }
    
    private func appendNewShapeLayer() {
        let shapeLayer = CAShapeLayer()
        setShapeLayerProperties(shapeLayer)
        self.layer.addSublayer(shapeLayer)
        shapeLayerArray.append(shapeLayer)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        path.addLine(to: touch.location(in: self))
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        switch appMode {
        case .draw:
            path.stroke()
            color.setStroke()
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
