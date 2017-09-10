//
//  SearchHelpViewController.swift
//  Pods
//
//  Created by Megan Efron on 9/9/17.
//
//

import UIKit


/// Item describes content for section in `SearchHelpViewController`
public struct SearchHelpSection {
    
    /// The title of the section
    public let title: String
    
    /// The detail of the section (standard subtitle or array of strings displayed like tags)
    public let detail: SearchHelpDetail
    
    public init(title: String, detail: SearchHelpDetail) {
        self.title = title
        self.detail = detail
    }
    
    /// The section's view contained in a stack view
    public var view: UIStackView {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .darkGray
        titleLabel.font = .systemFont(ofSize: 16.0, weight: UIFontWeightSemibold)
        titleLabel.text = title
        
        let detailView = detail.view
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }
}


/// The `SearchHelpSection` detail type
///
/// - text: A standard string subtitle
/// - tags: A subtitle that looks like an array of tag views
public enum SearchHelpDetail {
    case text(String)
    case tags([String])
    
    /// The detail view for the type (containing the detail content)
    public var view: UIView {
        switch self {
            
        case .text(let detail):
            let label = UILabel()
            label.numberOfLines = 0
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4.0
            let attributes = [
                NSFontAttributeName : UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName : UIColor.gray,
                NSParagraphStyleAttributeName : paragraphStyle
            ]
            label.attributedText = NSAttributedString(string: detail, attributes: attributes)
            return label
            
        case .tags(let detail):
            return SearchHelpTagCollectionView(tags: detail)
        }
    }
}

open class SearchHelpViewController: UIViewController {
    
    
    // MARK: - Public properties
    
    public let items: [SearchHelpSection]
    
    
    // MARK: - Lifecycle
    
    public init(items: [SearchHelpSection]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Search Help"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .fill
        contentView.addSubview(stackView)
        
        for item in items {
            stackView.addArrangedSubview(item.view)
        }
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 48.0),
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 256.0),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6).withPriority(UILayoutPriorityRequired - 1),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -48.0)
            ])
    }
}
