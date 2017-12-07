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
    
    public init(title: String, subtitle: String? = nil, icon: UIImage?, action: ActionSheetButtonAction?) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
    }
}

open class ActionSheetViewController: FormBuilderViewController {
    
    open var buttons: [ActionSheetButton]

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
                .onSelection({ _ in
                    button.action?()
                })
        }
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Support being transparent when in popover/form sheet
    open override var wantsTransparentBackground: Bool {
        didSet {
            let theme = ThemeManager.shared.theme(for: .current)
            view.backgroundColor = wantsTransparentBackground ? .clear : theme.color(forKey: .background)!
        }
    }
}
