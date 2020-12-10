//
//  CGPoint.swift
//  Paint
//
//  Created by LIUBOU KOZUS on 12/9/20.
//

import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
}
