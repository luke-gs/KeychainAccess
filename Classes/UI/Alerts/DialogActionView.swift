//
//  DialogActionView.swift
//  MPOLKit
//
//  Created by Kyle May on 6/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public protocol DialogActionViewDelegate: class {
    func shouldDismiss()
}

/// View for an action button in a `PSCAlertView`
open class DialogActionView: UIControl {

    open weak var delegate: DialogActionViewDelegate?
    open var action: DialogAction
    
    // MARK: - Views
    
    open private(set) var view: UIView!
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
    
    // MARK: - Setup
    
    public init(frame: CGRect = .zero, action: DialogAction, view: UIView = UILabel()) {
        self.action = action
        self.view = view
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
        topDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        topDivider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topDivider)
        
        sideDivider = UIView()
        sideDivider.isHidden = !showsSideDivider
        sideDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        sideDivider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sideDivider)

        if let label = view as? UILabel {
            label.text = action.title
            label.font = action.style.font
            label.textColor = action.style.color
            label.textAlignment = .center
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        addTarget(self, action: #selector(didSelectButton), for: .touchUpInside)
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
            
            view.topAnchor.constraint(equalTo: topDivider.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    /// Called when the button has been selected
    @objc private func didSelectButton() {
        delegate?.shouldDismiss()
        action.didSelect()
    }
}
