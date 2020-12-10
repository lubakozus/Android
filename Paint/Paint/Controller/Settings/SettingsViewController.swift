//
//  SettingsViewController.swift
//  Paint
//
//  Created by LIUBOU KOZUS on 12/8/20.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    
    func settingsViewController(_ settingsViewController: SettingsViewController, didUpdateSettings settings: Settings)
}

class SettingsViewController: UIViewController {

    weak var delegate: SettingsViewControllerDelegate?
    var defaultSettings: Settings!
    private var settings: Settings! {
        didSet {
            
            strokeColorImageView.tintColor = settings.strokeColor
            fillColorImageView.tintColor = settings.fillColor
            toolLabel.text = settings.tool.name
            
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            
            lineWidthLabel.text = formatter.string(from: NSNumber(floatLiteral: Double(settings.lineWidth)))
            lineWidthSlider.value = Float(settings.lineWidth)
            
            opacityLabel.text = formatter.string(from: NSNumber(floatLiteral: Double(settings.opacity)))
            opacitySlider.value = Float(settings.opacity)
            
            updateExample()
            
            delegate?.settingsViewController(self, didUpdateSettings: settings)
        }
    }
    
    @IBOutlet weak var strokeColorImageView: UIImageView!
    @IBOutlet weak var fillColorImageView: UIImageView!
    @IBOutlet weak var toolLabel: UILabel!
    @IBOutlet weak var lineWidthLabel: UILabel!
    @IBOutlet weak var lineWidthSlider: UISlider!
    @IBOutlet weak var opacityLabel: UILabel!
    @IBOutlet weak var opacitySlider: UISlider!
    @IBOutlet weak var previewImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings = defaultSettings
    }
    
    @IBAction func strokeColorButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Color", message: nil, preferredStyle: .actionSheet)
        UIColor.defaultPalette.forEach { color, name in
            let action = UIAlertAction(title: name, style: .default) { [unowned self] _ in
                self.settings.strokeColor = color
            }
            alert.addAction(action)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @IBAction func fillColorButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Color", message: nil, preferredStyle: .actionSheet)
        UIColor.defaultPalette.forEach { color, name in
            let action = UIAlertAction(title: name, style: .default) { [unowned self] _ in
                self.settings.fillColor = color
            }
            alert.addAction(action)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @IBAction func toolButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Tool", message: nil, preferredStyle: .actionSheet)
        Tool.allCases.forEach { tool in
            let action = UIAlertAction(title: tool.name, style: .default) { [unowned self] _ in
                self.settings.tool = tool
            }
            alert.addAction(action)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @IBAction func lineWidthSliderValueChanged(_ sender: UISlider) {
        settings.lineWidth = CGFloat(sender.value)
    }
    
    @IBAction func opacitySliderValueChanged(_ sender: UISlider) {
        settings.opacity = CGFloat(sender.value)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateExample() {
        UIGraphicsBeginImageContextWithOptions(previewImageView.frame.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let fromPoint = CGPoint(x: settings.lineWidth / 2, y: settings.lineWidth / 2)
        let toPoint = CGPoint(x: previewImageView.bounds.maxX - settings.lineWidth / 2, y: previewImageView.bounds.maxY - settings.lineWidth / 2)
        
        let points = [fromPoint, toPoint]
        let minX = points.map({ $0.x }).min()!
        let maxX = points.map({ $0.x }).max()!
        let minY = points.map({ $0.y }).min()!
        let maxY = points.map({ $0.y }).max()!
        let width = maxX - minX
        let height = maxY - minY
        
        switch settings.tool {
        case .line:
            context.move(to: fromPoint)
            context.addLine(to: toPoint)
        case .ellipse:
            let rect = CGRect(x: minX, y: minY, width: width, height: height)
            context.addEllipse(in: rect)
        case .rectangle:
            context.addRect(CGRect(x: minX, y: minY, width: width, height: height))
        }
        
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(settings.lineWidth)
        context.setStrokeColor(settings.strokeColor.cgColor)
        context.setFillColor(settings.fillColor.cgColor)
        context.drawPath(using: .fillStroke)
        
        previewImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        previewImageView.alpha = settings.opacity
        
        UIGraphicsEndImageContext()
    }
}
