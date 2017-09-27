//
//  WhatsNewDetailViewController.swift
//  Pods
//
//  Created by Megan Efron on 8/8/17.
//
//

import UIKit

public struct WhatsNewDetailItem {
    var image: UIImage?
    var title: String?
    var detail: String?
    
    public init(image: UIImage? = nil, title: String? = nil, detail: String? = nil) {
        self.image = image
        self.title = title
        self.detail = detail
    }
}

public class WhatsNewDetailViewController: UIViewController {
    
    public var theme: WhatsNewTheme {
        didSet {
            applyTheme()
        }
    }
    
    private let item: WhatsNewDetailItem
    private var imageView: UIImageView?
    private var titleLabel: UILabel?
    private var detailLabel: UILabel?
    
    private let stackView = UIStackView()
    
    public required init(item: WhatsNewDetailItem, theme: WhatsNewTheme) {
        self.item = item
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupViews()
        setupConstraints()
        
        applyTheme()
    }
    
    private func setupViews() {
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 32
        view.addSubview(stackView)
        
        // set up image view
        if let image = item.image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(imageView)
            self.imageView = imageView
        }
        
        // set up title label
        if let title = item.title {
            let label = UILabel()
            label.text = title
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textAlignment = .center
            label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
            stackView.addArrangedSubview(label)
            self.titleLabel = label
        }
        
        // set up detail label
        if let detail = item.detail {
            let label = UILabel()
            label.text = detail
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
            stackView.addArrangedSubview(label)
            self.detailLabel = label
        }
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).withPriority(UILayoutPriority(rawValue: UILayoutPriority.RawValue(Int(UILayoutPriority.required.rawValue) - 1))),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -128),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 64),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
        ])
        
        if let titleLabel = titleLabel {
            NSLayoutConstraint.activate([
                titleLabel.widthAnchor.constraint(equalToConstant: 400).withPriority(UILayoutPriority.defaultHigh)
            ])
        }
        
        if let detailLabel = detailLabel {
            NSLayoutConstraint.activate([
                detailLabel.widthAnchor.constraint(equalToConstant: 400).withPriority(UILayoutPriority.defaultHigh)
            ])
        }
    }
    
    private func applyTheme() {
        if let titleLabel = titleLabel {
            titleLabel.textColor = theme.titleTextColor
            titleLabel.font = theme.titleFont
        }
        if let detailLabel = detailLabel {
            detailLabel.textColor = theme.detailTextColor
            detailLabel.font = theme.detailFont
        }
    }
}
