//
//  LocationMapDirectionCollectionViewCell.swift
//  Pods
//
//  Created by RUI WANG on 13/9/17.
//
//

import UIKit

open class LocationMapDirectionCollectionViewCell: CollectionViewFormCell {

    /// The description label, used for diplaying the full address of selected location
    public let descriptionLabel: UILabel = UILabel(frame: .zero)

    /// The distance label, used for diaplaying the estimate distance
    /// from the current location to selected target location
    public let distanceLabel: UILabel = UILabel(frame: .zero)

    public let walkingEstButton: CustomSubtitleButton = CustomSubtitleButton(type: .custom)
    
    public let automobileEstButton: CustomSubtitleButton = CustomSubtitleButton(type: .custom)
    
    public let streetViewButton: CustomSubtitleButton = CustomSubtitleButton(type: .custom)
    
    private var directionStackView: UIStackView = UIStackView()
    
    // MARK: - Initialization
    
    override open func commonInit() {
        super.commonInit()
        
        accessibilityTraits |= UIAccessibilityTraitStaticText
        
        let contentView = self.contentView
        let descriptionLabel = self.descriptionLabel
        let distanceLabel = self.distanceLabel
        let walkingEstButton = self.walkingEstButton
        let automobileEstButton = self.automobileEstButton
        let streetViewButton = self.streetViewButton
        let directionStackView = self.directionStackView
        
        descriptionLabel.textAlignment = .left
        distanceLabel.textAlignment = .right
        descriptionLabel.numberOfLines = 2
        distanceLabel.numberOfLines = 1
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        walkingEstButton.translatesAutoresizingMaskIntoConstraints = false
        automobileEstButton.translatesAutoresizingMaskIntoConstraints = false
        streetViewButton.translatesAutoresizingMaskIntoConstraints = false
        directionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        directionStackView.axis = .horizontal
        directionStackView.distribution = .fillEqually
        directionStackView.spacing = 20.0
        directionStackView.alignment = .center
        
        directionStackView.addArrangedSubview(walkingEstButton)
        directionStackView.addArrangedSubview(automobileEstButton)
        directionStackView.addArrangedSubview(streetViewButton)
        
        descriptionLabel.adjustsFontForContentSizeCategory = true
        distanceLabel.adjustsFontForContentSizeCategory = true
        
        let traitCollection = self.traitCollection
        descriptionLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        distanceLabel.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(directionStackView)
        
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        
        descriptionLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        distanceLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        distanceLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)

        let buttonLayoutGuide = UILayoutGuide()
        buttonLayoutGuide.heightAnchor.constraint(equalToConstant: 50)
        contentView.addLayoutGuide(buttonLayoutGuide)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentModeLayoutGuide.leadingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: directionStackView.topAnchor, constant: -20.0),
            descriptionLabel.trailingAnchor.constraint(equalTo: distanceLabel.leadingAnchor),
            
            distanceLabel.topAnchor.constraint(equalTo: descriptionLabel.topAnchor),
            distanceLabel.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            distanceLabel.trailingAnchor.constraint(equalTo: contentModeLayoutGuide.trailingAnchor),

            walkingEstButton.heightAnchor.constraint(equalTo: buttonLayoutGuide.heightAnchor),
            automobileEstButton.heightAnchor.constraint(equalTo: buttonLayoutGuide.heightAnchor),
            streetViewButton.heightAnchor.constraint(equalTo: buttonLayoutGuide.heightAnchor),
            
            directionStackView.leadingAnchor.constraint(equalTo: contentModeLayoutGuide.leadingAnchor, constant: 10.0),
            directionStackView.trailingAnchor.constraint(equalTo: contentModeLayoutGuide.trailingAnchor, constant: -10.0),
            directionStackView.bottomAnchor.constraint(equalTo: contentModeLayoutGuide.bottomAnchor, constant: -10.0),
            directionStackView.heightAnchor.constraint(equalTo: buttonLayoutGuide.heightAnchor)
        ])
    }
    
    // MARK: - Class sizing methods
    
    /// Calculates the minimum content height for a cell, considering the text details.
    ///
    /// - Parameters:
    ///   - title:              The title text for the cell.
    ///   - subtitle:           The subtitle text for the cell.
    ///   - width:              The width constraint for the cell.
    ///   - traitCollection:    The trait collection the cell will be displayed in.
    /// - Returns:      The minumum content height for the cell.
    open class func minimumContentHeight(compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        let titleFont    = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        let subtitleFont = UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        
        let displayScale = traitCollection.currentDisplayScale
        return titleFont.lineHeight.ceiled(toScale: displayScale) + subtitleFont.lineHeight.ceiled(toScale: displayScale) + 50
    }

}
