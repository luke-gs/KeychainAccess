//
//  StatsOverviewCollectionViewCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 22/3/17.
//
//

import UIKit

open class StatsOverviewCollectionViewCell: CollectionViewFormCell {
    
    // MARK: - Class sizing methods
    
    public class func minimumHeight(compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        let titleFont = iconLabelFont(compatibleWith: traitCollection)
        return ceil((titleFont.lineHeight + titleFont.leading) * 2.0) + 66.0
    }
    
    
    // MARK: - Public properties
    
    open var items: [StatsOverviewItem] = [] {
        didSet {
            if items == oldValue { return }
            
            var reusableIconViews = self.iconViews
            var reusableLabels    = self.iconLabels
            
            let itemColor = itemIconColor ?? .white
            
            iconViews = items.map { (item: StatsOverviewItem) -> CircleIconView in
                let circle: CircleIconView
                if let view = reusableIconViews.first {
                    reusableIconViews.remove(at: 0)
                    circle = view
                } else {
                    circle = CircleIconView(frame: CGRect(x: 0.0, y: 0.0, width: 48.0, height: 48.0))
                }
                circle.color = item.color
                
                switch item.icon {
                case let image as UIImage:
                    if let iconImageView = circle.iconView as? UIImageView {
                        iconImageView.image = image
                    } else {
                        let iconView = UIImageView(image: image)
                        iconView.tintColor = itemColor
                        circle.iconView = iconView
                    }
                case let text as String:
                    if let iconLabel = circle.iconView as? UILabel {
                        iconLabel.text = text
                    } else {
                        let label = UILabel(frame: .zero)
                        label.text = text
                        label.textColor = itemColor
                        label.font = .systemFont(ofSize: 29.0, weight: UIFontWeightMedium)
                        label.adjustsFontSizeToFitWidth = true
                        circle.iconView = label
                    }
                default:
                    break
                }
                
                return circle
            }
            
            iconLabels = items.map { (item: StatsOverviewItem) -> UILabel in
                let label: UILabel
                if let view = reusableLabels.first {
                    reusableLabels.remove(at: 0)
                    label = view
                } else {
                    label = UILabel(frame: .zero)
                    label.textAlignment = .center
                    label.font = titleFont
                    label.numberOfLines = 2
                    label.adjustsFontSizeToFitWidth = true
                    label.minimumScaleFactor = 0.8
                }
                label.textColor = titleTextColor ?? .black
                label.text = item.title
                return label
            }
        }
    }
    
    open var itemIconColor: UIColor? {
        didSet {
            if itemIconColor == oldValue { return }
            
            let newColor = itemIconColor ?? .white
            
            iconViews.forEach {
                switch $0.iconView {
                case let imageView as UIImageView:
                    imageView.tintColor = newColor
                case let label as UILabel:
                    label.textColor = newColor
                default:
                    break
                }
            }
        }
    }
    
    open var titleTextColor: UIColor? {
        didSet {
            if titleTextColor == oldValue { return }
            
            let newColor = itemIconColor ?? .black
            iconLabels.forEach { $0.textColor = newColor }
        }
    }
    
    
    // MARK: - Private properties
    
    private var iconViews: [CircleIconView] = [] {
        didSet {
            if iconViews == oldValue { return }
            
            oldValue.forEach {
                if iconViews.contains($0) == false && $0.superview == scrollView {
                    $0.removeFromSuperview()
                }
            }
            iconViews.forEach {
                if oldValue.contains($0) == false {
                    scrollView.addSubview($0)
                }
            }
            setNeedsLayout()
        }
    }
    
    private var iconLabels: [UILabel] = [] {
        didSet {
            if iconLabels == oldValue { return }
            
            oldValue.forEach {
                if iconLabels.contains($0) == false && $0.superview == scrollView {
                    $0.removeFromSuperview()
                }
            }
            iconLabels.forEach {
                if oldValue.contains($0) == false {
                    scrollView.addSubview($0)
                }
            }
            setNeedsLayout()
        }
    }
    
    private let scrollView = UIScrollView(frame: .zero)
    
    private var titleFont: UIFont!
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let contentView = self.contentView
        scrollView.frame = contentView.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(scrollView)
        
        updateFonts()
    }
    
    
    // MARK: - Overrides
    
    open override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                setNeedsLayout()
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            if frame.size != oldValue.size {
                setNeedsLayout()
            }
        }
    }
    
    open override var layoutMargins: UIEdgeInsets {
        didSet {
            if layoutMargins != oldValue {
                scrollView.contentInset = layoutMargins
                scrollView.contentOffset.y = layoutMargins.top
                scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: layoutMargins.left, bottom: 0.0, right: layoutMargins.right)
                setNeedsLayout()
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let itemIntCount = items.count
        if itemIntCount == 0 {
            scrollView.contentSize = .zero
            scrollView.contentOffset = .zero
            return
        }
        
        let itemCount    = CGFloat(itemIntCount)
        let iconViewSize = CGSize(width: 48.0, height: 48.0)
        
        let scrollViewInsets         = scrollView.contentInset
        let nonScrollableContentSize = scrollView.frame.insetBy(scrollViewInsets)
        let minimumWidth             = iconViewSize.width * itemCount * 1.85
        
        let scrollViewWidth  = max(nonScrollableContentSize.width, minimumWidth)
        let interIconSpacing = scrollViewWidth / itemCount - iconViewSize.width
        
        scrollView.contentSize = CGSize(width: scrollViewWidth, height: nonScrollableContentSize.height)
        
        var iconXOrigin = interIconSpacing / 2.0
        let iconYOrigin = CGFloat(5.0)
        
        let maximumTextSize = CGSize(width: ceil(interIconSpacing + iconViewSize.width - 4.0), height: ceil((titleFont.lineHeight + titleFont.leading) * 2.0))
        
        iconViews.enumerated().forEach { (item: (offset: Int, element: CircleIconView)) in
            let iconFrame = CGRect(x: round(iconXOrigin), y: iconYOrigin, width: iconViewSize.width, height: iconViewSize.height)
            item.element.frame = iconFrame
            
            iconXOrigin += iconViewSize.width + interIconSpacing
            
            let label = iconLabels[item.offset]
            var textSize = label.sizeThatFits(maximumTextSize)
            if textSize.width > maximumTextSize.width {
                textSize.width = maximumTextSize.width
            }
            if textSize.height > maximumTextSize.height {
                textSize.height = maximumTextSize.height
            }
            
            label.frame = CGRect(x: round(iconFrame.midX - (textSize.width / 2.0)), y: round(iconFrame.maxY + 10.0), width: textSize.width, height: textSize.height)
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        let contentInset = scrollView.contentInset
        scrollView.contentOffset = CGPoint(x: -contentInset.left, y: -contentInset.top)
    }
    
    open override func contentSizeCategoryDidChange(_ newCategory: UIContentSizeCategory) {
        super.contentSizeCategoryDidChange(newCategory)
        updateFonts()
    }
    
    private func updateFonts() {
        titleFont = type(of: self).iconLabelFont(compatibleWith: traitCollection)
        iconLabels.forEach { $0.font = titleFont }
        setNeedsLayout()
    }
    
    
    // MARK: - Class font caching
    
    private static var fontCache: [UIContentSizeCategory: UIFont] = [:]
    
    private class func iconLabelFont(compatibleWith traitCollection: UITraitCollection) -> UIFont {
        let category = traitCollection.preferredContentSizeCategory
        if let font = StatsOverviewCollectionViewCell.fontCache[category] {
                return font
        } else {
            var fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote, compatibleWith: traitCollection)
            if let newDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
                fontDescriptor = newDescriptor
            }
            let font = UIFont(descriptor: fontDescriptor, size: 0.0)
            
            StatsOverviewCollectionViewCell.fontCache[category] = font
            return font
        }
    }
    
}


public struct StatsOverviewItem: Equatable {
    
    private(set) var icon: NSObject
    public var color: UIColor?
    public var title: String
    
    public init(icon: UIImage, color: UIColor?, title: String) {
        self.icon = icon
        self.color = color
        self.title = title
    }
    
    public init(icon: String, color: UIColor?, title: String) {
        self.icon = icon as NSString
        self.color = color
        self.title = title
    }
    
}


public func ==(lhs: StatsOverviewItem, rhs: StatsOverviewItem) -> Bool {
    return lhs.icon == rhs.icon && lhs.color == rhs.color && lhs.title == rhs.title
}

