//
//  PhotoMediaPreviewViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit


public class PhotoMediaPreviewViewController: UIViewController {

    public let photoMedia: PhotoMedia

    private let imageView = UIImageView()

    private let titleLabel = UILabel()

    public init(photoMedia: PhotoMedia) {
        self.photoMedia = photoMedia
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        imageView.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: view.bounds.width))
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill

        titleLabel.frame = CGRect(origin: CGPoint(x: 0.0, y: imageView.frame.maxY + 15.0), size: CGSize(width: view.bounds.width, height: 20.0))
        titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1, compatibleWith: traitCollection)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white

        titleLabel.backgroundColor = #colorLiteral(red: 0.2, green: 0.2039215686, blue: 0.2274509804, alpha: 0.82)

        titleLabel.text = photoMedia.title
        titleLabel.layer.cornerRadius = 6.0
        titleLabel.clipsToBounds = true
        titleLabel.isHidden = photoMedia.title?.isEmpty ?? true

        var titleWidth: CGFloat = 0.0
        if var sizing = photoMedia.title?.sizing() {
            sizing.font = titleLabel.font
            sizing.numberOfLines = 1
            titleWidth = sizing.minimumWidth(compatibleWith: traitCollection) + 20.0
        }

        view.addSubview(imageView)
        view.addSubview(titleLabel)

        view.tintColor = .white
        view.backgroundColor = .white

        photoMedia.thumbnailImage?.loadImage(completion: { [weak self] (image) in
            self?.imageView.image = image.sizing().image
        })

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            imageView.heightAnchor.constraint(equalToConstant: view.bounds.width),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).withPriority(.defaultHigh),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: imageView.layoutMarginsGuide.bottomAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20.0),
            titleLabel.widthAnchor.constraint(equalToConstant: titleWidth).withPriority(.defaultHigh),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])

        preferredContentSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }

}
