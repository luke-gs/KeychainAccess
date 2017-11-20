//
//  LabeledSwitch.swift
//  MPOLKit
//
//  Created by Kyle May on 15/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// `UISwitch` replicated with a title and image
open class LabeledSwitch: UIControl {
    
    // MARK: - State
    
    /// Possible switch states
    public enum State {
        case on
        case off
    }
    
    /// Current state of the switch
    private var switchState: State = .off
    
    /// Whether the switch is in the on state
    public var isOn: Bool {
        return switchState == .on
    }
    
    // MARK: - Appearance
    
    private let defaultOnTintColor: UIColor = .green
    private let defaultOffTintColor: UIColor = .clear
    private let defaultThumbTintColor: UIColor = .white
    private let defaultOnTitleColor: UIColor = .white
    private let defaultOffTitleColor: UIColor = .gray
    private let defaultOnBorderTintColor: UIColor = .clear
    private let defaultOffBorderTintColor: UIColor = .gray
    
    /// Background color when the switch is on
    open var onTintColor: UIColor? {
        didSet {
            if isOn {
                backgroundColor = onTintColor ?? defaultOnTintColor
            }
        }
    }
    
    /// Background color when the switch is off
    open var offTintColor: UIColor? {
        didSet {
            if !isOn {
                backgroundColor = offTintColor ?? defaultOffTintColor
            }
        }
    }
    
    /// Border color when the switch is on
    open var onBorderTintColor: UIColor? {
        didSet {
            if isOn {
                layer.borderColor = onBorderTintColor?.cgColor ?? defaultOnBorderTintColor.cgColor
            }
        }
    }
    
    /// Border color when the switch is off
    open var offBorderTintColor: UIColor? {
        didSet {
            if !isOn {
                layer.borderColor = onBorderTintColor?.cgColor ?? defaultOffBorderTintColor.cgColor
            }
        }
    }
    
    /// Background color of the thumb
    open var thumbTintColor: UIColor? {
        didSet {
            thumb.backgroundColor = thumbTintColor ?? defaultThumbTintColor
        }
    }
    
    /// Image to display on the thumb
    open var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    // MARK: - Views
    
    /// Moving circle part of the switch
    private var thumb = UIView()
    
    /// Image view to be displayed on the thumb
    private var imageView = UIImageView()
    
    /// Label for title text
    private var titleLabel: UILabel?
    
    // MARK: - Private Appearance
    
    /// Title for the switch in the on state
    private var onTitle: String? {
        didSet {
            if switchState == .on {
                titleLabel?.text = onTitle
            }
        }
    }
    
    /// Title for the switch in the off state
    private var offTitle: String? {
        didSet {
            if switchState == .off {
                titleLabel?.text = offTitle
            }
        }
    }
    
    /// Color for the title in the on state
    private var onTitleColor: UIColor?
    
    /// Color for title in the off state
    private var offTitleColor: UIColor?
    
    /// Color for the image in the on state
    private var onImageColor: UIColor?
    
    /// Color for image in the off state
    private var offImageColor: UIColor?
    
    
    // MARK: - Appearance setting
    
    /// Set title color for state
    open func setTitle(_ title: String?, for state: State) {
        if title != nil && titleLabel == nil {
            // Create the title label if it doesn't exist
            titleLabel = UILabel()
            insertSubview(titleLabel!, belowSubview: thumb)
        }
        
        switch state {
        case .on:
            onTitle = title
        case .off:
            offTitle = title
        }
        
        setNeedsLayout()
    }
    
    open func setTitleFont(_ font: UIFont) {
        titleLabel?.font = font
        setNeedsLayout()
    }
    
    /// Sets the title color for state
    open func setTitleColor(_ color: UIColor?, for state: State) {
        switch state {
        case .on:
            onTitleColor = color
            if switchState == .on {
                titleLabel?.textColor = onTitleColor
            }
        case .off:
            offTitleColor = color
            if switchState == .off {
                titleLabel?.textColor = offTitleColor
            }
        }
    }
    
    /// Sets the image color for state
    open func setImageColor(_ color: UIColor?, for state: State) {
        switch state {
        case .on:
            onImageColor = color
        case .off:
            offImageColor = color
        }
        
        if state == .on {
            imageView.tintColor = onImageColor
        } else {
            imageView.tintColor = offImageColor
        }
    }
    
    open func setOn(_ on: Bool, animated: Bool) {
        let animationDuration: CFTimeInterval = 0.3
        
        let thumbRect: CGRect
        let titlePoint: CGPoint
        
        let tintColor: UIColor
        let titleColor: UIColor
        let borderTintColor: UIColor
        let imageTintColor: UIColor

        if on {
            thumbRect = getThumbRect(for: .on, in: self.frame)
            titlePoint = getTitlePoint(for: .on, in: self.frame)
            
            tintColor = self.onTintColor ?? defaultOnTintColor
            titleColor = self.onTitleColor ?? defaultOnTitleColor
            borderTintColor = self.onBorderTintColor ?? defaultOnBorderTintColor
            imageTintColor = self.onImageColor ?? defaultOnTintColor
            
            switchState = .on
            titleLabel?.text = onTitle
        } else {
            thumbRect = getThumbRect(for: .off, in: self.frame)
            titlePoint = getTitlePoint(for: .off, in: self.frame)
            
            tintColor = self.offTintColor ?? defaultOffTintColor
            titleColor = self.offTitleColor ?? defaultOffTitleColor
            borderTintColor = self.offBorderTintColor ?? defaultOffBorderTintColor
            imageTintColor = self.offImageColor ?? defaultOffTintColor
            
            switchState = .off
            titleLabel?.text = offTitle
        }
        
        sendActions(for: .valueChanged)
        
        if animated {
            // Animate background colour change
            UIView.animate(withDuration: animationDuration, animations: {
                self.backgroundColor = tintColor
                self.layer.borderColor = borderTintColor.cgColor
                self.imageView.tintColor = imageTintColor
            })
            
            // Animate moving the thumb
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.thumb.frame.origin.x = thumbRect.origin.x
            }, completion: nil)
            
            if let titleLabel = titleLabel {
                // Fade title color
                UIView.transition(with: titleLabel, duration: animationDuration, options: .transitionCrossDissolve, animations: {
                    titleLabel.textColor = titleColor
                }, completion: nil)
                
                // Move title to other side
                UIView.animate(withDuration: animationDuration, animations: {
                    titleLabel.frame.origin = titlePoint
                })
            }
        } else {
            backgroundColor = tintColor
            thumb.frame.origin.x = thumbRect.origin.x
            titleLabel?.textColor = titleColor
            titleLabel?.frame.origin = titlePoint
            layer.borderColor = borderTintColor.cgColor
            imageView.tintColor = imageTintColor
        }
    }
    
    // MARK: - Setup
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    /// Creates and styles views
    private func setupViews() {
        layer.borderWidth = 2
        
        thumb.backgroundColor = thumbTintColor ?? defaultThumbTintColor
        thumb.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        thumb.layer.shadowRadius = 3
        thumb.layer.shadowOffset = CGSize(width: 0, height: 3)
        thumb.layer.shadowOpacity = 1
        addSubview(thumb)
        
        imageView.contentMode = .scaleAspectFit
        thumb.addSubview(imageView)
        
        setOn(false, animated: false)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSelectView))
        addGestureRecognizer(tapRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didSelectView))
        addGestureRecognizer(panRecognizer)
    }
    
    @objc private func didSelectView(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            if let panGesture = sender as? UIPanGestureRecognizer {
                let velocity = panGesture.velocity(in: self)
                guard fabs(velocity.x) > fabs(velocity.y) else { return }
            }
            setOn(!isOn, animated: true)
        }
    }
    
    private struct LayoutConstants {
        static let thumbPadding: CGFloat = 2
        static let textPadding: CGFloat = 16
        static let imagePadding: CGFloat = 8
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let thumbSize = frame.height - 4
        
        if let titleLabel = titleLabel {
            let titleSize: CGSize
            
            // Get title sizes
            if onTitle != nil || offTitle != nil {
                var onSized: StringSizing?
                var offSized: StringSizing?
                
                if let onTitle = onTitle {
                    onSized = StringSizing(string: onTitle, font: titleLabel.font, numberOfLines: 1)
                }
                
                if let offTitle = offTitle {
                    offSized = StringSizing(string: offTitle, font: titleLabel.font, numberOfLines: 1)
                }
                
                let onWidth = onSized?.minimumWidth(compatibleWith: traitCollection) ?? 0
                let offWidth = offSized?.minimumWidth(compatibleWith: traitCollection) ?? 0
                let width = max(onWidth, offWidth)
                
                let onHeight = onSized?.minimumHeight(inWidth: width, compatibleWith: traitCollection) ?? 0
                let offHeight = offSized?.minimumHeight(inWidth: width, compatibleWith: traitCollection) ?? 0
                let height = max(onHeight, offHeight)
                
                titleSize = CGSize(width: width, height: height)
            } else {
                titleSize = .zero
            }
            
            // Size and layout title
            titleLabel.frame.size = titleSize
            titleLabel.center.y = self.frame.height / 2
            titleLabel.frame.origin = getTitlePoint(for: switchState, in: frame)

            // Set frame width
            let frameWidth = titleLabel.frame.width + LayoutConstants.textPadding * 2 + thumbSize + LayoutConstants.thumbPadding
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frameWidth, height: frame.height)
            
        } else {
            let frameWidth = thumbSize + LayoutConstants.textPadding + LayoutConstants.thumbPadding * 2
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frameWidth, height: frame.height)
        }
        
        // Layout thumb
        thumb.frame = getThumbRect(for: switchState, in: frame)
        
        // Layout image view
        let imageSize = thumb.frame.width - (LayoutConstants.imagePadding * 2)
        imageView.frame = CGRect(x: LayoutConstants.imagePadding, y: LayoutConstants.imagePadding, width: imageSize, height: imageSize)

        thumb.layer.cornerRadius = thumbSize / 2
        layer.cornerRadius = frame.height / 2
        
        invalidateIntrinsicContentSize()
    }
    
    open override var intrinsicContentSize: CGSize {
        return frame.size
    }
    
    /// Gets the rect to use to position the thumb
    private func getThumbRect(for state: State, in rect: CGRect) -> CGRect {
        let thumbSize = rect.height - (2 * LayoutConstants.thumbPadding)
        let thumbX = state == .on ? frame.width - thumbSize - LayoutConstants.thumbPadding : LayoutConstants.thumbPadding
        return CGRect(x: thumbX, y: LayoutConstants.thumbPadding, width: thumbSize, height: thumbSize)
    }
    
    /// Gets the point to use to position the title
    private func getTitlePoint(for state: State, in rect: CGRect) -> CGPoint {
        guard let titleLabel = titleLabel else { return .zero }
        
        let titleX = state == .on ? LayoutConstants.textPadding : frame.width - titleLabel.frame.width - LayoutConstants.textPadding
        return CGPoint(x: titleX, y: titleLabel.frame.origin.y)
    }
}
