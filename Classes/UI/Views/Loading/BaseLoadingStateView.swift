//
//  BaseLoadingStateView.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 24/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

private var contentContext = 1

@available(iOS, introduced: 10.0, obsoleted: 11.0)
private var hiddenContext = 2

/// A standard view for showing loading state content.
///
/// `BaseLoadingStateView` is a UIStackView subclass designed for convenience with
/// the standard MPOL no content views correctly configured. The standard
/// views' `isHidden` property is managed by the class when the content
/// changes to or from nil. You can also adjust them manually where required.
///
/// Prior to iOS 11, spacers are used to insert custom space between the image
/// and title, and subtitle and button. On iOS 11 and later, this is managed
/// by the UIStackView custom spacing methods.
open class BaseLoadingStateView: UIStackView {

    // MARK: - Public properties

    /// The image container view, for an image or progress indicator.
    public let imageContainerView = UIView(frame: .zero)

    /// The title label.
    public let titleLabel = UILabel(frame: .zero)

    /// The subtitle label.
    public let subtitleLabel = UILabel(frame: .zero)

    /// The action button.
    public let actionButton = RoundedRectButton(frame: .zero)

    /// The spacer used to separate the image and title label.
    ///
    /// This property is deprecated in iOS 11+. Please use UIStackView's
    /// custom spacing methods.
    @available(iOS, introduced: 10.0, deprecated: 11.0, message: "Use custom sizes in iOS 11")
    public private(set) lazy var imageSpacer = SpacerView(frame: CGRect(x: 0.0, y: 0.0, width: 8.0, height: 16.0))


    /// The spacer used to separate the subtitle label and button.
    ///
    /// This property is deprecated in iOS 11+. Please use UIStackView's
    /// custom spacing methods.
    @available(iOS, introduced: 10.0, deprecated: 11.0, message: "Use custom sizes in iOS 11")
    public private(set) lazy var buttonSpacer = SpacerView(frame: CGRect(x: 0.0, y: 0.0, width: 8.0, height: 20.0))


    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let theme = ThemeManager.shared.theme(for: .current)

        imageContainerView.isHidden = true
        titleLabel.isHidden = true
        subtitleLabel.isHidden = true
        actionButton.isHidden = true

        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = theme.color(forKey: .primaryText)
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.textColor = .secondaryGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        actionButton.layer.cornerRadius = 4
        actionButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 48, bottom: 6, right: 48)
        
        alignment = .center
        axis = .vertical
        spacing = 16

        addArrangedSubview(imageContainerView)
        addArrangedSubview(titleLabel)
        addArrangedSubview(subtitleLabel)
        addArrangedSubview(actionButton)

        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), context: &contentContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &contentContext)
        subtitleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), context: &contentContext)
        subtitleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &contentContext)
        actionButton.addObserver(self, forKeyPath: #keyPath(RoundedRectButton.titleLabel.text), context: &contentContext)
        actionButton.addObserver(self, forKeyPath: #keyPath(RoundedRectButton.titleLabel.attributedText), context: &contentContext)

        if #available(iOS 11, *) {
            setCustomSpacing(16, after: imageSpacer)
            setCustomSpacing(20, after: subtitleLabel)
            return
        }

        imageSpacer.isHidden = true
        buttonSpacer.isHidden = true

        insertArrangedSubview(buttonSpacer, at: 4)

        imageContainerView.addObserver(self, forKeyPath: #keyPath(UIView.isHidden), context: &hiddenContext)
        actionButton.addObserver(self, forKeyPath: #keyPath(UIButton.isHidden), context: &hiddenContext)
    }

    deinit {
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &contentContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &contentContext)
        subtitleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &contentContext)
        subtitleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &contentContext)
        actionButton.removeObserver(self, forKeyPath: #keyPath(RoundedRectButton.titleLabel.text), context: &contentContext)
        actionButton.removeObserver(self, forKeyPath: #keyPath(RoundedRectButton.titleLabel.attributedText), context: &contentContext)

        if #available(iOS 11, *) {
            return
        }

        imageContainerView.removeObserver(self, forKeyPath: #keyPath(UIView.isHidden), context: &hiddenContext)
        actionButton.removeObserver(self, forKeyPath: #keyPath(UIButton.isHidden), context: &hiddenContext)
    }

    // MARK: - Overrides

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &contentContext {
            switch object {
            case let label as UILabel:
                label.isHidden = label.text?.isEmpty ?? true
            case let button as RoundedRectButton:
                button.isHidden = button.titleLabel?.text?.isEmpty ?? true
            default:
                break
            }
        } else if context == &hiddenContext {
            switch object {
            case let button as RoundedRectButton:
                buttonSpacer.isHidden = button.isHidden
            case let imageContainerView as UIView:
                imageSpacer.isHidden = imageContainerView.isHidden
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

}
