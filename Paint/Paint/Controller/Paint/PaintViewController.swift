//
//  ViewController.swift
//  Paint
//
//  Created by LIUBOU KOZUS on 11/29/20.
//

import UIKit
import AVFoundation

class PaintViewController: UIViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    var startPoint = CGPoint.zero
    var lastPoint = CGPoint.zero
    var isMoved = false
    var isLongPressed = false
    var longPressTimer: Timer?
    
    var settings = Settings(tool: .ellipse, fillColor: .white, strokeColor: .gray, lineWidth: 10, opacity: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIBarButtonItem) {
        mainImageView.image = nil
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        guard let image = mainImageView.image else {
            return
        }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activity, animated: true)
    }
    
    @IBAction func imageButtonTapped(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum
            picker.allowsEditing = false
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        let settingsViewController = SettingsViewController.instantiate()
        settingsViewController.defaultSettings = settings
        settingsViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        present(navigationController, animated: true)
    }
    
    func drawShape(_ shape: Shape, from fromPoint: CGPoint, to toPoint: CGPoint, redraw: Bool) {
        UIGraphicsBeginImageContextWithOptions(mainImageView.frame.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        if !redraw {
            tempImageView.image?.draw(in: mainImageView.bounds)
        }
        
        let points = [fromPoint, toPoint]
        let minX = points.map({ $0.x }).min()!
        let maxX = points.map({ $0.x }).max()!
        let minY = points.map({ $0.y }).min()!
        let maxY = points.map({ $0.y }).max()!
        let width = maxX - minX
        let height = maxY - minY
        let maxSide = max(width, height)
        
        switch shape {
        case .line:
            context.move(to: fromPoint)
            context.addLine(to: toPoint)
        case .ellipse:
            let rect = CGRect(x: minX, y: minY, width: width, height: height)
            context.addEllipse(in: rect)
        case .circle:
            context.addEllipse(in: CGRect(x: minX, y: minY, width: maxSide, height: maxSide))
        case .rectangle:
            context.addRect(CGRect(x: minX, y: minY, width: width, height: height))
        case .square:
            context.addRect(CGRect(x: minX, y: minY, width: maxSide, height: maxSide))
        }
        
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(settings.lineWidth)
        context.setStrokeColor(settings.strokeColor.cgColor)
        context.setFillColor(settings.fillColor.cgColor)
        context.drawPath(using: .fillStroke)
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = settings.opacity
        
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        isMoved = false
        lastPoint = touch.location(in: mainImageView)
        startPoint = touch.location(in: mainImageView)
        
        isLongPressed = false
        longPressTimer = .scheduledTimer(withTimeInterval: 1, repeats: false) { [unowned self] _ in
            isLongPressed = true
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        isMoved = true
        let currentPoint = touch.location(in: mainImageView)
        
        switch settings.tool {
        case .line:
            if isLongPressed {
                drawShape(.line, from: startPoint, to: currentPoint, redraw: true)
            } else {
                drawShape(.line, from: lastPoint, to: currentPoint, redraw: false)
            }
        case .ellipse:
            if isLongPressed {
                drawShape(.circle, from: startPoint, to: currentPoint, redraw: true)
            } else {
                drawShape(.ellipse, from: startPoint, to: currentPoint, redraw: true)
            }
        case .rectangle:
            if isLongPressed {
                drawShape(.square, from: startPoint, to: currentPoint, redraw: true)
            } else {
                drawShape(.rectangle, from: startPoint, to: currentPoint, redraw: true)
            }
        }
        
        lastPoint = currentPoint
        
        if currentPoint.distance(to: startPoint) > 10 {
            longPressTimer?.invalidate()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMoved {
            drawShape(.line, from: lastPoint, to: lastPoint, redraw: true)
        }
        
        UIGraphicsBeginImageContextWithOptions(mainImageView.frame.size, false, UIScreen.main.scale)
        mainImageView.image?.draw(in: mainImageView.bounds, blendMode: .normal, alpha: 1)
        tempImageView?.image?.draw(in: mainImageView.bounds, blendMode: .normal, alpha: settings.opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
        
        longPressTimer?.invalidate()
    }
}

extension PaintViewController: SettingsViewControllerDelegate {
    
    func settingsViewController(_ settingsViewController: SettingsViewController, didUpdateSettings settings: Settings) {
        self.settings = settings
    }
}

extension PaintViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            UIGraphicsBeginImageContextWithOptions(mainImageView.frame.size, false, UIScreen.main.scale)
            mainImageView.image?.draw(in: mainImageView.bounds, blendMode: .normal, alpha: 1)
            let rect = AVMakeRect(aspectRatio: image.size, insideRect: mainImageView.bounds)
            image.draw(in: rect, blendMode: .normal, alpha: 1)
            mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
}



