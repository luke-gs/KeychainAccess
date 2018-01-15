//
//  PixelWidthView.swift
//  MPOLKit
//
//  Created by QHMW64 on 15/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class PixelWidthView: UIView {

    public enum NibSize: CGFloat {
        case small = 5
        case medium = 25
        case large = 50
        case giant = 100


        init(value: CGFloat) {
            switch value {
            case 5: self = .small
            case 25: self = .medium
            case 50: self = .large
            case 100: self = .giant
            default:
                let values = NibSize.allCases
                var closestMatch = NibSize.giant
                var closestDelta = CGFloat.infinity
                values.forEach {
                    let delta: CGFloat = CGFloat(fabs(Double($0.rawValue - value)))
                    if delta < closestDelta {
                        closestMatch = $0
                        closestDelta = CGFloat(delta)
                    }
                }
                self = closestMatch
            }
        }

        var image: UIImage? {
            return UIImage.circle(diameter: rawValue, color: .darkGray)
        }

        static var allCases: [NibSize] = [.small, .medium, .large, .giant]
    }

    var selectionHandler: (() -> ())?

    let label: UILabel = UILabel()
    let imageView: UIImageView = UIImageView()
    let nibSize: NibSize

    init(nibSize: NibSize = .giant) {
        self.nibSize = nibSize

        super.init(frame: .zero)

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(gesture:))))

        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.text = "\(Int(nibSize.rawValue)) px"
        addSubview(label)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = nibSize.image
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),

            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8.0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),
            ])
    }

    func update(with nibSize: NibSize) {
        imageView.image = nibSize.image
        label.text = "\(Int(nibSize.rawValue)) px"
    }

    @objc private func viewTapped(gesture: UITapGestureRecognizer) {
        selectionHandler?()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
