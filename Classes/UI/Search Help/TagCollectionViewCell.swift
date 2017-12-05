//
//  TagCollectionViewCell.swift
//  MPOLKit
//
//  Created by Megan Efron on 9/9/17.
//
//

import UIKit

open class TagCollectionViewCell: UICollectionViewCell, DefaultReusable {
    
    open let label = UILabel()
    
    open static let font: UIFont = .systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 4.0
        contentView.layer.borderWidth = 1.0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = TagCollectionViewCell.font
        label.textAlignment = .center
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
}
