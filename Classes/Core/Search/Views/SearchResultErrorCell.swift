//
//  SearchResultErrorCell.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class SearchResultErrorCell: UICollectionViewCell, DefaultReusable {
    
    public typealias SearchResultErrorCellButtonHandler = (SearchResultErrorCell) -> ()
    
    
    public static let contentHeight: CGFloat = 152.0
    
    public let titleLabel = UILabel(frame: .zero)
    public let actionButton = UIButton(type: .system)
    public let readMoreButton = UIButton(type: .system)
    
    public var actionButtonHandler: SearchResultErrorCellButtonHandler?
    public var readMoreButtonHandler: SearchResultErrorCellButtonHandler?
    
    private let container = UIView(frame: .zero)
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        actionButton.setTitle(NSLocalizedString("Try Again", comment: "Search result - Try again"), for: .normal)
        actionButton.setTitleColor(.black, for: .normal)
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority.almostRequired, for: UILayoutConstraintAxis.vertical)
        
        readMoreButton.setTitle("READ MORE", for: .normal)
        readMoreButton.titleLabel?.font = .systemFont(ofSize: 11.0, weight: UIFont.Weight.semibold)
        readMoreButton.isHidden = true
        readMoreButton.backgroundColor = .clear
        readMoreButton.addTarget(self, action: #selector(readMoreButtonTapped), for: .touchUpInside)
        
        actionButton.titleLabel?.font = .systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)
        actionButton.setBackgroundImage(UIImage.resizableRoundedImage(cornerRadius: 4.0, borderWidth: 0.0, borderColor: nil, fillColor: .black).withRenderingMode(.alwaysTemplate), for: .normal)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        actionButton.setContentCompressionResistancePriority(UILayoutPriority.required, for: UILayoutConstraintAxis.vertical)
        
        container.addSubview(readMoreButton)
        
        container.addSubview(titleLabel)
        container.addSubview(actionButton)
        
        contentView.addSubview(container)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints     = false
        actionButton.translatesAutoresizingMaskIntoConstraints   = false
        container.translatesAutoresizingMaskIntoConstraints      = false
        readMoreButton.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: UIView] = ["title": titleLabel, "button": actionButton, "container": container]
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[title]-24-[button]|", options: [.alignAllCenterX], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[title]|", options: [], metrics: nil, views: views)
        constraints += [
            container.widthAnchor.constraint(lessThanOrEqualToConstant: 400.0),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.leadingAnchor),
            container.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            container.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
            container.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            readMoreButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -10),
            readMoreButton.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    public func apply(theme: Theme) {
        titleLabel.textColor = theme.color(forKey: .secondaryText)
    }
    
    @objc private func actionButtonTapped() {
        actionButtonHandler?(self)
    }
    
    @objc public func readMoreButtonTapped() {
        readMoreButtonHandler?(self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        readMoreButton.isHidden = titleLabel.bounds.height == 0 || titleLabel.isTruncated == false
    }
}

fileprivate extension UILabel {
    
    var isTruncated: Bool {
        guard let text = text else { return false }
        
        let size = CGSize(width: frame.size.width, height: .greatestFiniteMagnitude)
        let textSize = (text as NSString).boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedStringKey.font: font],
            context: nil).size
        
        return floor(textSize.height) > floor(bounds.size.height)
    }
}
