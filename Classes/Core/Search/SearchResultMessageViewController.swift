//
//  SearchResultMessageViewController.swift
//  MPOLKit
//
//  Created by Megan Efron on 4/10/17.
//

import UIKit

/// Screen that presents a search result message, if the message is truncated in the cell
/// and user requests to "READ MORE".
open class SearchResultMessageViewController: UIViewController {
    
    // MARK: - Properties
    
    public let textView = UITextView()
    
    
    // MARK: - Lifecycle
    
    public init(message: String) {
        super.init(nibName: nil, bundle: nil)
        
        textView.text = message
        
        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        
        let closeText = NSLocalizedString("Close", bundle: .mpolKit, comment: "BarButton - Close")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: closeText, style: .plain, target: self, action: #selector(closeButtonDidSelect))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.alwaysBounceVertical = true
        textView.isEditable = false
        textView.isSelectable = false
        textView.adjustsFontForContentSizeCategory = true
        textView.textContainerInset = UIEdgeInsets(top: 20.0, left: 12.0, bottom: 20.0, right: 12.0)
        view.addSubview(textView)
        
        let size = textView.sizeThatFits(CGSize(width: 500, height: CGFloat.greatestFiniteMagnitude))
        self.preferredContentSize = size
        
        apply(ThemeManager.shared.theme(for: .current))
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Actions
    
    @objc private func closeButtonDidSelect() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Theme
    
    @objc private func interfaceStyleDidChange() {
        apply(ThemeManager.shared.theme(for: .current))
    }
    
    private func apply(_ theme: Theme) {
        view.backgroundColor = theme.color(forKey: .background)
        textView.textColor = theme.color(forKey: .secondaryText)
    }
}
