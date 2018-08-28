//
//  NavigationTitleView.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/2/18.
//

import UIKit

/// Navigation title view with title and subtitle
open class NavigationTitleView: UIStackView {
    
    public let titleLabel: UILabel
    public let subtitleLabel: UILabel
    
    public init(title: String?, subtitle: String?) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.sizeToFit()
        self.titleLabel = titleLabel
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = .white
        subtitleLabel.sizeToFit()
        self.subtitleLabel = subtitleLabel
        
        let verticalPadding: CGFloat = 2 // not much, but we've gotta fit in the nav space
        let width = max(titleLabel.frame.width, subtitleLabel.frame.width)
        let height = titleLabel.frame.height + subtitleLabel.frame.height + verticalPadding
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Arrange in stackview for easy layout
        addArrangedSubview(titleLabel)
        addArrangedSubview(subtitleLabel)
        distribution = .equalSpacing
        axis = .vertical
    }
    
    public required init(coder: NSCoder) {
        MPLCodingNotSupported()
    }
}
