//
//  MapFilterToggleRowView.swift
//  MPOLKit
//
//  Created by Kyle May on 17/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class MapFilterToggleRowView: UIView {
    
    public struct LayoutConstants {
        public static let checkboxSpacing: CGFloat = 32
        public static let topMargin: CGFloat = 12
        public static let titleMargin: CGFloat = 8
        /// Checkbox class strangely has a slight leading offset
        public static let checkboxOffset: CGFloat = 5
        public static let separatorHeight: CGFloat = 1
        public static let separatorVerticalMargin: CGFloat = 16
    }
    
    open private(set) var titleLabel: UILabel!
    open private(set) var options: [CheckBox] = []
    open var optionsStackView: UIStackView!
    private var separator: UIView!
    
    
    private let showsSeparator: Bool
    public let toggleRow: MapFilterToggleRow
    
    public init(frame: CGRect = .zero, toggleRow: MapFilterToggleRow, enabledTitleColor: UIColor = #colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1), disabledTitleColor: UIColor = #colorLiteral(red: 0.5215836167, green: 0.5254672766, blue: 0.5528345108, alpha: 0.5), showsSeparator: Bool = false) {
        self.showsSeparator = showsSeparator
        self.toggleRow = toggleRow
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.text = toggleRow.title
        titleLabel.textColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // Create views for options
        options = toggleRow.options.map {
            let checkbox = CheckBox()
            checkbox.setTitle($0.text, for: .normal)
            checkbox.setTitleColor(enabledTitleColor, for: .normal)
            checkbox.setTitleColor(disabledTitleColor, for: .disabled)
            checkbox.isEnabled = $0.isEnabled
            checkbox.isSelected = $0.isOn
            checkbox.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return checkbox
        }
        
        // Add options and spacer
        optionsStackView = UIStackView(arrangedSubviews: options + [UIView()])
        optionsStackView.axis = .horizontal
        optionsStackView.alignment = .leading
        optionsStackView.distribution = .fill
        optionsStackView.spacing = LayoutConstants.checkboxSpacing
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(optionsStackView)
        
        separator = UIView()
        separator.isHidden = !showsSeparator
        separator.backgroundColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 0.24)
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        
        setupConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: titleLabel.text != nil ? LayoutConstants.topMargin : 0),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            optionsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: LayoutConstants.titleMargin),
            optionsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -LayoutConstants.checkboxOffset),
            optionsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            separator.heightAnchor.constraint(equalToConstant: LayoutConstants.separatorHeight),
            separator.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: showsSeparator ? LayoutConstants.separatorVerticalMargin : 0),
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            separator.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separator.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
        ])
    }
    
    /// Save the view's values to the model
    open func applyValues() {
        for (option, checkbox) in zip(toggleRow.options, options) {
            option.isOn = checkbox.isSelected
        }
    }
    
    /// Sets the values for a `MapFilterToggleRow`. Use this to reset values
    open func setValues(for toggleRow: MapFilterToggleRow) {
        for (option, checkbox) in zip(toggleRow.options, options) {
            checkbox.isSelected = option.isOn
        }
    }
    
}

