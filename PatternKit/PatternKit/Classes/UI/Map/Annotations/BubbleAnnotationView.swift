//
//  BubbleAnnotationView.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

/// An annotation view in the shape of a bubble. Use the `bubbleContentView` to add your views.
open class BubbleAnnotationView: AutoLayoutAnnotationView, DefaultReusable {
    
    // MARK: - Constants
    
    private struct LayoutConstants {
        static let minimumWidth: CGFloat = 22
        static let height: CGFloat = 34

        static let smallMargin: CGFloat = 4
        
        static let arrowWidth: CGFloat = 12
        static let arrowHeight: CGFloat = 10
        static let arrowLeading: CGFloat = 10
    }
    
    // MARK: - Views
    
    /// View for making the glass whiter and adding shadow
    private var backgroundView: UIView!
    
    /// Rounded rect for the content
    private var bubbleView: UIVisualEffectView!
    
    /// Arrow at the bottom of the rect pointing to the location
    private var bottomArrow: CalloutArrow!
    
    /// Content view for the bubble
    public private(set) var bubbleContentView: UIView!
    
    // MARK: - Setup
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    open func configure(withAnnotation annotation: MKAnnotation, usesDarkBackground: Bool) {
        self.annotation = annotation
        
        let effect = UIBlurEffect(style: usesDarkBackground ? .dark : .extraLight)
        bubbleView.effect = effect
        bottomArrow.visualEffectView.effect = effect
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowRadius = 4
        backgroundView.layer.cornerRadius = 4
        backgroundView.layer.shouldRasterize = true
        backgroundView.layer.rasterizationScale = UIScreen.main.scale
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundView)
        
        bottomArrow = CalloutArrow(effectStyle: .dark)
        bottomArrow.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomArrow)
        
        bubbleView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        bubbleView.layer.cornerRadius = 4
        bubbleView.layer.masksToBounds = true
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        
        bubbleContentView = UIView()
        bubbleContentView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.contentView.addSubview(bubbleContentView)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            
            contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: LayoutConstants.minimumWidth),
            contentView.heightAnchor.constraint(equalToConstant: LayoutConstants.height),
            
            bubbleContentView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: LayoutConstants.smallMargin),
            bubbleContentView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -LayoutConstants.smallMargin),
            bubbleContentView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -LayoutConstants.smallMargin),
            bubbleContentView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: LayoutConstants.smallMargin),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            bottomArrow.topAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            bottomArrow.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomArrow.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: LayoutConstants.arrowLeading),
            bottomArrow.widthAnchor.constraint(equalToConstant: LayoutConstants.arrowWidth),
            bottomArrow.heightAnchor.constraint(equalToConstant: LayoutConstants.arrowHeight),
        ])
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Change the center to be the arrow point by moving left by half the width minus the middle of the arrow, then up by half the height
        centerOffset = CGPoint(x: ((frame.width / 2) - LayoutConstants.arrowLeading - (LayoutConstants.arrowWidth / 2)), y: -(frame.height / 2))
        backgroundView.layer.shadowPath = CGPath(rect: CGRect.init(x: 0, y: 0, width: bounds.width, height: LayoutConstants.height - LayoutConstants.arrowHeight), transform: nil)
        
    }
}

/// An upside down triangle view which replicates the bottom of a MKMapView callout bubble
fileprivate class CalloutArrow: UIView {
    
    public var visualEffectView: UIVisualEffectView!
    private var backgroundView: UIView!
    private var shadowView: UIView!
    
    init(frame: CGRect = .zero, effectStyle: UIBlurEffectStyle) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        shadowView = UIView()
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 4
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        addSubview(shadowView)
        
        backgroundView = UIView()
        backgroundView.backgroundColor = .white
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: effectStyle))
        visualEffectView.frame = frame
        addSubview(visualEffectView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        visualEffectView.frame = bounds
        backgroundView.frame = bounds
        shadowView.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Get height and width
        let layerHeight = layer.frame.height
        let layerWidth = layer.frame.width
        
        // Create path
        let bezierPath = UIBezierPath()
        
        // Draw points
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: layerWidth / 2, y: layerHeight))
        bezierPath.addLine(to: CGPoint(x: layerWidth, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        bezierPath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        
        let shapeLayer2 = CAShapeLayer()
        shapeLayer2.path = bezierPath.cgPath
        
        visualEffectView.layer.mask = shapeLayer
        backgroundView.layer.mask = shapeLayer2
        shadowView.layer.shadowPath = bezierPath.cgPath
    }
}
