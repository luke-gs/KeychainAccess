//
//  SearchResultLoadingCell.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class SearchResultLoadingCell: UICollectionViewCell, DefaultReusable {
    public let titleLabel = UILabel(frame: .zero)
    public let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    private let container = UIView(frame: .zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        
        container.addSubview(activityIndicator)
        container.addSubview(titleLabel)
        
        contentView.addSubview(container)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints        = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints         = false
        
        let views: [String: UIView] = ["title": titleLabel, "indicator": activityIndicator]
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[indicator(32)]-16-[title]|", options: [.alignAllCenterX], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[title]|", options: [], metrics: nil, views: views)
        constraints += [
            activityIndicator.widthAnchor.constraint(equalToConstant: 32.0),
            container.widthAnchor.constraint(lessThanOrEqualToConstant: 320.0),
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
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.startAnimating()
    }
    
    public func apply(theme: Theme) {
        titleLabel.textColor = theme.color(forKey: .secondaryText)
    }
}
