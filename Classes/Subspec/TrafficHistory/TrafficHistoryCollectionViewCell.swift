//
//  TrafficHistoryCollectionViewCell.swift
//  ClientKit
//
//  Created by QHMW64 on 18/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class TrafficHistoryCollectionViewCell: CollectionViewFormCell {
    
    public struct Item {
        public let number: String
        public let title: String

        public init(number: String, title: String) {
            self.number = number
            self.title = title
        }
    }
    
    var details: [Item] = [] {
        didSet {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            details.forEach { (info) in
                let view = DemeritPinView()
                view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                view.translatesAutoresizingMaskIntoConstraints = false
                view.label.text = info.number
                view.subtitle.text = info.title
                stackView.addArrangedSubview(view)
            }
        }
    }
    
    let label: UILabel = UILabel()
    let stackView: UIStackView = UIStackView()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame )
        
        separatorStyle = .none
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .top
        stackView.spacing = 8.0
        contentView.addSubview(stackView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        label.textAlignment = .center
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: contentView.layoutMargins.top),
            stackView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -label.layoutMargins.top),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor)
            ])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Calculates a minimum height with the standard configuration of single lines
    /// for the title and subtitle, and a double line for detail text unless detail sizable
    /// has number of lines specified.
    ///
    /// - Parameter
    ///   - detail: The detail sizable information.
    ///   - image: An optional size for an image to display at the leading edge of the titles.
    ///   - width: The available width.
    ///   - traitCollection: The trait collection.
    /// - Returns: The correct height for the cell.
    public class func minimumContentHeight(withDetail detail: StringSizable?, imageSize: CGSize? = nil, inWidth width: CGFloat, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        let font = defaultFont(compatibleWith: traitCollection)
        
        var detailHeight: CGFloat = font.lineHeight * 2.0
        
        if var detailSizing = detail?.sizing() {
            if detailSizing.font == nil {
                detailSizing.font = font
            }
            
            if detailSizing.numberOfLines != nil {
                detailHeight = max(detailSizing.minimumHeight(inWidth: width, compatibleWith: traitCollection), detailHeight)
            }
        }
        
        return detailHeight + 70
    }
    
    private class func defaultFont(compatibleWith traitCollection: UITraitCollection) -> UIFont {
        return UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
    }
    
    // MARK: - Theme
    
    public func applyTheme(theme: Theme) {
        stackView.arrangedSubviews.forEach { (view) in
            if let view = view as? DemeritPinView {
                view.subtitle.textColor = theme.color(forKey: Theme.ColorKey.primaryText)
                view.circleView.color = #colorLiteral(red: 0.1642476916, green: 0.1795658767, blue: 0.2130921185, alpha: 1)
            }
        }
        label.textColor = theme.color(forKey: Theme.ColorKey.primaryText)
    }
}

class DemeritPinView: UIView {
    
    let label: UILabel
    let subtitle: UILabel
    let circleView: CircleIconView
    
    init() {
        label = UILabel()
        subtitle = UILabel()
        circleView = CircleIconView()
        
        super.init(frame: .zero)
        
        label.font = UIFont.boldSystemFont(ofSize: 25.0)
        label.textColor = UIColor.white
        
        circleView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        circleView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        
        subtitle.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0
        subtitle.font = UIFont.preferredFont(forTextStyle: .caption1, compatibleWith: traitCollection)
        
        addSubview(circleView)
        addSubview(subtitle)
        circleView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            label.widthAnchor.constraint(lessThanOrEqualTo: circleView.widthAnchor, multiplier: 1.0),
            label.heightAnchor.constraint(lessThanOrEqualTo: circleView.heightAnchor, multiplier: 1.0),
            
            circleView.topAnchor.constraint(equalTo: topAnchor),
            circleView.bottomAnchor.constraint(equalTo: subtitle.topAnchor, constant: -subtitle.layoutMargins.top),
            circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor),
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.heightAnchor.constraint(equalToConstant: 50),
            
            subtitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitle.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

}
