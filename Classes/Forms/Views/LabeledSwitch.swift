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
    
    private static let defaultOnTintColor: UIColor = .green
    private static let defaultTintColor: UIColor = .lightGray
    private static let defaultThumbTintColor: UIColor = .white
    
    /// Background color when the switch is on
    open var onTintColor: UIColor?
    
    /// Border color of the switch
    open override var tintColor: UIColor! {
        didSet {
            //
        }
    }
    
    /// Background color of the thumb
    open var thumbTintColor: UIColor?
    
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
    private var titleLabel = UILabel()
    
    
    // MARK: - Private Appearance
    
    /// Title for the switch in the on state
    private var onTitle: String?
    
    /// Title for the switch in the off state
    private var offTitle: String?
    
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
        switch state {
        case .on:
            onTitle = title
        case .off:
            offTitle = title
        }
    }
    
    /// Sets the title color for state
    open func setTitleColor(_ color: UIColor?, for state: State) {
        switch state {
        case .on:
            onTitleColor = color
        case .off:
            offTitleColor = color
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
    }
}
