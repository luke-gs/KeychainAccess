//
//  TasksFilterHeader.swift
//  MPOLKit
//
//  Created by Kyle May on 15/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksFilterHeader: UIView {
    
    /// Title label on the left side
    open var titleLabel = UILabel()
    
    /// Toggle on the right side
    open var toggle = LabeledSwitch()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    public convenience init(frame: CGRect = .zero, title: String?, showsToggle: Bool) {
        self.init(frame: frame)
        
        toggle.isHidden = !showsToggle
        titleLabel.text = title
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
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            toggle.heightAnchor.constraint(equalToConstant: 32),
            toggle.topAnchor.constraint(equalTo: self.topAnchor),
            toggle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            toggle.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor),
            toggle.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
}
