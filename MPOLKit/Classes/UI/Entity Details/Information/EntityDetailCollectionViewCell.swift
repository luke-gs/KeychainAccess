//
//  EntityDetailCollectionViewCell.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class EntityDetailCollectionViewCell: CollectionViewFormCell {
    
    /// The image view for the cell.
    var imageView: UIImageView { return borderedImageView.imageView }
    
    
    /// The source label.
    let sourceLabel = RoundedRectLabel(frame: .zero)
    
    
    /// The title label. This should be used for details such as the driver's name,
    /// vehicle's registration, etc.
    let titleLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The subtitle label. This should be used for ancillery entity details.
    let subtitleLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The detail label. This should be any secondary details.
    let detailLabel: UILabel = UILabel(frame: .zero)
    
    
    /// The description label. This should be a description of the entity, attributes etc.
    let descriptionLabel: UILabel = UILabel(frame: .zero)
    
    
    /// A button for selecting/entering additional descriptions.
    var additionalDescriptionsButton = UIButton(type: .system)
    
    
    /// The alert color for the entity.
    var alertColor: UIColor? {
        get { return borderedImageView.borderColor }
        set { borderedImageView.borderColor = newValue }
    }
    
    
    /// The delegate for the cell.
    /// 
    /// It is recommended you become the cell's delegate rather than using target action
    /// on the `additionalDescriptionButton`.
    public weak var delegate: EntityDetailCollectionViewCellDelegate?
    
    
    fileprivate let borderedImageView = BorderedImageView(frame: .zero)
    
    
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
        contentView.addSubview(borderedImageView)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(additionalDescriptionsButton)
        
        additionalDescriptionsButton.addTarget(self, action: #selector(additionalDescriptionsButtonDidSelect), for: .touchUpInside)
    }
    
}



protocol EntityDetailCollectionViewCellDelegate: class {
    
    func entityDetailCellDidSelectAdditionalDescriptions(_ cell: EntityDetailCollectionViewCell)
    
}



fileprivate extension EntityDetailCollectionViewCell {
    
    @objc fileprivate func additionalDescriptionsButtonDidSelect() {
        delegate?.entityDetailCellDidSelectAdditionalDescriptions(self)
    }
    
}
