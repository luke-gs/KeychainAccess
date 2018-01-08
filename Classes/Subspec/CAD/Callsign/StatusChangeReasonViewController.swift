//
//  StatusChangeReasonViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// View controller for managing the current callsign status
open class StatusChangeReasonViewController: ThemedPopoverViewController, UITextViewDelegate {

    open let textView: UITextView = UITextView(frame: .zero)
    open let placeholder: UILabel = UILabel(frame: .zero)

    open override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Change Status", comment: "")
        setupViews()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton(_:)))
    }

    open override var wantsTransparentBackground: Bool {
        didSet {
            // Apply theme changes to view and sub views, ignoring transparency
            DispatchQueue.main.async {
                self.view.backgroundColor = self.theme.color(forKey: .background)
                self.textView.backgroundColor = self.view.backgroundColor
                self.textView.textColor = self.theme.color(forKey: .primaryText)
                self.placeholder.textColor = self.theme.color(forKey: .placeholderText)
            }
        }
    }

    open func setupViews() {
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        view.addSubview(textView)

        placeholder.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        placeholder.textColor = .disabledGray
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.text = NSLocalizedString("Enter optional remark", comment: "")
        view.addSubview(placeholder)

        let inset = 24 as CGFloat
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: inset),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset),

            placeholder.topAnchor.constraint(equalTo: view.topAnchor, constant: inset),
            placeholder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
        ])
    }

    @objc private func didTapCancelButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapDoneButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    open func textViewDidBeginEditing(_ textView: UITextView) {
        placeholder.isHidden = true
    }

    open func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholder.isHidden = false
        }
    }

}
