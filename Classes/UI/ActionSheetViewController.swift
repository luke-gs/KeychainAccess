//
//  ActionSheetViewController.swift
//  MPOLKit
//
//  Created by Megan Efron on 8/12/17.
//

import UIKit

open class ActionSheetButton {
    
    public typealias ActionSheetButtonAction = () -> Void
    
    open var title: String
    open var subtitle: String?
    open var icon: UIImage?
    open var action: ActionSheetButtonAction?
    open var tintColor: UIColor?
    
    public init(title: String, subtitle: String? = nil, icon: UIImage?, tintColor: UIColor? = nil, action: ActionSheetButtonAction?) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tintColor = tintColor
        self.action = action
    }
}

open class ActionSheetViewController: FormBuilderViewController {
    
    open var buttons: [ActionSheetButton]
    open var preferredContentWidth: CGFloat = 200
    
    public init(buttons: [ActionSheetButton]) {
        self.buttons = buttons
        super.init()
    }
    
    open override func construct(builder: FormBuilder) {
        builder.title = nil
        builder.forceLinearLayout = true
        
        buttons.forEach { button in
            builder += SubtitleFormItem()
                .title(button.title)
                .subtitle(button.subtitle)
                .image(button.icon)
                .imageTintColor(button.tintColor)
                .onSelection({ _ in
                    button.action?()
                })
        }
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // We need to set this manually because we are not presenting this in a PopoverNavigationController
        wantsTransparentBackground = !UIViewController.isWindowCompact()
        
        self.reloadForm()
        collectionView?.setNeedsLayout()
        collectionView?.layoutIfNeeded()
        
        preferredContentSize = collectionView?.contentSize ?? .zero
        preferredContentSize.width = preferredContentWidth
    }
}
