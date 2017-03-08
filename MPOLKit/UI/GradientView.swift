//
//  GradientView.swift
//  MPOLKit
//
//  Created by Rod Brown on 8/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class GradientView: UIView {
    
    public enum Direction: Int {
        case vertical
        case horizontal
    }
    
    public var gradientDirection: Direction = .vertical {
        didSet { if gradientDirection != oldValue { setNeedsDisplay() } }
    }
    
    public var gradientColors: [UIColor] = [] {
        didSet {
            if gradientColors != oldValue {
                let hasColors = gradientColors.isEmpty == false
                
                // Only set to have a redraw if we have colors.
                contentMode = hasColors ? .redraw : .scaleToFill
                
                // set opacity on the basis of the colors - if we have at least one color and they're all opaque, we can safely set opaque.
                isOpaque = hasColors && gradientColors.contains(where: {
                    var alphaComponent: CGFloat = 0.0
                    $0.getWhite(nil, alpha: &alphaComponent)
                    return alphaComponent < 1.0
                }) == false
                
                setNeedsDisplay()
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isOpaque = false
    }
    
    public override func draw(_ rect: CGRect) {
        let colorCount = gradientColors.count
        if colorCount == 0 { return }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let bounds = self.bounds
        
        if colorCount > 1,
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors.map({ $0.cgColor }) as CFArray, locations: nil) {
            // Draw the gradient
            let start: CGPoint
            let end:   CGPoint
            if gradientDirection == .vertical {
                start = CGPoint(x: rect.midX, y: bounds.minY)
                end   = CGPoint(x: rect.midX, y: bounds.maxY)
            } else {
                start = CGPoint(x: rect.minX, y: bounds.midY)
                end   = CGPoint(x: rect.maxX, y: bounds.midY)
            }
            context.drawLinearGradient(gradient, start: start, end: end, options: [])
        } else {
            // we don't have multiple colors, or we couldn't initialize the gradient. Fall back to filling space.
            let correctColor = gradientColors[0]
            correctColor.set()
            UIRectFill(bounds)
        }
    }

}
