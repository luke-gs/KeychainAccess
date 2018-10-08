//
//  TravelTimeAccessoryView.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import PromiseKit

/// View used for Traveltime.
/// Consists of an icon indicating travel type
/// a distance label and a time label
public class TravelTimeAccessoryView: UIView {
    public var timeLabel: UILabel = UILabel(frame: .zero)
    public var distanceLabel: UILabel = UILabel(frame: .zero)
    public var imageView: UIImageView = UIImageView(frame: .zero)
    
    public init (image: UIImage?, distance: String?, time: String?, frame: CGRect){
        super.init(frame: frame)
        
        [timeLabel, distanceLabel, imageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        timeLabel.text = time
        timeLabel.textAlignment = .right
        timeLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        timeLabel.layer.masksToBounds = true
        
        distanceLabel.text = distance
        distanceLabel.textAlignment = .right
        distanceLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        distanceLabel.layer.masksToBounds = true
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        let theme = ThemeManager.shared.theme(for: .current)
        
        timeLabel.textColor = theme.color(forKey: .secondaryText)
        distanceLabel.textColor = theme.color(forKey: .secondaryText)
        imageView.tintColor = theme.color(forKey: .secondaryText)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            imageView.heightAnchor.constraint(equalTo: timeLabel.heightAnchor),
            timeLabel.topAnchor.constraint(equalTo: topAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: imageView.trailingAnchor, constant: 8),
            distanceLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor),
            distanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            distanceLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            distanceLabel.widthAnchor.constraint(equalTo: timeLabel.widthAnchor)
            ])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open func apply(theme: Theme) {
        timeLabel.textColor = theme.color(forKey: .secondaryText)
        distanceLabel.textColor = theme.color(forKey: .secondaryText)
        imageView.tintColor = theme.color(forKey: .secondaryText)
    }
}
