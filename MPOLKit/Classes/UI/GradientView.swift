//
//  GradientView.swift
//  MPOLKit
//
//  Created by Rod Brown on 8/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// A view for displaying a gradient of colors.
///
/// `GradientView` uses Core Graphics to create gradients, rather than Core Animation
/// and `CAGradientLayer`. Core Animation doesn't support dithering, so gradients tend
/// to come out with banding that ruins the effect.
public class GradientView: UIView {
    
    /// The gradient directions available on GradientView.
    public enum Direction {
        /// Vertical gradient. Colors will be drawn in the order top-to-bottom.
        case vertical
        /// Horizontal gradient. Colors will be drawn from the leading-to-trailing.
        case horizontal
    }
    
    
    /// The gradient direction. The default is `.vertical`.
    public var gradientDirection: Direction = .vertical {
        didSet { if gradientDirection != oldValue { setNeedsDisplay() } }
    }
    
    
    /// The colors for the gradient. The default is none.
    ///
    /// There are optimizations that avoid drawing a full gradient, an requiring re-drawing
    /// with single colors when resizing, when there is only one color. Gradient view also
    /// toggles its own opacity to optimize when the colors are fully opaque.
    public var gradientColors: [UIColor] = [] {
        didSet {
            if gradientColors != oldValue {
                let colorCount = gradientColors.count
                
                // Only set to have a redraw if we have multiple colors.
                contentMode = colorCount > 1 ? .redraw : .scaleToFill
                
                // set opacity on the basis of the colors - if we have at least one color and they're all opaque, we can safely set opaque.
                isOpaque = colorCount > 0 && gradientColors.contains(where: {
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
                let isRightToLeft: Bool
                if #available(iOS 10, *) {
                    isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
                } else {
                    isRightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
                }
                start = CGPoint(x: isRightToLeft ? rect.minX : rect.maxX, y: bounds.midY)
                end   = CGPoint(x: isRightToLeft ? rect.maxX : rect.minX, y: bounds.midY)
            }
            context.drawLinearGradient(gradient, start: start, end: end, options: [])
        } else {
            // we don't have multiple colors, or we couldn't initialize the gradient. Fall back to filling space.
            let correctColor = gradientColors[0]
            correctColor.set()
            UIRectFill(bounds)
        }
    }
    
    public override var semanticContentAttribute: UISemanticContentAttribute  {
        didSet {
            if semanticContentAttribute == oldValue || gradientDirection != .horizontal { return }
            setNeedsDisplay()
            
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 10, *),
            gradientDirection == .horizontal && traitCollection.layoutDirection != previousTraitCollection?.layoutDirection {
            setNeedsDisplay()
        }
    }

}
