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

    // MARK: - Constants
    
    private struct LayoutConstants {
        static let detailsViewHeight: CGFloat = 16
        static let detailsViewRadius: CGFloat = 2
        
        static let circleSize: CGFloat = 50
        static let circleRadius: CGFloat = circleSize / 2
        static let circleImageMargin: CGFloat = 14
        
        static let borderSize: CGFloat = 4
    }
    
    // MARK: - View properties
    
    private var circleBorderColor: UIColor
    private var circleBackgroundColor: UIColor
    private var resourceImage: UIImage?
    
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
    
    public init(annotation: MKAnnotation?, reuseIdentifier: String?, circleBorderColor: UIColor = .white, circleBackgroundColor: UIColor, resourceImage: UIImage?) {
        self.circleBorderColor = circleBorderColor
        self.circleBackgroundColor = circleBackgroundColor
        self.resourceImage = resourceImage

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
        configureViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        detailsView = UIView()
        detailsView.backgroundColor = UIColor(red: 86.0 / 255.0, green: 88.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)
        detailsView.layer.cornerRadius = LayoutConstants.detailsViewRadius
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(detailsView)
        
        detailsTitleLabel = UILabel()
        detailsTitleLabel.textColor = .white
        detailsTitleLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightBold)
        detailsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsView.addSubview(detailsTitleLabel)

        detailsSubtitleLabel = UILabel()
        detailsSubtitleLabel.textColor = .white
        detailsSubtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightRegular)
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
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 50),
            
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
            imageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: -2),
        ])
    }

    /// Sets the data on the views from the annotation
    func configureViews() {
        detailsTitleLabel.text = annotation?.title ?? ""
        detailsSubtitleLabel.text = annotation?.subtitle ?? ""
        imageView.image = resourceImage
        circleView.backgroundColor = circleBackgroundColor
        circleView.layer.borderColor = circleBorderColor.cgColor
    }

}
