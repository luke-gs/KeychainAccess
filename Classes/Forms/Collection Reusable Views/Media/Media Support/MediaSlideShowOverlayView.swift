//
//  MediaSlideShowOverlayView.swift
//  MPOLKit
//
//  Created by KGWH78 on 31/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit

public protocol MediaOverlayViewable: class {

    weak var slideShowViewController: (MediaSlideShowable & MediaSlideShowViewController)? { get set }

    func populateWithPreview(_ preview: MediaPreviewable?)

    func setHidden(_ hidden: Bool, animated: Bool)

    func view() -> UIView

}

extension MediaOverlayViewable where Self: UIView {

    public func view() -> UIView {
        return self
    }

}

public class MediaSlideShowOverlayView: UIView, MediaOverlayViewable, MediaDetailViewControllerDelegate {

    private let titleLabel = UILabel()
    private let commentLabel = UILabel()

    private let captionsBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    private lazy var textStackView = UIStackView(arrangedSubviews: [titleLabel, commentLabel])

    private let textPadding: CGFloat = 12

    private var hidingViewConstraint: NSLayoutConstraint?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        captionsBackgroundView.clipsToBounds = true
        captionsBackgroundView.alpha = 0.75
        addSubview(captionsBackgroundView)

        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1

        commentLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        commentLabel.font = UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        commentLabel.textAlignment = .center
        commentLabel.numberOfLines = 4

        textStackView.axis = .vertical
        textStackView.alignment = .fill
        textStackView.distribution = .fill
        textStackView.spacing = textPadding
        addSubview(textStackView)

        captionsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false

        hidingViewConstraint = captionsBackgroundView.topAnchor.constraint(equalTo: bottomAnchor)

        NSLayoutConstraint.activate([
            captionsBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            captionsBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            captionsBackgroundView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            textStackView.leadingAnchor.constraint(equalTo: captionsBackgroundView.readableContentGuide.leadingAnchor, constant: textPadding).withPriority(.almostRequired),
            textStackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor).withPriority(.almostRequired),
            textStackView.topAnchor.constraint(equalTo: captionsBackgroundView.readableContentGuide.topAnchor, constant: textPadding),
            textStackView.bottomAnchor.constraint(equalTo: captionsBackgroundView.readableContentGuide.bottomAnchor, constant: -textPadding),

            textStackView.centerXAnchor.constraint(equalTo: captionsBackgroundView.centerXAnchor)
        ])
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public var slideShowViewController: (MediaSlideShowable & MediaSlideShowViewController)? {
        didSet {
            let preview = slideShowViewController?.currentPreview
            updateDetailsWithPreview(preview)
            setupNavigationItemsWithPreview(preview)
        }
    }

    public func setHidden(_ hidden: Bool, animated: Bool) {
        guard isHidden != hidden else { return }

        let finalColor: UIColor = hidden ? .black : .white

        hidingViewConstraint?.isActive = hidden

        if animated {

            let isCurrentlyHidden = isHidden
            // Unhide first so the view can be animated in.
            if isCurrentlyHidden && !hidden {
                isHidden = false
            }

            slideShowViewController?.view.backgroundColor = hidden ? .white : .black

            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction], animations: {
                self.layoutIfNeeded()
                self.slideShowViewController?.view.backgroundColor = finalColor

            }, completion: { result in
                self.isHidden = hidden
                self.slideShowViewController?.view.backgroundColor = finalColor
            })
        } else {
            isHidden = hidden
            slideShowViewController?.view.backgroundColor = finalColor
        }

        slideShowViewController?.navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }

    private func updateDetailsWithPreview(_ preview: MediaPreviewable?) {
        if let preview = preview,
            let viewModel = slideShowViewController?.viewModel,
            let index = viewModel.indexOfPreview(preview) {
            slideShowViewController?.navigationItem.title = String.localizedStringWithFormat("Asset %1$d of %2$d", index + 1, viewModel.previews.count)
            
            titleLabel.text = preview.title
            commentLabel.text = preview.comments
        } else {
            slideShowViewController?.navigationItem.title = nil
            titleLabel.text = nil
            commentLabel.text = nil
        }
        
        titleLabel.isHidden = titleLabel.text?.isEmpty ?? true
        commentLabel.isHidden = commentLabel.text?.isEmpty ?? true
        captionsBackgroundView.isHidden = titleLabel.isHidden && commentLabel.isHidden

        titleLabel.alpha = 0.0
        commentLabel.alpha = 0.0

        layoutIfNeeded()

        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [.calculationModeCubic], animations: {

            // Animate the UIStackView size changes first, triggered due to the titleLabel & commentLabel changes.
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                self.layoutIfNeeded()
            })

            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7, animations: {
                self.titleLabel.alpha = 1.0
                self.commentLabel.alpha = 1.0
            })

        }, completion: nil)

    }

    public func populateWithPreview(_ preview: MediaPreviewable?) {
        updateDetailsWithPreview(preview)
        setupNavigationItemsWithPreview(preview)
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event), view != self {
            return view
        }
        return nil
    }

    // MARK: - PhotoMediaDetailViewControllerDelegate

    public func mediaDetailViewControllerDidUpdateMedia(_ detailViewController: MediaDetailViewController) {
        guard let slideShowViewController = slideShowViewController, let currentPhotoPreview = slideShowViewController.currentPreview else { return }

        populateWithPreview(currentPhotoPreview)
        _ = slideShowViewController.viewModel.replaceMedia(currentPhotoPreview.media, with: currentPhotoPreview.media)
    }

    // MARK: - Private

    @objc func closeTapped() {
        slideShowViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func removeTapped(_ item: UIBarButtonItem) {
        slideShowViewController?.handleDeletePreviewButtonTapped(item)
    }

    @objc func editTapped(_ item: UIBarButtonItem) {
        guard let slideShowViewController = slideShowViewController,
            let currentPreview = slideShowViewController.currentPreview else { return }

        let detailViewController = MediaDetailViewController(media: currentPreview.media)
        detailViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: detailViewController)
        navigationController.modalPresentationStyle = .formSheet

        slideShowViewController.present(navigationController, animated: true, completion: nil)
    }

    private func setupNavigationItemsWithPreview(_ preview: MediaPreviewable?) {
        if let navigationItem = slideShowViewController?.navigationItem {
            if slideShowViewController?.allowEditing == true && preview != nil {
                let removeItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeTapped(_:)))
                let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped(_:)))

                navigationItem.rightBarButtonItems = [editItem, removeItem]
            } else {
                navigationItem.rightBarButtonItems = nil
            }
        }
    }


}
