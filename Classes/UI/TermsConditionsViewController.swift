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
    
    public weak var delegate: TermsConditionsViewControllerDelegate?
    
    private var textView: UITextView?
    
    private var textViewInsetManager: ScrollViewInsetManager?

    private var buttonsView: DialogActionButtonsView!
    
    public let fileURL: URL
    
    // MARK: - Initializers
    
    public init(fileURL: URL,
                acceptText: String? = NSLocalizedString("Accept", bundle: .mpolKit, comment: "T&C - Accept"),
                declineText: String? = NSLocalizedString("Decline", bundle: .mpolKit, comment: "T&C - Decline")) {
        self.fileURL = fileURL

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Terms and Conditions", bundle: .mpolKit, comment: "Title")

        automaticallyAdjustsScrollViewInsets = false
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
        
        textView!.attributedText = text

        let declineAction = DialogAction(title: "Decline") { _ in
            self.declineButtonDidSelect()
        }
        let acceptAction = DialogAction(title: "Accept") { _ in
            self.acceptButtonDidSelect()
        }
        buttonsView = DialogActionButtonsView(actions: [declineAction, acceptAction])
        buttonsView.backgroundColor = .white
        buttonsView.layer.cornerRadius = 0

        textView!.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(textView!)
        view.addSubview(buttonsView)

        NSLayoutConstraint.activate([

            textView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView!.topAnchor.constraint(equalTo: view.topAnchor),
            textView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsView.topAnchor.constraint(equalTo: textView!.bottomAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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

    // MARK: - Action methods
    
    private func declineButtonDidSelect() {
        delegate?.termsConditionsController(self, didFinishAcceptingConditions: false)
    }
    
    private func acceptButtonDidSelect() {
        delegate?.termsConditionsController(self, didFinishAcceptingConditions: true)
    }
}


public protocol TermsConditionsViewControllerDelegate : class {
    
    func termsConditionsController(_ controller: TermsConditionsViewController, didFinishAcceptingConditions accept: Bool)
    
}
