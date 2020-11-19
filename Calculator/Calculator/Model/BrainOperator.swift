//
//  Operator.swift
//  Calculator


import Foundation

enum BrainOperator: String, CaseIterable {
    
    case plus = "+"
    case minus = "−"
    case root = "√"
    case cubicroot = "∛"
    case multiply = "×"
    case divide = "÷"
    case percent = "%"
    case sin = "sin"
    case cos = "cos"
    
    var hasPostfixOperand: Bool {
        switch self {
        case .percent:
            return false
        default:
            return true
        }
    }
    
    var hasPrefixOperand: Bool {
        switch self {
        case .plus, .minus, .multiply, .divide, .percent:
            return true
        case .root, .cubicroot, .sin, .cos:
            return false
        }
    }
    
    var requiresBracketsForPostfixOperand: Bool {
        switch self {
        case .sin, .cos:
            return true
        default:
            return false
        }
    }
}
