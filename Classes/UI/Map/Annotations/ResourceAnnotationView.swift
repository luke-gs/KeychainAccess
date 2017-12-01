//
//  ResourceAnnotationView.swift
//  MPOLKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class ResourceAnnotationView: MKAnnotationView {

    public static let defaultReuseIdentifier = "ResourceAnnotationView"
    
    // MARK: - Constants
    
    private struct LayoutConstants {
        static let detailsViewHeight: CGFloat = 16
        static let detailsViewRadius: CGFloat = 2
        
        static let circleSize: CGFloat = 40
        static let circleRadius: CGFloat = circleSize / 2
        static let circleImageMargin: CGFloat = 14
        
        static let imagePadding: CGFloat = 5
        
        static let borderSize: CGFloat = 2
    }
    
    // MARK: - Views
    
    /// A dark gray text area above the circle
    private var detailsView: UIView!
    
    /// The bold text in the details view
    private var detailsTitleLabel: UILabel!
    
    /// The regular text in the details view, next to the title
    private var detailsSubtitleLabel: UILabel!
    
    /// The main circle view with the resource icon inside
    private var circleView: UIView!
    
    /// The image view inside the circle
    private var imageView: UIImageView!
    
    // MARK: - Setup
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    public func configure(withAnnotation annotation: MKAnnotation, circleBorderColor: UIColor = .white, circleBackgroundColor: UIColor, resourceImage: UIImage?, imageTintColor: UIColor?) {
        self.annotation = annotation
        
        detailsTitleLabel.text = annotation.title ?? ""
        detailsSubtitleLabel.text = annotation.subtitle ?? ""
        imageView.image = resourceImage?.withCircleBackground(tintColor: imageTintColor,
                                                              circleColor: circleBackgroundColor,
                                                              padding: CGSize(width: LayoutConstants.imagePadding, height: LayoutConstants.imagePadding),
                                                              shrinkImage: true)
        circleView.backgroundColor = circleBackgroundColor
        circleView.layer.borderColor = circleBorderColor.cgColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        detailsView = UIView()
        detailsView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2039215686, blue: 0.2274509804, alpha: 1)
        detailsView.layer.cornerRadius = LayoutConstants.detailsViewRadius
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        detailsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        detailsView.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        detailsView.layer.shadowOpacity = 1
        detailsView.layer.shadowRadius = 4
        addSubview(detailsView)
        
        detailsTitleLabel = UILabel()
        detailsTitleLabel.textColor = .white
        detailsTitleLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.bold)
        detailsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsView.addSubview(detailsTitleLabel)

        detailsSubtitleLabel = UILabel()
        detailsSubtitleLabel.textColor = .white
        detailsSubtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        detailsSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsView.addSubview(detailsSubtitleLabel)

        circleView = UIView()
        circleView.layer.borderWidth = LayoutConstants.borderSize
        circleView.layer.cornerRadius = LayoutConstants.circleRadius
        circleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        circleView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        circleView.layer.shadowOpacity = 1
        circleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(circleView)
        
        imageView = UIImageView()
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        circleView.addSubview(imageView)
        
        centerOffset = CGPoint(x: 0, y: -16)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 64),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            detailsView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
            detailsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            detailsView.heightAnchor.constraint(equalToConstant: LayoutConstants.detailsViewHeight),

            detailsTitleLabel.centerYAnchor.constraint(equalTo: detailsView.centerYAnchor),
            detailsTitleLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 4),

            detailsSubtitleLabel.leadingAnchor.constraint(equalTo: detailsTitleLabel.trailingAnchor, constant: 2),
            detailsSubtitleLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -4),
            detailsSubtitleLabel.centerYAnchor.constraint(equalTo: detailsTitleLabel.centerYAnchor),

            circleView.topAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: 8),
            circleView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            circleView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            circleView.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor),

            circleView.heightAnchor.constraint(equalToConstant: LayoutConstants.circleSize),
            circleView.widthAnchor.constraint(equalToConstant: LayoutConstants.circleSize),

            imageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: -1),
        ])
    }
}
