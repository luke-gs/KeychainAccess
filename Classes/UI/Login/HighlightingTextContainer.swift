//
//  HighlightingTextContainer.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public struct HighlightTextContainerThing {
    public var text: String
    public var highlightText: String
    public var action: ((UIViewController)->())?

    public init(text: String, highlightText: String, action: ((UIViewController)->())?) {
        self.text = text
        self.highlightText = highlightText
        self.action = action
    }
}

public class HighlightingTextView: UITextView {
    public var highlightContainerThing: HighlightTextContainerThing? {
        didSet {
            guard let highlightContainerThing = highlightContainerThing else { return }

            let text = NSMutableAttributedString(string: highlightContainerThing.text)
            let range = text.mutableString.range(of: highlightContainerThing.highlightText)

            text.addAttribute(.link, value: "", range: range)
            text.addAttribute(.foregroundColor, value: ThemeManager.shared.theme(for: .current).color(forKey: .tint)!, range: range)

            self.attributedText = text
        }
    }

    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init() {
        super.init(frame: .zero, textContainer: nil)
        self.isEditable = false
        self.isSelectable = true
        self.isScrollEnabled = false
        self.backgroundColor = .clear
    }
}
