//
//  FancyLoginViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import LocalAuthentication

final public class FancyLoginViewController: UIViewController {

    public let mode: LoginMode

    public let titleLabel: UILabel = UILabel()
    public let loginButton: UIButton = UIButton()
    public let subtitleTextView: HighlightingTextView = HighlightingTextView()
    public let detailTextView: HighlightingTextView = HighlightingTextView()

    public var subtitleContainer: HighlightTextContainerThing?
    public var credentials: [LabeledTextField]?
    public var detailContainer: HighlightTextContainerThing?
    public var shouldUseBiometric: Bool = false

    private let credentialsStackView: UIStackView = UIStackView()

    private lazy var authenticationContext = LAContext()
    private(set) lazy var biometricButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)

        var imageKey: AssetManager.ImageKey = .touchId
        var buttonText = " or use Touch ID"
        // Apple lies, it's not @available(iOS 11.0, *), it's later.
        // Crash on iOS 11.0
        if #available(iOS 11.0.1, *) {
            if authenticationContext.biometryType == .faceID {
                imageKey = .faceId
                buttonText = " or user Face ID"
            }
        }

        button.setImage(AssetManager.shared.image(forKey: imageKey), for: .normal)
        button.setTitle(buttonText, for: .normal)
//        button.addTarget(self, action: #selector(biometricButtonTriggered), for: .primaryActionTriggered)
//        button.addTarget(self, action: #selector(biometricButtonTouchDown), for: .touchDown)
        button.tintColor = UIColor(red:0.35, green:0.78, blue:0.98, alpha:1)

        return button
        }()


    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(mode: LoginMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)

        subtitleContainer = HighlightTextContainerThing(text: "By continuing you are agreeing to the Terms and Conditions of Use previously presented to you.",
                                                        highlightText: "Terms and Conditions of Use") { vc in
                                                            print("HELLO!!")
        }

        detailContainer = HighlightTextContainerThing(text: "Forgot Your Password?",
                                                      highlightText: "Forgot Your Password?") { vc in
                                                        print("HELLO PASSWORD!!")
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDefaults()
    }

    // MARK: Private

    private func setupDefaults() {
        titleLabel.textColor = .white
        titleLabel.text = self.title
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.text = "Login to Continue"

        subtitleTextView.highlightContainerThing = subtitleContainer
        subtitleTextView.textColor = .white
        subtitleTextView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        subtitleTextView.textAlignment = .center
        subtitleTextView.delegate = self

        detailTextView.highlightContainerThing = detailContainer
        detailTextView.textColor = .white
        detailTextView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        detailTextView.textAlignment = .center
        detailTextView.delegate = self

        credentialsStackView.alignment = .fill
        credentialsStackView.distribution = .fillEqually
        credentialsStackView.axis = .vertical

        var usernameField: LabeledTextField {
            let field = LabeledTextField()

            field.label.text = NSLocalizedString("Identification Number", comment: "")
            field.label.textColor = .white

            let textField = field.textField
            textField.accessibilityLabel = NSLocalizedString("Username Field", comment: "Accessibility")
            textField.returnKeyType = .next
            //            textField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
            //            textField.addObserver(self, forKeyPath: #keyPath(UITextField.text), context: &kvoContext)
            textField.autocapitalizationType = .none
            textField.delegate = self
            textField.textColor = .white
            textField.autocorrectionType = .no
            //            self.isUsernameFieldLoaded = true

            return field
        }

        var passwordField: LabeledTextField {
            let field = LabeledTextField()

            field.label.textColor = .white
            field.label.text = NSLocalizedString("Password", comment: "")

            let textField = field.textField
            textField.accessibilityLabel = NSLocalizedString("Password Field", comment: "Accessibility")
            textField.isSecureTextEntry = true
            textField.delegate = self
            textField.returnKeyType = .done
            textField.clearsOnBeginEditing = true
            textField.textColor = .white
            //            textField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
            //            textField.addObserver(self, forKeyPath: #keyPath(UITextField.text), context: &kvoContext)
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            //            self.isPasswordFieldLoaded = true

            return field
        }

        credentialsStackView.addArrangedSubview(usernameField)
        credentialsStackView.addArrangedSubview(passwordField)

        let buttonBackground = UIImage.resizableRoundedImage(cornerRadius: 24, borderWidth: 0.0, borderColor: nil, fillColor: .white)
        loginButton.titleLabel?.font = .systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
        loginButton.setBackgroundImage(buttonBackground.withRenderingMode(.alwaysTemplate), for: .normal)
        loginButton.setTitle("Login Now", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .disabled)
        loginButton.adjustsImageWhenDisabled = true
//        loginButton.addTarget(self, action: #selector(loginButtonTriggered), for: .primaryActionTriggered)
//        loginButton.addTarget(self, action: #selector(loginButtonTouchDown), for: .touchDown)
    }

    private func setupViews() {
        let views = [
            titleLabel,
            subtitleTextView,
            credentialsStackView,
            biometricButton,
            loginButton,
            detailTextView
        ]

        views.forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subView)
        }

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[tl]-[stv]-13-[csv]-24-[bb]-32-[lb(48)]-24-[dtv]->=0-|",
                                                         options: [],
                                                         metrics: nil,
                                                         views: ["tl": titleLabel,
                                                                 "stv": subtitleTextView,
                                                                 "csv": credentialsStackView,
                                                                 "bb": biometricButton,
                                                                 "lb": loginButton,
                                                                 "dtv": detailTextView])

        constraints += views.map{$0.leadingAnchor.constraint(equalTo: view.leadingAnchor)}
        constraints += views.map{$0.trailingAnchor.constraint(equalTo: view.trailingAnchor)}

        NSLayoutConstraint.activate(constraints)
    }
}

extension FancyLoginViewController: UITextViewDelegate, UITextFieldDelegate {

    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("INTERACTED WITH URL!! \(URL)")

        if textView == self.subtitleTextView {
            subtitleContainer?.action?(self)
        } else if textView == self.detailTextView {
            detailContainer?.action?(self)
        }
        return false
    }

    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("INTERACTED WITH URL!! \(URL)")

        if textView == self.subtitleTextView {
            subtitleContainer?.action?(self)
        } else if textView == self.detailTextView {
            detailContainer?.action?(self)
        }
        return false
    }
}

public struct HighlightTextContainerThing {
    var text: String
    var highlightText: String
    var action: ((UIViewController)->())?
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
