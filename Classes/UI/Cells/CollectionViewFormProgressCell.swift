//
//  CollectionViewFormProgressCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 26/3/17.
//
//

import UIKit

open class CollectionViewFormProgressCell: CollectionViewFormValueFieldCell {

    public let progressView: UIProgressView = UIProgressView(progressViewStyle: .default)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.setContentHuggingPriority(UILayoutPriorityFittingSizeLevel, for: .horizontal)
        progressView.trackTintColor = #colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 0.25)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 2.0
        contentView.addSubview(progressView)
        
// TODO: Fix this
//        NSLayoutConstraint.activate([
//            NSLayoutConstraint(item: progressView, attribute: .centerY,  relatedBy: .equal, toItem: contentModeLayoutGuide, attribute: .centerY),
//            NSLayoutConstraint(item: progressView, attribute: .height,   relatedBy: .equal, toConstant: 4.0),
//            NSLayoutConstraint(item: progressView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin),
//            NSLayoutConstraint(item: progressView, attribute: .leading,  relatedBy: .equal, toItem: textLayoutGuide, attribute: .trailing, constant: 20.0),
//            
//            // I'd like the progress view to be as wide as it can be (where ambiguity may make it smaller) so I place in a constraint that cannot
//            // be fulfilled mathematically, but I'd like it to be obeyed as much as possible (fill as much as possible)
//            NSLayoutConstraint(item: progressView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, priority: UILayoutPriorityFittingSizeLevel)
//        ])
    }
    
}
