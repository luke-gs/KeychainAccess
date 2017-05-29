//
//  TermsConditionsViewController.swift
//  Pods
//
//  Created by Rod Brown on 29/5/17.
//
//

import UIKit

open class TermsConditionsViewController: UIViewController {
    
    // MARK: - Properties
    
    open var termsAndConditions: NSAttributedString? = NSAttributedString(string: NSLocalizedString("Terms and Conditions", bundle: .mpolKit, comment: ""), attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)] ) {
        didSet {
            textView?.attributedText = termsAndConditions
        }
    }
    
    open weak var delegate: TermsConditionsViewControllerDelegate?
    
    
    private var textView: UITextView?
    
    
    // MARK: - Initializers
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Terms and Conditions", bundle: .mpolKit, comment: "Title")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidSelect(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Accept", bundle: .mpolKit, comment: "Bar Button"), style: .done, target: self, action: #selector(acceptButtonDidSelect(_:)))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    open override func loadView() {
        let textView = UITextView(frame: .zero, textContainer: nil)
        textView.alwaysBounceVertical = true
        textView.isEditable = false
        if #available(iOS 10, *) {
            textView.adjustsFontForContentSizeCategory = true
        }
        textView.font = .preferredFont(forTextStyle: .body)
        textView.attributedText = termsAndConditions
        self.textView = textView
        self.view = textView
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
