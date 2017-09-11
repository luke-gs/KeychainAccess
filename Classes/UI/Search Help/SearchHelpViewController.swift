//
//  SearchHelpViewController.swift
//  Pods
//
//  Created by Megan Efron on 9/9/17.
//
//

import UIKit


open class SearchHelpViewController: UIViewController {
    
    
    // MARK: - Properties
    
    public let details: SearchHelpDetails
    
    private var stackView: UIStackView?
    
    
    // MARK: - Lifecycle
    
    public required init(details: SearchHelpDetails) {
        self.details = details
        super.init(nibName: nil, bundle: nil)
        
        self.title = details.title
        
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
        
        for section in details.sections {
            let titleLabel = UILabel()
            titleLabel.numberOfLines = 0
            titleLabel.textColor = theme.color(forKey: .primaryText)!
            titleLabel.font = .systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
            titleLabel.text = section.title
            
            let detailView: UIView
            
            switch section.detail {
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
            view.removeFromSuperview()
        }
        
        loadSections()
    }
}
