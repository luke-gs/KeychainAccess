//
//  CollectionViewFormOptionStackViewCell.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

//Displayable protocol used by CollectionViewFormStackViewCell
public protocol OptionDisplayable {
    var title: String {get}
    var image: UIImage {get}
}

protocol OptionViewDelegate: class {
    func didSelect(_ view: OptionView)
}

public class CollectionViewFormOptionStackViewCell: CollectionViewFormCell, OptionViewDelegate {

    public let stackView: UIStackView = UIStackView()
    var selectionHandler: ((Int) -> ())?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        contentView.addSubview(stackView)

        //layout constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setOptions(_ displayables: [OptionDisplayable]) {
        for view in stackView.subviews {
            view.removeFromSuperview()
        }

        addOptions(displayables)
    }

    public func addOptions(_ displayables: [OptionDisplayable]) {

        for displayable in displayables {
            let view = OptionView(frame: .zero, image: displayable.image, title: displayable.title)
            view.delegate = self
            stackView.addArrangedSubview(view)
        }
    }

    public func insertOption(_ displayable: OptionDisplayable, at index: Int ) {

        guard index < stackView.arrangedSubviews.count else { return }
        let view = OptionView(frame: .zero, image: displayable.image, title: displayable.title)
        view.delegate = self
        stackView.insertArrangedSubview(view, at: index)
    }

    internal func didSelect(_ view: OptionView) {

        var indexOfSelectedCell: Int?
        for (index, viewToCompare) in (stackView.arrangedSubviews as! [OptionView]).enumerated() {
            if viewToCompare == view {
                indexOfSelectedCell = index
            }
        }

        guard let cellIndex = indexOfSelectedCell else { fatalError("View not found in stack view") }

        setSelectedOption(indexOfSelectedCell: cellIndex)
        selectionHandler?(cellIndex)
    }

    public func setSelectedOption(indexOfSelectedCell: Int) {
        if let view = stackView.arrangedSubviews[indexOfSelectedCell] as? OptionView {
            view.isSelected = true
        }
    }
}

public class OptionView: UIView {
    let imageView: UIImageView = UIImageView()
    let label: UILabel = UILabel()
    weak var delegate: OptionViewDelegate?
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                imageView.tintColor = UIColor.brightBlue
                label.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
                label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            } else {
                imageView.tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .placeholderText)
                label.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .secondaryText)
                label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            }
        }
    }

    public init(frame: CGRect, image: UIImage, title: String) {
        super.init(frame: frame)

        //image view
        imageView.image = image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .placeholderText) //.popoverBackground

        //label
        label.text = title
        label.textAlignment = .center
        label.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .secondaryText)
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)

        layoutViews()

        //add gesture recogniser
        let tap = UITapGestureRecognizer(target: self, action: #selector(didSelect))
        addGestureRecognizer(tap)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutViews() {

        //add items to view
        addSubview(imageView)
        addSubview(label)

        //layout constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            //image view
            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 24),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -24),

            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
        ])
    }

    @objc private func didSelect() {
        delegate?.didSelect(self)
    }
}
