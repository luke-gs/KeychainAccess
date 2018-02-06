//
//  PSCAlertActionView.swift
//  MPOLKit
//
//  Created by Kyle May on 6/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public protocol PSCAlertActionViewDelegate: class {
    func shouldDismiss()
}

open class PSCAlertActionView: UIControl {

    open weak var delegate: PSCAlertActionViewDelegate?
    
    private var action: PSCAlertAction
    
    open private(set) var titleLabel: UILabel!
    open private(set) var topDivider: UIView!
    open private(set) var sideDivider: UIView!
    
    open var showsSideDivider: Bool = false {
        didSet {
            sideDivider.isHidden = !showsSideDivider
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.black.withAlphaComponent(0.05) : .clear
        }
    }
    
    public init(frame: CGRect = .zero, action: PSCAlertAction) {
        self.action = action
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        topDivider = UIView()
        topDivider.backgroundColor = .disabledGray
        topDivider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topDivider)
        
        sideDivider = UIView()
        sideDivider.isHidden = !showsSideDivider
        sideDivider.backgroundColor = .disabledGray
        sideDivider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sideDivider)
        
        titleLabel = UILabel()
        titleLabel.text = action.title
        titleLabel.font = action.style.font
        titleLabel.textColor = action.style.color
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        addTarget(self, action: #selector(didSelectButton), for: .touchUpInside)
    }
    
    @objc private func didSelectButton() {
        delegate?.shouldDismiss()
        action.didSelect()
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topDivider.heightAnchor.constraint(equalToConstant: 1),
            topDivider.topAnchor.constraint(equalTo: topAnchor),
            topDivider.leadingAnchor.constraint(equalTo: leadingAnchor),
            topDivider.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            sideDivider.widthAnchor.constraint(equalToConstant: 1),
            sideDivider.topAnchor.constraint(equalTo: topAnchor),
            sideDivider.bottomAnchor.constraint(equalTo: bottomAnchor),
            sideDivider.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: topDivider.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
}
