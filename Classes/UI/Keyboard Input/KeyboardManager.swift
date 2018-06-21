//
//  KeyboardManager.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

final class KeyboardManager {
    let managedView: Weak<UIView>

    private var offset : CGFloat = 0
    private let padding: CGFloat = 24

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
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        guard let responder = UIResponder.currentFirstResponder as? UIView else { return }

        let localRect = responder.convert(window.frame, to: nil)
        let originHeight = localRect.origin.y + responder.frame.size.height
        let difference = originHeight - keyboardSize.origin.y

        print(difference)

        if difference > 0 {
            offset = difference + padding
            UIView.animate(withDuration: keyboardDuration.doubleValue) { [offset] in
                managedView.frame.origin.y -= offset
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let managedView = managedView.object else { return }
        guard let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }

        if offset > 0 {
            UIView.animate(withDuration: keyboardDuration.doubleValue) { [offset] in
                managedView.frame.origin.y += offset
            }
            offset = 0
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
