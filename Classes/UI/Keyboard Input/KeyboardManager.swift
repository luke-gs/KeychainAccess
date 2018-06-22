//
//  KeyboardManager.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

final class KeyboardManager {
    let managedView: Weak<UIView>

    private let padding: CGFloat = 24
    private lazy var originalOrigin: CGFloat = {
        let localRect = managedView.object!.convert(UIApplication.shared.keyWindow!.frame, to: nil)
        return localRect.origin.y
    }()

    init(managedView: UIView) {
        self.managedView = Weak(managedView)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let managedView = managedView.object else { return }
        guard let keyboardDetails = notification.keyboardAnimationDetails() else { return }
        guard let responder = UIResponder.currentFirstResponder as? UIView else { return }

        let localRect = responder.convert(window.frame, to: nil)
        let bottomOfFrame = localRect.origin.y + responder.frame.size.height
        let difference = bottomOfFrame - keyboardDetails.endFrame.origin.y

        if difference > 0 {
            let offset = difference + padding
            UIView.animate(withDuration: keyboardDetails.duration) { [originalOrigin, offset] in
                managedView.frame.origin.y = originalOrigin - offset
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let managedView = managedView.object else { return }
        guard let keyboardDetails = notification.keyboardAnimationDetails() else { return }

        if managedView.frame.origin.y != originalOrigin {
            UIView.animate(withDuration: keyboardDetails.duration) { [originalOrigin] in
                managedView.frame.origin.y = originalOrigin
            }
        }
    }
}

extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?

    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}
