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

    /// The container primarily for title view. Add custom content view as subview.
    public let titleView: UIView = UIView()

    /// The login button.
    public let loginButton: UIButton = UIButton()

    /// The detail text view.
    /// Make sure to provide a `HighlightTextModel` to specify the text to highlight and the action
    /// to perform when tapped.
    public let detailTextView: HighlightingTextView = HighlightingTextView()

    /// An array of credentials to use
    public var credentials: [LoginCredential]? {
        didSet {
            // Check if there are old credentials
            // Ensure that the observations (added by `setupCredentialActions`) are removed.
            removeObservers(from: oldValue)

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
    private lazy var loginDelegate: LoginViewControllerDelegate? = {
        let loginDelegate: LoginViewControllerDelegate?
        switch loginMode {
        case .credentials(let delegate):
            loginDelegate = delegate
        case .credentialsWithBiometric(let delegate):
            loginDelegate = delegate
        case .externalAuth(delegate: let delegate):
            loginDelegate = delegate
        }
        return loginDelegate
    }()

    /// Inititalise the view controller with a login mode
    ///
    /// - Parameter mode: The login mode to use
    public init(mode: LoginMode) {
        self.loginMode = mode
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        removeObservers(from: credentials)
    }

    /// Set the loading state of the view controller
    ///
    /// - Parameters:
    ///   - loading: `true` if loading is required
    ///   - animated: `true` if animation is required
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
        var buttonText = NSLocalizedString("Use Touch ID", comment: "")
        // Apple lies, it's not @available(iOS 11.0, *), it's later.
        // Crash on iOS 11.0
        if #available(iOS 11.0.1, *) {
            // `canEvaluatePolicy` needs to be called first before `biometryType` is known.
            if authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && authenticationContext.biometryType == .faceID {
                imageKey = .faceId
                buttonText = NSLocalizedString("Use Face ID", comment: "")
            }
        }

        button.setImage(AssetManager.shared.image(forKey: imageKey), for: .normal)
        button.setTitle(buttonText, for: .normal)

        button.tintColor = ColorPalette.shared.brightBlue
        button.clipsToBounds = true

        // Gives spacing between Image and Text
        let spacing: CGFloat = 12
        let half = spacing * 0.5
        let insets = UIEdgeInsetsMake(0, spacing, 0, 0)
        button.titleEdgeInsets = insets

        // Ensure that the content is pad properly. titleEdgeInsets doesn't
        // affect intrinsicContentSize.
        let contentInsets = UIEdgeInsetsMake(0, half, 0, half)
        button.contentEdgeInsets = contentInsets

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

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loginDelegate?.loginViewControllerDidAppear(self)
    }
    private func setupViews() {
        contentView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let views = [
            titleView,
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
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),

            contentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).withPriority(.defaultLow),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ]

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[tv]-42-[csv]-20-[lb(48)]-20-[bb]-20-[dtv]|",
                                                         options: [.alignAllLeading, .alignAllTrailing,],
                                                         metrics: nil,
                                                         views: ["tv": titleView,
                                                                 "csv": credentialsStackView,
                                                                 "lb": loginButton,
                                                                 "bb": biometricButton,
                                                                 "dtv": detailTextView])

        constraints += [
            titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupStackView() {
        credentialsStackView.alignment = .fill
        credentialsStackView.distribution = .fillProportionally
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

    private func removeObservers(from credentials: [LoginCredential]?) {
        credentials?.forEach {
            $0.inputField.textField.removeObserver(self, forKeyPath: #keyPath(UITextField.text), context: &kvoContext)
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
