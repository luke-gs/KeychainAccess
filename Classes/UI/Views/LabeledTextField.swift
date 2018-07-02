//
//  LabeledTextField.swift
//  MPOLKit
//
//  Created by QHMW64 on 14/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

open class LabeledTextField: UIView {

    public let label: UILabel = UILabel()
    public let textField: UITextField = UITextField()

    private let separator: UIView = UIView()

    public init() {

        super.init(frame: .zero)

        // Allow view to be tapped
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(sender:))))

        label.translatesAutoresizingMaskIntoConstraints = false
        label.isAccessibilityElement = false
        label.font = .systemFont(ofSize: 17.0, weight: UIFont.Weight.regular)
        addSubview(label)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 17.0, weight: UIFont.Weight.regular)
        textField.textAlignment = .right
        addSubview(textField)

        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = #colorLiteral(red: 0.7630171865, green: 0.7580402272, blue: 0.7838609132, alpha: 0.8041923415)
        addSubview(separator)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: textField.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 19),

            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textField.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 19),
            
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0 / traitCollection.currentDisplayScale),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    @objc private func viewTapped(sender: UIView) {
        if !textField.isFirstResponder && textField.canBecomeFirstResponder {
            textField.becomeFirstResponder()
        }
    }

}
