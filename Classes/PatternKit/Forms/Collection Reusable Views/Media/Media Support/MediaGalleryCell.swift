//
//  MediaGalleryCell.swift
//  MPOLKit
//
//  Created by James Aramroongrot on 13/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation


open class MediaGalleryCell: MediaPreviewableCell {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = nil
        
        contentView.layer.cornerRadius = 0.0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
