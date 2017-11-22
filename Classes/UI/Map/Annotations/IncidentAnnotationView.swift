//
//  IncidentAnnotationView.swift
//  MPOLKit
//
//  Created by Kyle May on 2/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class IncidentAnnotationView: MKAnnotationView {

    public static let defaultReuseIdentifier = "IncidentAnnotationView"
    
    // MARK: - Constants
    
    private struct LayoutConstants {
        static let minimumWidth: CGFloat = 112
        static let height: CGFloat = 48
        static let priorityIconWidth: CGFloat = 24
        static let priorityIconHeight: CGFloat = 16
        static let priorityIconTextMargin: CGFloat = 4
        
        static let largeMargin: CGFloat = 12
        static let smallMargin: CGFloat = 4

        static let arrowWidth: CGFloat = 24
        static let arrowHeight: CGFloat = 16
    }
    
    // MARK: - Views
    
    /// Rounded rect for the content
    private var bubbleView: UIView!
    
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
    
    public func configure(withAnnotation annotation: MKAnnotation, priorityColor: UIColor, priorityText: String, priorityFilled: Bool, usesDarkBackground: Bool) {
        self.annotation = annotation
        
        let bubbleColor = usesDarkBackground ? .primaryGray : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let titleColor = usesDarkBackground ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : .primaryGray
        
        bubbleView.backgroundColor = bubbleColor
        bottomArrow.color = bubbleColor
        titleLabel.textColor = titleColor
        
        titleLabel.text = [annotation.title ?? "", annotation.subtitle ?? ""].removeNils().joined(separator: " ")
        priorityLabel.text = priorityText
        
        // If we want a filled in priority icon
        if priorityFilled {
            priorityBackground.backgroundColor = priorityColor
            priorityBackground.layer.borderColor = UIColor.clear.cgColor
            priorityLabel.textColor = .black
        } else {
            priorityBackground.backgroundColor = .clear
            priorityBackground.layer.borderColor = priorityColor.cgColor
            priorityLabel.textColor = priorityColor
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 4
        
        bubbleView = UIView()
        bubbleView.layer.cornerRadius = 10
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleView)
        
        bottomArrow = CalloutArrow(color: .white)
        bottomArrow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomArrow)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        titleLabel.textColor = #colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3803921569, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(titleLabel)
        
        priorityBackground = UIView()
        priorityBackground.layer.cornerRadius = 2
        priorityBackground.layer.borderWidth = 1
        priorityBackground.backgroundColor = .gray
        priorityBackground.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(priorityBackground)
        
        priorityLabel = UILabel()
        priorityLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.bold)
        priorityLabel.textAlignment = .center
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityBackground.addSubview(priorityLabel)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: LayoutConstants.minimumWidth),
            heightAnchor.constraint(equalToConstant: LayoutConstants.height),
            
            titleLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: priorityBackground.trailingAnchor, constant: LayoutConstants.largeMargin),
            titleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -LayoutConstants.largeMargin),
            
            priorityBackground.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            priorityBackground.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: LayoutConstants.largeMargin),
            priorityBackground.widthAnchor.constraint(equalToConstant: LayoutConstants.priorityIconWidth),
            priorityBackground.heightAnchor.constraint(equalToConstant: LayoutConstants.priorityIconHeight),
            
            priorityLabel.topAnchor.constraint(equalTo: priorityBackground.topAnchor, constant: LayoutConstants.priorityIconTextMargin),
            priorityLabel.leadingAnchor.constraint(equalTo: priorityBackground.leadingAnchor, constant: LayoutConstants.priorityIconTextMargin),
            priorityLabel.trailingAnchor.constraint(equalTo: priorityBackground.trailingAnchor, constant: -LayoutConstants.priorityIconTextMargin),
            priorityLabel.bottomAnchor.constraint(equalTo: priorityBackground.bottomAnchor, constant: -LayoutConstants.priorityIconTextMargin),
            
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor),
            bubbleView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            bottomArrow.topAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            bottomArrow.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomArrow.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -LayoutConstants.arrowWidth),
            bottomArrow.widthAnchor.constraint(equalToConstant: LayoutConstants.arrowWidth),
            bottomArrow.heightAnchor.constraint(equalToConstant: LayoutConstants.arrowHeight),
        ])
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Change the center to be the arrow point by moving left by half the width minus the middle of the arrow, then up by half the height
        centerOffset = CGPoint(x: -((frame.width / 2) - LayoutConstants.arrowWidth - (LayoutConstants.arrowWidth / 2)), y: -(frame.height / 2))
    }
}

/// An upside down triangle view which replicates the bottom of a MKMapView callout bubble
private class CalloutArrow: UIView {
    var color: UIColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    init(frame: CGRect = .zero, color: UIColor) {
        self.color = color
        
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    override func draw(_ rect: CGRect) {
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
        
        // Apply color
        color.setFill()
        bezierPath.fill()
        
        // Mask to path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        layer.mask = shapeLayer
    }
}
