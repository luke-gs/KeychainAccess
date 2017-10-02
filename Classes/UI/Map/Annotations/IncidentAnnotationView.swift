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

    // MARK: - Constants
    
    private struct LayoutConstants {
        static let minimumWidth: CGFloat = 112
        static let height: CGFloat = 72
        static let priorityIconWidth: CGFloat = 24
        static let priorityIconHeight: CGFloat = 16
        static let priorityIconTextMargin: CGFloat = 4
        
        static let largeMargin: CGFloat = 12
        static let smallMargin: CGFloat = 8

        static let arrowWidth: CGFloat = 24
        static let arrowHeight: CGFloat = 16
    }
    
    // MARK: - View Properties
    
    private var priorityText: String
    private var priorityColor: UIColor
    private var priorityBackgroundFilled: Bool
    private var usesDarkBackground: Bool
    private var bubbleColor: UIColor {
        return usesDarkBackground ? #colorLiteral(red: 0.2549019608, green: 0.2509803922, blue: 0.262745098, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    // MARK: - Views
    
    /// Rounded rect for the content
    private var bubbleView: UIView!
    
    /// Arrow at the bottom of the rect pointing to the location
    private var bottomArrow: CalloutArrow!
    
    /// Top line label in the bubble
    private var titleLabel: UILabel!
    
    /// Second line label in the bubble
    private var subtitleLabel: UILabel!
    
    /// Rounded rect showing the priority level colour
    private var priorityBackground: UIView!
    
    /// Label inside priority rect showing the priority level text
    private var priorityLabel: UILabel!

    // MARK: - Setup
    
    public init(annotation: MKAnnotation?, reuseIdentifier: String?, priorityColor: UIColor, priorityText: String, priorityFilled: Bool, usesDarkBackground: Bool) {
        self.usesDarkBackground = usesDarkBackground
        self.priorityText = priorityText
        self.priorityColor = priorityColor
        self.priorityBackgroundFilled = priorityFilled
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
        configureViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        bottomArrow = CalloutArrow(color: bubbleColor)
        bottomArrow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomArrow)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
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
        priorityLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightBold)
        priorityLabel.textAlignment = .center
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        priorityBackground.addSubview(priorityLabel)
        
        subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(subtitleLabel)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: LayoutConstants.minimumWidth),
            heightAnchor.constraint(equalToConstant: LayoutConstants.height),
            
            titleLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: LayoutConstants.smallMargin),
            titleLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: LayoutConstants.largeMargin),
            titleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -LayoutConstants.largeMargin),
            
            priorityBackground.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priorityBackground.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priorityBackground.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -LayoutConstants.smallMargin),
            priorityBackground.widthAnchor.constraint(equalToConstant: LayoutConstants.priorityIconWidth),
            priorityBackground.heightAnchor.constraint(equalToConstant: LayoutConstants.priorityIconHeight),
            
            priorityLabel.topAnchor.constraint(equalTo: priorityBackground.topAnchor, constant: LayoutConstants.priorityIconTextMargin),
            priorityLabel.leadingAnchor.constraint(equalTo: priorityBackground.leadingAnchor, constant: LayoutConstants.priorityIconTextMargin),
            priorityLabel.trailingAnchor.constraint(equalTo: priorityBackground.trailingAnchor, constant: -LayoutConstants.priorityIconTextMargin),
            priorityLabel.bottomAnchor.constraint(equalTo: priorityBackground.bottomAnchor, constant: -LayoutConstants.priorityIconTextMargin),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: priorityBackground.trailingAnchor, constant: LayoutConstants.smallMargin),
            subtitleLabel.topAnchor.constraint(equalTo: priorityBackground.topAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -LayoutConstants.smallMargin),
            subtitleLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -LayoutConstants.smallMargin),
            
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
    
    /// Sets the data on the views from the annotation
    func configureViews() {
        bubbleView.backgroundColor = bubbleColor
        bottomArrow.backgroundColor = bubbleColor

        titleLabel.text = annotation?.title ?? ""
        subtitleLabel.text = annotation?.subtitle ?? ""
        priorityLabel.text = priorityText

        // If we want a filled in priority icon
        if priorityBackgroundFilled {
            priorityBackground.backgroundColor = priorityColor
            priorityBackground.layer.borderColor = UIColor.clear.cgColor
            priorityLabel.textColor = .black
        } else {
            priorityBackground.backgroundColor = .clear
            priorityBackground.layer.borderColor = priorityColor.cgColor
            priorityLabel.textColor = priorityColor
        }
        
        if usesDarkBackground {
            titleLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            titleLabel.textColor = #colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3803921569, alpha: 1)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        centerOffset = CGPoint(x: -((frame.width / 2) - LayoutConstants.arrowWidth - (LayoutConstants.arrowWidth / 2)), y: -(frame.height / 2))
    }
}

/// An upside down triangle view which replicates the bottom of a MKMapView callout bubble
private class CalloutArrow: UIView {
    var color: UIColor
    
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
