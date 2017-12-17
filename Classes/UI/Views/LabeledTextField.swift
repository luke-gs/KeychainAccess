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
        label.font = .systemFont(ofSize: 14.0, weight: UIFont.Weight.regular)
        addSubview(label)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
        addSubview(textField)

        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = #colorLiteral(red: 0.7630171865, green: 0.7580402272, blue: 0.7838609132, alpha: 0.8041923415)
        addSubview(separator)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -4),
            
            textField.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -11),
            
            separator.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: label.trailingAnchor),
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
