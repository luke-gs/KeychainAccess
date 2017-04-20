//
//  SearchNavigationField.swift
//  MPOL
//
//  Created by Rod Brown on 6/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class SearchNavigationField: UIView {
    
    // MARK: - Public properties
    
    public weak var delegate: SearchNavigationFieldDelegate?
    
    public let typeLabel = RoundedRectLabel(frame: .zero)
    
    public let titleLabel = UILabel(frame: .zero)
    
    public let resultCountLabel = UILabel(frame: .zero)
    
    @NSCopying open var fieldBackgroundColor: UIColor! = .white {
        didSet {
            if fieldBackgroundColor == nil {
                fieldBackgroundColor = .white
            }
            if fieldBackgroundColor == oldValue { return }
            
            mainButton.setBackgroundImage(.resizableRoundedImage(cornerRadius: 4.0, borderWidth: 0.0, borderColor: nil, fillColor: fieldBackgroundColor), for: .normal)
        }
    }
    
    @NSCopying open var clearButtonColor: UIColor! = .gray {
        didSet {
            if clearButtonColor == nil {
                clearButtonColor = .gray
            }
            if clearButtonColor == oldValue { return }
            
            clearButton.tintColor = clearButtonColor
        }
    }
    
    
    // MARK: - Private properties
    
    private let mainButton = UIButton(type: .custom)
    
    private let clearButton = UIButton(type: .custom)
    
    
    // MARK: - Initializers
    
    public init() {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 32.0))
        
        let mainButtonBackground = UIImage.resizableRoundedImage(cornerRadius: 4.0, borderWidth: 0.0, borderColor: nil, fillColor: fieldBackgroundColor)
        
        mainButton.frame = self.bounds
        mainButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainButton.setBackgroundImage(mainButtonBackground, for: .normal)
        mainButton.adjustsImageWhenHighlighted = false
        mainButton.addTarget(self, action: #selector(mainButtonDidSelect), for: .primaryActionTriggered)
        addSubview(mainButton)
        
        clearButton.setImage(#imageLiteral(resourceName: "SearchBarClearButton"), for: .normal)
        clearButton.tintColor = .gray
        clearButton.adjustsImageWhenHighlighted = true
        
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.backgroundColor = tintColor
        typeLabel.textColor = .white
        typeLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh + 10, for: .horizontal)
        typeLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17.0, weight: UIFontWeightBold)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.allowsDefaultTighteningForTruncation = true
        
        resultCountLabel.translatesAutoresizingMaskIntoConstraints = false
        resultCountLabel.font = .systemFont(ofSize: 13.0, weight: UIFontWeightRegular)
        resultCountLabel.allowsDefaultTighteningForTruncation = true
        resultCountLabel.adjustsFontSizeToFitWidth = true
        resultCountLabel.minimumScaleFactor = 0.6
        resultCountLabel.setContentCompressionResistancePriority(titleLabel.contentCompressionResistancePriority(for: .horizontal) - 1, for: .horizontal)
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearButtonDidSelect), for: .primaryActionTriggered)
        clearButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        clearButton.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        
        addSubview(resultCountLabel)
        addSubview(titleLabel)
        addSubview(typeLabel)
        addSubview(clearButton)
        
        let views: [String: UIView] = [
            "type"  : typeLabel,
            "title" : titleLabel,
            "result": resultCountLabel,
            "clear" : clearButton
        ]
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[type]-[title]-(>=0)-[result]-30-|", options: [.alignAllCenterY], metrics: nil, views: views)
        constraints += [
            NSLayoutConstraint(item: typeLabel,   attribute: .centerY,  relatedBy: .equal, toItem: self, attribute: .centerY),
            NSLayoutConstraint(item: clearButton, attribute: .centerX,  relatedBy: .equal, toItem: self, attribute: .trailing, constant: -15.0),
            NSLayoutConstraint(item: clearButton, attribute: .centerY,  relatedBy: .equal, toItem: self, attribute: .centerY),
            NSLayoutConstraint(item: clearButton, attribute: .width,    relatedBy: .greaterThanOrEqual,  toConstant: 44.0),
            NSLayoutConstraint(item: clearButton, attribute: .height,   relatedBy: .greaterThanOrEqual,  toConstant: 44.0),
            NSLayoutConstraint(item: titleLabel,  attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: resultCountLabel, attribute: .leading, constant: 8.0, priority: 200)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    
    // MARK: - Overrides
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if effectiveUserInterfaceLayoutDirection == .rightToLeft {
            resultCountLabel.isHidden = resultCountLabel.frame.maxX + 8.0 > titleLabel.frame.minX
        } else {
            resultCountLabel.isHidden = resultCountLabel.frame.minX < titleLabel.frame.maxX + 8.0
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Make the bar appear bigger for touch handling purposes.
        //
        // We say "yes" if the point is within 6 points of our bounds in the height dimension, because 32 points
        // (our default) is not a good touch target. 44 makes it exactly the recommended for iOS.
        return bounds.insetBy(dx: 0.0, dy: -6.0).contains(point)
    }
    
    
    // MARK: - Private methods
    
    @objc private func mainButtonDidSelect() {
        delegate?.searchNavigationFieldDidSelect(self)
    }
    
    @objc private func clearButtonDidSelect() {
        delegate?.searchNavigationFieldDidSelectClear(self)
    }
    
}

public protocol SearchNavigationFieldDelegate: class {
    
    func searchNavigationFieldDidSelect(_ field: SearchNavigationField)
    
    func searchNavigationFieldDidSelectClear(_ field: SearchNavigationField)
    
}
