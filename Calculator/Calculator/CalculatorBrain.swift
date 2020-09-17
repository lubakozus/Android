//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by ILLIA HARKAVY on 9/17/20.
//  Copyright © 2020 ILLIA HARKAVY. All rights reserved.
//

import Foundation
import MathParser

struct CalculatorBrain {
    
    var outputString = ""
    
    var trailingOperator: BrainOperator? {
        var outputString = self.outputString
        while outputString.hasSuffix("(") {
            outputString.removeLast()
        }
        return BrainOperator.allCases.first { brainOperator in
            outputString.hasSuffix(brainOperator.rawValue)
        }
    }
    
    var trailingNumber: String? {
        var outputString = self.outputString
        var trailingNumber = ""
        while let last = outputString.last, last.isNumber || last == "." {
            trailingNumber.insert(last, at: trailingNumber.startIndex)
            outputString.removeLast()
        }
        if trailingNumber.isEmpty {
            return nil
        } else {
            return trailingNumber
        }
    }
    
    mutating func addDigit(_ digit: String) {
        if !outputString.hasSuffix(")"), trailingOperator?.hasPostfixOperand ?? true {
            outputString = outputString + digit
        }
    }
    
    mutating func addOperator(_ brainOperator: BrainOperator) {
        func add() {
            if brainOperator.requiresBracketsForPostfixOperand {
                outputString = outputString + brainOperator.rawValue + "("
            } else {
                outputString = outputString + brainOperator.rawValue
            }
        }
        if brainOperator.hasPrefixOperand {
            if trailingNumber != nil || outputString.hasSuffix(")") || !(trailingOperator?.hasPostfixOperand ?? false) {
                add()
            }
        } else {
            if !outputString.hasSuffix(")"), trailingOperator?.hasPostfixOperand ?? false {
                add()
            }
        }
    }
    
    mutating func addOpenBracket() {
        if trailingNumber == nil, !outputString.hasSuffix(")") {
            outputString = outputString + "("
        }
    }
    
    mutating func addCloseBracket() {
        if trailingNumber != nil || outputString.hasSuffix(")"), outputString.countAll("(") > outputString.countAll(")") {
            outputString = outputString + ")"
        }
    }
    
    mutating func addPoint() {
        if let trailingNumber = self.trailingNumber, !trailingNumber.contains(".") {
            outputString = outputString + "."
        }
    }
    
    mutating func delete() {
        if let trailingNumber = self.trailingNumber {
            outputString.removeLast(trailingNumber.count)
        } else if let trailingOperator = self.trailingOperator {
            while outputString.hasSuffix("(") {
                outputString.removeLast()
            }
            outputString.removeLast(trailingOperator.rawValue.count)
        }
    }
    
    mutating func deleteAll() {
        outputString = ""
    }
    
    mutating func calculate() {
        if let result = try? outputString.replacingOccurrences(of: "%", with: "*0.01").evaluate() {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 5
            outputString = formatter.string(from: NSNumber(value: result))!
        }
    }
    
}

extension Collection where Element: Equatable {
    
    func countAll(where check: (Element) -> Bool) -> Int {
        filter(check).count
    }
    
    func countAll(_ element: Element) -> Int {
        countAll(where: { $0 == element })
    }
}
