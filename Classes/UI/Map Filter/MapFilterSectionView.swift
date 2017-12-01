//
//  MapFilterSectionView.swift
//  MPOLKit
//
//  Created by Kyle May on 17/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class MapFilterSectionView: UIView {
    
    public struct LayoutConstants {
        public static let separatorHeight: CGFloat = 1
        public static let separatorMargin: CGFloat = 24
        public static let rowSpacing: CGFloat = 12
        public static let toggleHeight: CGFloat = 32
        public static let trailingMargin: CGFloat = 24
    }
    
    private let section: MapFilterSection
    
    /// Whether to disable selection of the toggle row items when
    /// the section's toggle is disabled. Default value is `false`.
    open var disablesCheckboxesOnSectionDisabled = false {
        didSet {
            // Update the toggle rows for toggle state and this property
            updateToggleRows()
        }
    }
    
    /// Title label on the left side
    open var titleLabel = UILabel()
    
    /// Toggle on the right side
    open var toggle = LabeledSwitch()
    
    open var toggleRowStackView: UIStackView!
    open var toggleRows: [MapFilterToggleRowView] = []
    
    open var separator: UIView!
    
    public init(frame: CGRect = .zero, section: MapFilterSection) {
        self.section = section
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
        
        toggle.isHidden = section.isOn == nil
        toggle.setOn(section.isOn ?? false, animated: false)
        titleLabel.text = section.title
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {

        // Add title
        titleLabel.textColor = #colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1)
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // Add toggle
        toggle.setTitle(NSLocalizedString("SHOW", comment: "Currently showing this filter"), for: .on)
        toggle.setTitle(NSLocalizedString("HIDE", comment: "Currently hiding this filter"), for: .off)
        toggle.setTitleColor(.white, for: .on)
        toggle.setTitleColor(.gray, for: .off)
        toggle.setTitleFont(UIFont.systemFont(ofSize: 11, weight: .bold))
        toggle.image = AssetManager.shared.image(forKey: .map)
        toggle.setImageColor(#colorLiteral(red: 0.01170070749, green: 0.4809396863, blue: 0.9994120002, alpha: 1), for: .on)
        toggle.setImageColor(.gray, for: .off)
        toggle.onTintColor = #colorLiteral(red: 0.01170070749, green: 0.4809396863, blue: 0.9994120002, alpha: 1)
        toggle.offTintColor = #colorLiteral(red: 0.8431087136, green: 0.8431568742, blue: 0.8508625627, alpha: 1)
        toggle.onBorderTintColor = .clear
        toggle.offBorderTintColor = .clear
        toggle.addTarget(self, action: #selector(updateToggleRows), for: .valueChanged)
        toggle.isHidden = section.isOn != nil
        toggle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toggle)
        
        // For each toggle row, add toggle row view
        for (index, toggleRow) in section.toggleRows.enumerated() {
            // Show separator if not last row
            let showSeparator = index < section.toggleRows.count - 1
            
            let row = MapFilterToggleRowView(toggleRow: toggleRow, showsSeparator: showSeparator)
            toggleRows.append(row)
        }
        
        // Add rows and spacer
        toggleRowStackView = UIStackView(arrangedSubviews: toggleRows)
        toggleRowStackView.axis = .vertical
        toggleRowStackView.distribution = .fill
        toggleRowStackView.spacing = LayoutConstants.rowSpacing
        toggleRowStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toggleRowStackView)
        
        // Add separator
        separator = UIView()
        separator.backgroundColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 0.24)
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            toggle.heightAnchor.constraint(equalToConstant: LayoutConstants.toggleHeight),
            toggle.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            toggle.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor),
            toggle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -LayoutConstants.trailingMargin),
            
            toggleRowStackView.topAnchor.constraint(equalTo: toggle.bottomAnchor),
            toggleRowStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            toggleRowStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -LayoutConstants.trailingMargin),
            
            separator.heightAnchor.constraint(equalToConstant: LayoutConstants.separatorHeight),
            separator.topAnchor.constraint(equalTo: toggleRowStackView.bottomAnchor, constant: LayoutConstants.separatorMargin),
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    /// Updates the toggle rows for the section toggle's state
    @objc open func updateToggleRows() {
        // Do nothing if we aren't using a toggle
        guard section.isOn != nil else { return }
        
        // Disable all checkboxes if toggle is off, otherwise revert to original state
        toggleRows.forEach { row in
            for (option, checkbox) in zip(row.toggleRow.options, row.options) {
                if disablesCheckboxesOnSectionDisabled {
                    checkbox.isEnabled = toggle.isOn ? option.isEnabled : false
                } else {
                    checkbox.isEnabled = option.isEnabled
                }
            }
        }
    }
    
    /// Save the view's values to the model
    open func applyValues() {
        if section.isOn != nil {
            section.isOn = toggle.isOn
        }
        toggleRows.forEach {
            $0.applyValues()
        }
    }
    
    /// Sets the values for a `MapFilterSection`. Use this to reset values
    open func setValues(for section: MapFilterSection) {
        if section.isOn != nil {
            // Set toggle if we are using one
            toggle.setOn(section.isOn.isTrue, animated: false)
        }
        
        // Set toggle rows
        for (toggleRow, toggleRowView) in zip(section.toggleRows, toggleRows) {
            toggleRowView.setValues(for: toggleRow)
        }
    }
    
}
