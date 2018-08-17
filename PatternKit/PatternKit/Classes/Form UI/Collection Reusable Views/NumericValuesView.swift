//
//  NumericValuesView.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// A NumericValuesView is used to display a number of labeled values
/// as a means of providing an overview of the data the screen contains, in a numeric format.
///
/// An array of 'items' can be passed in or set afterwards to populate the cells.
///
/// - Parameter
///   - items: An array of Item struct
///   - title: String?

public class NumericValuesView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /// Style
    /// an enum used to determine the textColor of the title and value labels in each cell
    ///
    /// can also be extended to add extra funtionality for each style, eg. make emphasised items pulse
    ///
    /// - normal: will use theme color for primaryText key
    /// - subtle: will use secondary gray color
    /// - emphasised: will use orangeRed color
    /// - custom: allows you to pass in your own color for the item
    public enum Style {

        case normal
        case subtle
        case emphasised
        case custom(UIColor)

        var color: UIColor? {

            switch self {
            case .subtle:
                return .secondaryGray
            case .emphasised:
                return .orangeRed
            case .normal:
                return nil
            case .custom(let color):
                return color
            }
        }
    }

    // Item is a struct used to populate the cells data
    public struct Item {
        var title: String
        var value: Int
        var style: Style

        public init(title: String, value: Int, style: Style = Style.normal) {
            self.title = title
            self.value = value
            self.style = style
        }
    }

    public var titleLabel = UILabel()

    public var items: [Item] {
        didSet {
            collectionView.reloadData()
        }
    }

    private var collectionView: UICollectionView

    private var isCompact: Bool = false

    private var correctInsets: UIEdgeInsets {

        if isCompact {
            return UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 20)
        }
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }

    public init(title: String? = nil, items: [Item] = []) {

        self.items = items
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .clear
        addSubview(titleLabel)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(RegularValueCell.self, forCellWithReuseIdentifier: "regularCell")
        collectionView.register(CompactValueCell.self, forCellWithReuseIdentifier: "compactCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = correctInsets
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        self.isCompact = self.traitCollection.horizontalSizeClass == .compact

        applyTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: NSNotification.Name.interfaceStyleDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    @objc private func applyTheme() {
        let theme = ThemeManager.shared.theme(for: .current)
        titleLabel.textColor = theme.color(forKey: .primaryText)
        backgroundColor = theme.color(forKey: .contentBackgroundGray)

        collectionView.reloadData()
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let widthSpacing =  isCompact ? 0.00 : layout.minimumInteritemSpacing * (CGFloat(items.count))
        let heightSpacing =  isCompact ? layout.minimumInteritemSpacing * (CGFloat(items.count)) : 0.00

        let inset = collectionView.contentInset
        let width = collectionView.bounds.size.width - inset.left - inset.right - widthSpacing
        let height = collectionView.bounds.size.height - inset.top - inset.bottom - heightSpacing

        if isCompact {
            return CGSize(width: width, height: max(height / CGFloat(items.count), 0))
        } else {
            return CGSize(width: width / CGFloat(items.count), height: max(height, 60))
        }
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = isCompact ? "compactCell" : "regularCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ValueCell
        let item = items[indexPath.row]

        cell.titleLabel.text = item.title
        cell.valueLabel.text = String(item.value)

        cell.applyTheme(styleColor: item.style.color)
        
        return cell
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        collectionView.performBatchUpdates({
            collectionView.collectionViewLayout.invalidateLayout()
        }, completion: { (successful) in
            self.collectionView.reloadData()
        })
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        isCompact = self.traitCollection.horizontalSizeClass == .compact 
        collectionView.contentInset = correctInsets
    }
}

fileprivate class ValueCell: UICollectionViewCell {
    let valueLabel = UILabel()
    let titleLabel = UILabel()

    public func applyTheme(styleColor: UIColor?) {
        let theme = ThemeManager.shared.theme(for: .current)

        valueLabel.textColor = styleColor ?? theme.color(forKey: .primaryText)
        titleLabel.textColor = styleColor ?? theme.color(forKey: .primaryText)
    }
}

fileprivate class RegularValueCell: ValueCell {

    override init(frame: CGRect) {
        super.init(frame: .zero)

        backgroundColor = .clear

        valueLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        valueLabel.textAlignment = .center
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(valueLabel)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([

            //value label
            valueLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            valueLabel.topAnchor.constraint(lessThanOrEqualTo: contentView.topAnchor, constant: 24),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            //title label
            titleLabel.topAnchor.constraint(lessThanOrEqualTo: valueLabel.bottomAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(lessThanOrEqualTo: contentView.leadingAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: -8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -24),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}

fileprivate class CompactValueCell: ValueCell {

    override init(frame: CGRect) {
        super.init(frame: .zero)

        valueLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)

        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
        valueLabel.textAlignment = .right

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(valueLabel)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([

            //title label
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 4),

            //value label
            valueLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
