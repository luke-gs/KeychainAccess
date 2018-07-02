//
//  LoginViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import LocalAuthentication
import Lottie

fileprivate var kvoContext = 1

/// The default login view controller used to populate the contentVC of
/// the `LoginContainerViewController`
final public class LoginViewController: UIViewController {

    // MARK: Start public interfaces

    /// The type of login mode to use
    public let loginMode: LoginMode

    /// The primary title label. Customise to your hearts content.
    public let titleLabel: UILabel = UILabel()

    /// The login button. Customise to your hearts content.
    public let loginButton: UIButton = UIButton()

    /// The subtitle text view. Customise to your hearts content.
    /// Make sure to provide a `HighlightTextModel` to specify the text to highlight and the action
    /// to perform when tapped.
    public let subtitleTextView: HighlightingTextView = HighlightingTextView()

    /// The detail text view. Customise to your hearts content.
    /// Make sure to provide a `HighlightTextModel` to specify the text to highlight and the action
    /// to perform when tapped.
    public let detailTextView: HighlightingTextView = HighlightingTextView()

    /// An array of credentials to use
    public var credentials: [LoginCredential]? {
        didSet {
            credentialsStackView.arrangedSubviews.forEach{$0.removeFromSuperview()}
            credentials?.forEach { credential in
                credentialsStackView.addArrangedSubview(credential.inputField)
                credential.inputField.textField.text = credential.value
            }
            setupCredentialActions()
        }
    }

    /// Whether to allow biometrics
    ///
    /// Defaults to `true`
    public var usesBiometrics: Bool = true

    /// Inititalise the view controller with a login mode
    ///
    /// - Parameter mode: the login mode to use
    public init(mode: LoginMode) {
        self.loginMode = mode
        super.init(nibName: nil, bundle: nil)
    }

    /// Set the loading state of the view controller
    ///
    /// - Parameters:
    ///   - loading: true if loading is required
    ///   - animated: true if animation is required
    public func setLoading(_ loading: Bool, animated: Bool) {
        if loading == isLoading { return }
        self.isLoading = loading
        if animated {
            UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }

    /// Reset all the credential fields
    public func resetFields() {
        credentials?.forEach{$0.inputField.textField.text = nil}
    }

    // MARK: End public interfaces

    private lazy var insetManager: ScrollViewInsetManager = ScrollViewInsetManager(scrollView: scrollView)
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    private lazy var authenticationContext = LAContext()
    private(set) var credentialsStackView: UIStackView = UIStackView()
    private(set) lazy var biometricButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)

        var imageKey: AssetManager.ImageKey = .touchId
        var buttonText = " or use Touch ID"
        // Apple lies, it's not @available(iOS 11.0, *), it's later.
        // Crash on iOS 11.0
        if #available(iOS 11.0.1, *) {
            if authenticationContext.biometryType == .faceID {
                imageKey = .faceId
                buttonText = " or use Face ID"
            }
        }

        button.setImage(AssetManager.shared.image(forKey: imageKey), for: .normal)
        button.setTitle(buttonText, for: .normal)
        button.tintColor = ColorPalette.shared.skyBlue

        button.clipsToBounds = true

        return button
        }()

    private lazy var loadingIndicator: LOTAnimationView? = {
        let spinner = MPOLSpinnerView(style: .regular)
        spinner.isHidden = true
        spinner.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.heightAnchor.constraint(equalToConstant: 48),
            spinner.widthAnchor.constraint(equalToConstant: 48),
            spinner.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor)
            ])

        return spinner
    }()

    private var isLoading: Bool = false {
        didSet {
            if isLoading == oldValue || isViewLoaded == false { return }

            if isLoading {
                loadingIndicator?.isHidden = false
                loadingIndicator?.play()
                loginButton.isHidden = true
                view.endEditing(true)
                view.isUserInteractionEnabled = false
            } else {
                loadingIndicator?.isHidden = true
                loadingIndicator?.pause()
                loginButton.isHidden = false
                view.isUserInteractionEnabled = true
            }
        }
    }

    private lazy var biometricHeightConstraint: NSLayoutConstraint = {
        return biometricButton.heightAnchor.constraint(equalToConstant: 0).withPriority(.required)
    }()

    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupStackView()
        setupActions()

        insetManager.standardContentInset    = .zero
        insetManager.standardIndicatorInset  = .zero

        if usesBiometrics == false {
            biometricButton.isHidden = true
            biometricHeightConstraint.isActive = true
        }

        scrollView.showsVerticalScrollIndicator = false
    }

    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

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
            contentView.addSubview(subView)
        }

        var constraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ]

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[tl]-[stv]-13-[csv]-24-[bb]-32-[lb(48)]-24-[dtv]|",
                                                         options: [.alignAllLeading, .alignAllTrailing,],
                                                         metrics: nil,
                                                         views: ["tl": titleLabel,
                                                                 "stv": subtitleTextView,
                                                                 "csv": credentialsStackView,
                                                                 "bb": biometricButton,
                                                                 "lb": loginButton,
                                                                 "dtv": detailTextView])

        constraints += [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupStackView() {
        credentialsStackView.alignment = .fill
        credentialsStackView.distribution = .fillEqually
        credentialsStackView.axis = .vertical
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTriggered), for: .primaryActionTriggered)
        loginButton.addTarget(self, action: #selector(loginButtonTouchDown), for: .touchDown)
        biometricButton.addTarget(self, action: #selector(biometricButtonTriggered), for: .primaryActionTriggered)
        biometricButton.addTarget(self, action: #selector(biometricButtonTouchDown), for: .touchDown)
    }

    private func setupCredentialActions() {
        credentials?.forEach { credential in
            credential.inputField.textField.delegate = self
            credential.inputField.textField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
            credential.inputField.textField.addObserver(self, forKeyPath: #keyPath(UITextField.text), context: &kvoContext)
        }
    }

    private func updateLoginButtonState() {
        switch loginMode {
        case .credentials:
            loginButton.isEnabled = areCredentialsValid()
        case .credentialsWithBiometric:
            loginButton.isEnabled = areCredentialsValid()
        case .externalAuth:
            loginButton.isEnabled = true
        }
    }

    private func authenticateWithBiometric(title: String) {
        guard case .credentialsWithBiometric(let delegate) = loginMode else { return }

        authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: title, reply: { [weak self] (success, error) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if success {
                    delegate?.loginViewControllerDidAuthenticateWithBiometric(self, context: self.authenticationContext)
                }
            }
        })
    }

    private func areCredentialsValid() -> Bool {
        guard let credentials = credentials else { return false }
        return credentials.reduce(true, { (result, cred) -> Bool in
            let isValid = !cred.isRequired ? true : cred.isValid
            return result && isValid
        })
    }

    @objc private func biometricButtonTriggered() {
        guard let credential = credentials?.first?.value else { return }
        authenticateWithBiometric(title: "Login to account \"\(credential)\"")
    }

    @objc private func biometricButtonTouchDown() {
        HapticHelper.shared.prepare(.medium)
    }

    @objc private func loginButtonTouchDown() {
        HapticHelper.shared.prepare(.medium)
    }

    @objc private func loginButtonTriggered() {
        HapticHelper.shared.trigger(.medium)

        switch loginMode {
        case .credentials(let delegate):
            guard let credentials = credentials else { return }
            guard areCredentialsValid() else { return }
            view.endEditing(true)
            delegate?.loginViewController(self, didFinishWithCredentials: credentials)
        case .credentialsWithBiometric(let delegate):
            guard let credentials = credentials else { return }
            guard areCredentialsValid() else { return }
            view.endEditing(true)
            delegate?.loginViewController(self, didFinishWithCredentials: credentials)
        case .externalAuth(let delegate):
            delegate?.loginViewControllerDidCommenceExternalAuth(self)
        }
    }

    @objc private func textFieldTextDidChange(_ textField: UITextField) {
        let credential = credentials?.first(where: {$0.inputField.textField == textField})
        credential?.value = textField.text
        updateLoginButtonState()
    }
}

extension LoginViewController: UITextViewDelegate, UITextFieldDelegate {

    // MARK: - UITextViewDelegate

    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let textView = textView as? HighlightingTextView {
            textView.highlightTextModel?.action?(self)
        }
        return false
    }

    // MARK: - UITextFieldDelegate

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let validCreds = credentials else { return false }
        guard let currentCredentialFieldIndex = validCreds.index(where: {$0.inputField.textField == textField}) else { return false }

        if currentCredentialFieldIndex == (validCreds.count - 1) {
            textField.resignFirstResponder()
            if loginButton.isEnabled {
                loginButtonTriggered()
            }
        } else {
            let nextCredentialField = validCreds[currentCredentialFieldIndex + 1]
            nextCredentialField.inputField.textField.becomeFirstResponder()
        }
        return false
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isSecureTextEntry {
            let text = textField.text as NSString?
            let newText = text?.replacingCharacters(in: range, with: string)
            textField.text = newText
            return false
        }
        return true
    }
}

// MARK: KVO

extension LoginViewController {

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if keyPath == #keyPath(UITextField.text), let field = object as? UITextField {
                textFieldTextDidChange(field)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
