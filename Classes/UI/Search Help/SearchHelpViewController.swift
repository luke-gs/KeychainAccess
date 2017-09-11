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
}


/// The `SearchHelpSection` detail type that contains relevant content type
///
/// - text: A standard string subtitle
/// - tags: A subtitle that looks like an array of tag views
public enum SearchHelpDetail {
    case text(String)
    case tags([String])
}

open class SearchHelpViewController: UIViewController {
    
    
    // MARK: - Properties
    
    public let items: [SearchHelpSection]
    
    private var stackView: UIStackView?
    
    
    // MARK: - Lifecycle
    
    public init(items: [SearchHelpSection]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Search Help"
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSections), name: .interfaceStyleDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
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
        self.stackView = stackView
        
        loadSections()
        
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
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -48.0)
            ])
    }
    
    // MARK: - Theme
    
    private func loadSections() {
        guard let stackView = stackView else { return }
        
        let theme = ThemeManager.shared.theme(for: .current)
        
        view.backgroundColor = theme.color(forKey: .background)!
        
        for item in items {
            let titleLabel = UILabel()
            titleLabel.numberOfLines = 0
            titleLabel.textColor = theme.color(forKey: .primaryText)!
            titleLabel.font = .systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
            titleLabel.text = item.title
            
            let detailView: UIView
            
            switch item.detail {
            case .text(let detail):
                let label = UILabel()
                label.numberOfLines = 0
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 4.0
                let attributes = [
                    NSFontAttributeName : UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightRegular),
                    NSForegroundColorAttributeName : theme.color(forKey: .secondaryText)!,
                    NSParagraphStyleAttributeName : paragraphStyle
                ]
                label.attributedText = NSAttributedString(string: detail, attributes: attributes)
                detailView = label
            case .tags(let detail):
                // Applies theme from inside the implementation
                detailView = SearchHelpTagCollectionView(tags: detail)
            }
            
            let itemStackView = UIStackView(arrangedSubviews: [titleLabel, detailView])
            itemStackView.axis = .vertical
            itemStackView.spacing = 8
            itemStackView.alignment = .fill
            itemStackView.distribution = .fill
            
            stackView.addArrangedSubview(itemStackView)
        }
    }

    // This only gets called if theme changes
    @objc private func reloadSections() {
        guard let stackView = stackView else { return }
        
        // Remove subviews and reload
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
        }
        
        loadSections()
    }
}
