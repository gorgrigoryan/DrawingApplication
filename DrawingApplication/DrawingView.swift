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
        let condition = appMode == Mode.move
        for shapeLayer in shapeLayerArray {
            shapeLayer.isHidden = condition
        }
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
            pathArray.append(DrawingLine(path: path, color: color))
            path.move(to: touchLocation)
            tool.center = touchLocation
            setNeedsDisplay()
            undoPaths = []
        case .move:
            // TODO: write for cycle for finding needed layer
            setNeedsDisplay()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        
        switch appMode {
        case .draw:
            tool.center = touchLocation
            path.addLine(to: touchLocation)
        case .move:
            if isExistPoint {
                // TODO: move layer if you find needed layer
            }
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
            isExistPoint = false
        }
    }
    
    private func setShapeLayerProperties(_ shapeLayer: CAShapeLayer) {
        shapeLayer.path = path.cgPath
        shapeLayer.frame = bounds
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = brushSize
    }
    
    private func appendNewShapeLayer() {
        let shapeLayer = CAShapeLayer()
        setShapeLayerProperties(shapeLayer)
        layer.addSublayer(shapeLayer)
        
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
            for line in pathArray {
                line.color.setStroke()
                line.path.stroke()
            }
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
