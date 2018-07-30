//
//  TermsConditionsViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 29/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public final class TermsConditionsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var textView: UITextView?
    
    private var textViewInsetManager: ScrollViewInsetManager?
    
    public let fileURL: URL

    private let buttonsView: DialogActionButtonsView?
    
    // MARK: - Initializers
    
    public init(fileURL: URL,
                actions: [DialogAction]?) {
        self.fileURL = fileURL
        self.buttonsView = actions != nil ? DialogActionButtonsView(actions: actions!) : nil

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Terms and Conditions", bundle: .mpolKit, comment: "Title")

        automaticallyAdjustsScrollViewInsets = false

        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .interfaceStyleDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .interfaceStyleDidChange, object: nil)
    }

    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    // MARK: - View lifecycle
    
    public override func loadView() {
        let textView = UITextView(frame: .zero, textContainer: nil)
        textView.textContainerInset = UIEdgeInsets(top: 12.0, left: 8.0, bottom: 8.0, right: 8.0)
        textView.alwaysBounceVertical = true
        textView.isEditable = false
        textView.isSelectable = false
        textView.adjustsFontForContentSizeCategory = true
        
        self.textView = textView
        self.textViewInsetManager = ScrollViewInsetManager(scrollView: textView)
        view = UIView(frame: .zero)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let text = try? NSAttributedString(url: self.fileURL, options: [:], documentAttributes: nil) else {
            return
        }

        var constraints: [NSLayoutConstraint] = []
        let textViewBottomConstraint: NSLayoutConstraint?

        if let buttonsView = buttonsView {

            buttonsView.backgroundColor = .clear

            buttonsView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(buttonsView)

            constraints += [
                buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                buttonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ]

            textViewBottomConstraint = textView!.bottomAnchor.constraint(equalTo: buttonsView.topAnchor)

        } else {
            textViewBottomConstraint = textView!.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
        }

        textView!.backgroundColor = .clear
        textView!.attributedText = text
        textView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView!)


        constraints += [
            textView!.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
            textView!.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            textView!.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            textViewBottomConstraint!
        ]
        NSLayoutConstraint.activate(constraints)

        applyTheme()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11, *) {
            return
        }

        let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: max(bottomLayoutGuide.length, statusTabBarInset), right: 0.0)
        textViewInsetManager?.standardContentInset   = insets
        textViewInsetManager?.standardIndicatorInset = insets
    }

    // MARK: - Themeing

    @objc public func applyTheme() {
        let theme = ThemeManager.shared.theme(for: .current)

        view.backgroundColor = theme.color(forKey: Theme.ColorKey.background)
        textView?.textColor = theme.color(forKey: Theme.ColorKey.primaryText)
    }
}
