//
//  CustomSubtitleButton.swift
//  Pods
//
//  Created by RUI WANG on 13/9/17.
//
//

import UIKit

open class CustomSubtitleButton: UIButton {
    
    open var topImageView: UIImageView!
    
    open var bottomLabel: UILabel!
    
    open var buttonActionHandler: ((CustomSubtitleButton) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        topImageView = UIImageView(frame: .zero)
        topImageView.contentMode = .scaleAspectFit
        self.addSubview(topImageView)
        
        bottomLabel = UILabel(frame: .zero)
        bottomLabel.textAlignment = .center
        bottomLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        bottomLabel.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        self.addSubview(bottomLabel)
        
        topImageView.image = AssetManager.shared.image(forKey: .location)
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topImageView.topAnchor.constraint(equalTo: topAnchor),

            bottomLabel.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: 8.0),
            bottomLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    open func config(image: UIImage, title: String) {
        topImageView.image = image
        bottomLabel.text = title
    }
    
    // MARK: Action methods
    
    @objc private func buttonDidSelected() {
        buttonActionHandler?(self)
    }
}
