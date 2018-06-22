//
//  HighlightingTextContainer.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

/// A struct used to wrap the required information
/// for the `HighlightingTextView`
public struct HighlightTextContainerThing {

    /// The text to display
    public var text: String

    /// The text to highlight
    public var highlightText: String

    /// The action to perform when the text is tapped
    public var action: ((UIViewController)->())?

    /// Intializer
    ///
    /// - Parameters:
    ///   - text: the text to display
    ///   - highlightText: the text to highlight
    ///   - action: the action to perform when the text is tapped
    public init(text: String, highlightText: String, action: ((UIViewController)->())?) {
        self.text = text
        self.highlightText = highlightText
        self.action = action
    }
}

/// TextView which automatically highlights text in the form of a link
/// to be used with the UITextViewDelegate`'s
///
/// `textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction)`
///
/// which still needs to be implemented by the delegate
public class HighlightingTextView: UITextView {

    /// The text highlight container
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
