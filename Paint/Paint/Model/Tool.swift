//
//  Tool.swift
//  Paint
//
//  Created by LIUBOU KOZUS on 11/29/20.
//

import Foundation

enum Tool: CaseIterable {
    
    case line
    case ellipse
    case rectangle
    
    var name: String {
        switch self {
        case .line:
            return "Line"
        case .ellipse:
            return "Ellipse"
        case .rectangle:
            return "Rectangle"
        }
    }
}
