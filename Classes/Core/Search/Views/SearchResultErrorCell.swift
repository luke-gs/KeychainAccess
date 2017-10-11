//
//  SearchResultErrorCell.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class SearchResultErrorCell: UICollectionViewCell, DefaultReusable {
    
    public static let contentHeight: CGFloat = 152.0
    
    public let titleLabel = UILabel(frame: .zero)
    public let button = UIButton(type: .system)
    
    public var buttonHandler: ((SearchResultErrorCell) -> ())?
    
    private let container = UIView(frame: .zero)
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        button.setTitle(NSLocalizedString("Try Again", comment: "Search result - Try again"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority.almostRequired, for: UILayoutConstraintAxis.vertical)
        
        button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)
        button.setBackgroundImage(UIImage.resizableRoundedImage(cornerRadius: 4.0, borderWidth: 0.0, borderColor: nil, fillColor: .black).withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.setContentCompressionResistancePriority(UILayoutPriority.required, for: UILayoutConstraintAxis.vertical)
        
        container.addSubview(titleLabel)
        container.addSubview(button)
        
        contentView.addSubview(container)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints     = false
        container.translatesAutoresizingMaskIntoConstraints  = false
        
        let views: [String: UIView] = ["title": titleLabel, "button": button, "container": container]
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[title]-24-[button]|", options: [.alignAllCenterX], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[title]|", options: [], metrics: nil, views: views)
        constraints += [
            container.widthAnchor.constraint(lessThanOrEqualToConstant: 400.0),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.leadingAnchor),
            container.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            container.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
            container.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    public func apply(theme: Theme) {
        titleLabel.textColor = theme.color(forKey: .secondaryText)
    }
    
    @objc private func buttonTapped() {
        buttonHandler?(self)
    }
}


