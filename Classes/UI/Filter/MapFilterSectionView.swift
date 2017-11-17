//
//  MapFilterSectionView.swift
//  MPOLKit
//
//  Created by Kyle May on 17/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class MapFilterSectionView: UIView {
    
    public struct LayoutConstants {
        public static let separatorHeight: CGFloat = 1
        public static let separatorMargin: CGFloat = 24
        public static let rowSpacing: CGFloat = 12
    }
    
    private let section: MapFilterSection
    
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
        
        toggle.isHidden = section.isEnabled == nil
        toggle.setOn(section.isEnabled ?? false, animated: false)
        titleLabel.text = section.title
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {

        titleLabel.textColor = #colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1)

        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        toggle.setTitle("SHOW", for: .on)
        toggle.setTitle("HIDE", for: .off)
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
        toggle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toggle)
        
        // for each toggle row, add toggle thing
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
            
            toggle.heightAnchor.constraint(equalToConstant: 32),
            toggle.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            toggle.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor),
            toggle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            
            toggleRowStackView.topAnchor.constraint(equalTo: toggle.bottomAnchor),
            toggleRowStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            toggleRowStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            
            separator.heightAnchor.constraint(equalToConstant: LayoutConstants.separatorHeight),
            separator.topAnchor.constraint(equalTo: toggleRowStackView.bottomAnchor, constant: LayoutConstants.separatorMargin),
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
}
