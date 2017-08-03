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
    
    public let fileURL: URL
    
    // MARK: - Initializers
    
    public init(fileURL: URL,
                acceptText: String? = NSLocalizedString("Accept", bundle: .mpolKit, comment: "T&C - Accept"),
                cancelText: String? = NSLocalizedString("Cancel", bundle: .mpolKit, comment: "T&C - Cancel")) {
        self.fileURL = fileURL
        
        super.init(nibName: nil, bundle: nil)
        
        title = NSLocalizedString("Terms and Conditions", bundle: .mpolKit, comment: "Title")
        
        navigationItem.leftBarButtonItem  = UIBarButtonItem(title: cancelText, style: .done, target: self, action: #selector(cancelButtonDidSelect(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: acceptText, style: .done, target: self, action: #selector(acceptButtonDidSelect(_:)))
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
        self.view = textView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let text = try? NSAttributedString(url: self.fileURL, options: [:], documentAttributes: nil) else {
            return
        }
        
        textView!.attributedText = text
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: max(bottomLayoutGuide.length, statusTabBarInset), right: 0.0)
        textViewInsetManager?.standardContentInset   = insets
        textViewInsetManager?.standardIndicatorInset = insets
    }

    // MARK: - Action methods
    
    @objc private func cancelButtonDidSelect(_ item: UIBarButtonItem) {
        delegate?.termsConditionsController(self, didFinishAcceptingConditions: false)
    }
    
    @objc private func acceptButtonDidSelect(_ item: UIBarButtonItem) {
        delegate?.termsConditionsController(self, didFinishAcceptingConditions: true)
    }
}


public protocol TermsConditionsViewControllerDelegate : class {
    
    func termsConditionsController(_ controller: TermsConditionsViewController, didFinishAcceptingConditions accept: Bool)
    
}
