//
//  ViewController.swift
//  Calculator
//
//  Created by ILLIA HARKAVY on 9/17/20.
//  Copyright © 2020 ILLIA HARKAVY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var brain: CalculatorBrain! {
        
        didSet {
            textField.text = brain.outputString
            
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brain = CalculatorBrain()
    }


    @IBAction func digitPressed(_ sender: UIButton) {

        brain.addDigit(sender.currentTitle!)
    }
    @IBAction func pointPressed(_ sender: UIButton) {
        brain.addPoint()
    }
    @IBAction func operatorPressed(_ sender: UIButton) {
        if let brainOperator = BrainOperator(rawValue: sender.currentTitle!) {
            brain.addOperator(brainOperator)
        }
    }
    @IBAction func bracketOpenPressed(_ sender: UIButton) {
        brain.addOpenBracket()
    }
    @IBAction func bracketClosedPressed(_ sender: UIButton) {
        brain.addCloseBracket()
    }
    @IBAction func deletePressed(_ sender: UIButton) {
        brain.delete()
    }
    @IBAction func deleteAllPressed(_ sender: UIButton) {
        brain.deleteAll()
    }
    @IBAction func calculatePressed(_ sender: UIButton) {
        brain.calculate()
    }
}

