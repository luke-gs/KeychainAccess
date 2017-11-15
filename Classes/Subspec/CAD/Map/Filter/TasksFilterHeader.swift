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
    open var toggle = UISwitch() // TODO: Use custom class
    
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
        
        toggle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toggle)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            toggle.topAnchor.constraint(equalTo: self.topAnchor),
            toggle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            toggle.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor),
            toggle.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
}
