//
//  IncidentAnnotationView.swift
//  MPOLKit
//
//  Created by Kyle May on 2/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class IncidentAnnotationView: AutoLayoutAnnotationView {

    public static let defaultReuseIdentifier = "IncidentAnnotationView"
    
    // MARK: - Constants
    
    private struct LayoutConstants {
        static let minimumWidth: CGFloat = 112
        static let height: CGFloat = 34
        static let priorityIconWidth: CGFloat = 24
        static let priorityIconHeight: CGFloat = 16
        static let priorityIconTextMargin: CGFloat = 4
        
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
    
    /// Top line label in the bubble
    private var titleLabel: UILabel!
    
    /// Rounded rect showing the priority level colour
    private var priorityBackground: UIView!
    
    /// Label inside priority rect showing the priority level text
    private var priorityLabel: UILabel!

    // MARK: - Setup
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    public func configure(withAnnotation annotation: MKAnnotation, priorityText: String, priorityTextColor: UIColor, priorityFillColor: UIColor, priorityBorderColor: UIColor, usesDarkBackground: Bool) {
        self.annotation = annotation
        
        let effect = UIBlurEffect(style: usesDarkBackground ? .dark : .extraLight)
        let titleColor = usesDarkBackground ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.2, green: 0.2039215686, blue: 0.2274509804, alpha: 1)
        
        bubbleView.effect = effect
        bottomArrow.visualEffectView.effect = effect
        titleLabel.textColor = titleColor
        
        titleLabel.text = [annotation.title ?? "", annotation.subtitle ?? ""].joined()
        priorityLabel.text = priorityText
        
        priorityBackground.backgroundColor = priorityFillColor
        priorityBackground.layer.borderColor = priorityBorderColor.cgColor
        priorityLabel.textColor = priorityTextColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        
        backgroundView = UIView()
        backgroundView.backgroundColor = .clear//UIColor.white.withAlphaComponent(0.8)
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowRadius = 4
        backgroundView.layer.cornerRadius = 4
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
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        titleLabel.textColor = #colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3803921569, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.contentView.addSubview(titleLabel)
        
        priorityBackground = UIView()
        priorityBackground.layer.cornerRadius = 2
        priorityBackground.layer.borderWidth = 1
        priorityBackground.backgroundColor = .gray
        priorityBackground.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.contentView.addSubview(priorityBackground)
        
        priorityLabel = UILabel()
        priorityLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.bold)
        priorityLabel.textAlignment = .center
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityBackground.addSubview(priorityLabel)
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
            
            titleLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: priorityBackground.trailingAnchor, constant: LayoutConstants.smallMargin),
            titleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -LayoutConstants.smallMargin),
            
            priorityBackground.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            priorityBackground.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: LayoutConstants.smallMargin),
            priorityBackground.widthAnchor.constraint(equalToConstant: LayoutConstants.priorityIconWidth),
            priorityBackground.heightAnchor.constraint(equalToConstant: LayoutConstants.priorityIconHeight),
            
            priorityLabel.topAnchor.constraint(equalTo: priorityBackground.topAnchor, constant: LayoutConstants.priorityIconTextMargin),
            priorityLabel.leadingAnchor.constraint(equalTo: priorityBackground.leadingAnchor, constant: LayoutConstants.priorityIconTextMargin),
            priorityLabel.trailingAnchor.constraint(equalTo: priorityBackground.trailingAnchor, constant: -LayoutConstants.priorityIconTextMargin),
            priorityLabel.bottomAnchor.constraint(equalTo: priorityBackground.bottomAnchor, constant: -LayoutConstants.priorityIconTextMargin),
            
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
