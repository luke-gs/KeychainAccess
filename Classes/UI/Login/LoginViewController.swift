//
//  LoginViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 9/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import Lottie
import LocalAuthentication

fileprivate var kvoContext = 1


open class LoginViewController: UIViewController, UITextFieldDelegate {

    /// The image to present behind the login screen.
    open var backgroundImage: UIImage? {
        didSet {
            backgroundView?.image = backgroundImage
        }
    }

    // Branding image that sits in top left corner
    open var topLeftImage: UIImage? {
        didSet {
            topLeftImageView = UIImageView(image: topLeftImage)
        }
    }

    // Branding image that sits in bottom left corner
    open var bottomLeftImage: UIImage? {
        didSet {
            leftAccessoryView = UIImageView(image: bottomLeftImage)
        }
    }
    
    /// The header view to show above the login credentials section.
    ///
    /// This view is generally used to present branding for the MPOL product,
    /// and will be positioned by AutoLayout.
    open var headerView: UIView? {
        didSet {
            if headerView == oldValue { return }
            
            headerView?.alpha = isHeaderAndAccessoryViewHidden ? 0.0 : 1.0
            
            guard let contentStackView = self.contentStackView else { return }
            
            if oldValue?.superview == contentStackView {
                oldValue?.removeFromSuperview()
            }
            
            if let newHeader = headerView {
                contentStackView.insertArrangedSubview(newHeader, at: 0)
            }
        }
    }
    
    open var leftAccessoryView: UIView? {
        didSet {
            if oldValue == leftAccessoryView { return }
            
            // Remove previous leftView from superview
            if let oldValue = oldValue {
                oldValue.removeFromSuperview()
            }
            
            if let leftView = leftAccessoryView, let accessoryView = accessoryView {
                // Setup leftView for autolayout
                leftView.translatesAutoresizingMaskIntoConstraints = false
                accessoryView.addSubview(leftView)
                
                // Add constraints to pin to left in accessoryView
                NSLayoutConstraint.activate([
                    leftView.leadingAnchor.constraint(equalTo: accessoryView.leadingAnchor),
                    leftView.bottomAnchor.constraint(equalTo: accessoryView.bottomAnchor),
                    leftView.topAnchor.constraint(greaterThanOrEqualTo: accessoryView.topAnchor),
                    leftView.trailingAnchor.constraint(lessThanOrEqualTo: accessoryView.centerXAnchor, constant: -5.0)
                    ])
            }
        }
    }
    
    open var rightAccessoryView: UIView? {
        didSet {
            if oldValue == rightAccessoryView { return }
            
            // Remove previous rightView from superview
            if let oldValue = oldValue {
                oldValue.removeFromSuperview()
            }
            
            if let rightView = rightAccessoryView, let accessoryView = accessoryView {
                // Setup rightView for autolayout
                rightView.translatesAutoresizingMaskIntoConstraints = false
                accessoryView.addSubview(rightView)
                
                // Add constraints to pin to right in accessoryView
                NSLayoutConstraint.activate([
                    rightView.leadingAnchor.constraint(greaterThanOrEqualTo: accessoryView.centerXAnchor, constant: 5.0),
                    rightView.bottomAnchor.constraint(equalTo: accessoryView.bottomAnchor),
                    rightView.topAnchor.constraint(greaterThanOrEqualTo: accessoryView.topAnchor),
                    rightView.trailingAnchor.constraint(equalTo: accessoryView.trailingAnchor)
                    ])
            }
        }
    }

    open private(set) lazy var credentialsView: UIView? = nil

    open private(set) lazy var usernameField: LabeledTextField = {
        let field = LabeledTextField()
        
        field.label.text = NSLocalizedString("ID Number", comment: "")
        field.label.textColor = .white

        let textField = field.textField
        textField.accessibilityLabel = NSLocalizedString("Username Field", comment: "Accessibility")
        textField.returnKeyType = .next
        textField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
        textField.addObserver(self, forKeyPath: #keyPath(UITextField.text), context: &kvoContext)
        textField.autocapitalizationType = .none
        textField.delegate = self
        textField.textColor = .white
        textField.autocorrectionType = .no
        self.isUsernameFieldLoaded = true

        return field
    }()

    open private(set) lazy var passwordField: LabeledTextField = {
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
        textField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
        textField.addObserver(self, forKeyPath: #keyPath(UITextField.text), context: &kvoContext)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        self.isPasswordFieldLoaded = true

        return field
    }()

    open private(set) lazy var forgotPasswordButton: UIButton = { [unowned self] in
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Forgot Your Password?", for: .normal)
        button.setTitleColor(UIColor.brightBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)
        button.addTarget(self, action: #selector(forgotPasswordButtonTriggered), for: .primaryActionTriggered)
        if case LoginMode.externalAuth = loginMode {
            button.isHidden = true
        }

        return button
        }()

    open private(set) lazy var biometricButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)

        var imageKey: AssetManager.ImageKey = .touchId
        // Apple lies, it's not @available(iOS 11.0, *), it's later.
        // Crash on iOS 11.0
        if #available(iOS 11.0.1, *) {
            if authenticationContext.biometryType == .faceID {
                imageKey = .faceId
            }
        }

        button.setImage(AssetManager.shared.image(forKey: imageKey), for: .normal)
        button.addTarget(self, action: #selector(biometricButtonTriggered), for: .primaryActionTriggered)
        button.addTarget(self, action: #selector(biometricButtonTouchDown), for: .touchDown)
        button.tintColor = .white
        return button
    }()

    open private(set) lazy var changeUserButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .medium)
        button.setTitle("Not you? Change username.", for: .normal)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.64), for: .normal)

        button.addTarget(self, action: #selector(changeUserButtonTriggered), for: .primaryActionTriggered)
        button.addTarget(self, action: #selector(changeUserButtonTouchDown), for: .touchDown)
        return button
    }()

    /// The login button.
    ///
    /// To default background image for this button is a template image and will adapt to the standard tintColor.
    open private(set) lazy var loginButton: UIButton = { [unowned self] in
        let buttonBackground = UIImage.resizableRoundedImage(cornerRadius: 22.0, borderWidth: 15.0, borderColor: nil, fillColor: .white)
        
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
        button.setBackgroundImage(buttonBackground.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setTitle("Login Now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .disabled)
        button.adjustsImageWhenDisabled = true
        button.addTarget(self, action: #selector(loginButtonTriggered), for: .primaryActionTriggered)
        button.addTarget(self, action: #selector(loginButtonTouchDown), for: .touchDown)

        self.isLoginButtonLoaded = true
        return button
    }()
    
    
    /// The terms and conditions string to present at the bottom of login window.
    open private(set) lazy var termsAndConditionsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "By continuing you are agreeing to the Terms and Conditions of Use previously presented to you."
        label.font = .systemFont(ofSize: 17.0)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    
    /// The version number
    open private(set) lazy var versionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 13.0, weight: UIFont.Weight.bold)
        label.textColor = UIColor(white: 1.0, alpha: 0.64)
        
        if let info = Bundle.main.infoDictionary {
            let version = info["CFBundleShortVersionString"] as? String ?? ""
            let build   = info["CFBundleVersion"] as? String ?? ""
            
            label.text = "Version \(version) #\(build)"
        }
        
        return label
    }()
    
    /// The minimum length of the username before the login button is enabled.
    ///
    /// The default is `0`.
    open var minimumUsernameLength: Int = 0 {
        didSet {
            if minimumUsernameLength != oldValue {
                updateLoginButtonState()
            }
        }
    }
    
    
    /// The minimum length of the password before the login button is enabled.
    ///
    /// The default is `0`.
    open var minimumPasswordLength: Int = 0 {
        didSet {
            if minimumPasswordLength != oldValue {
                updateLoginButtonState()
            }
        }
    }
    
    
    
    /// A boolean value indicating whether the content is currently loading.
    ///
    /// When loading, the login fields are hidden and an activity indicator is
    /// displayed. Setting this property directly performs the update without
    /// an animation.
    open var isLoading: Bool = false {
        didSet {
            if isLoading == oldValue || isViewLoaded == false { return }
            
            if isLoading {
                loadingIndicator?.isHidden = false
                loadingIndicator?.play()
                loginButton.isHidden = true
                
                scrollView?.endEditing(true)
                
                view.isUserInteractionEnabled = false
            } else {
                loadingIndicator?.isHidden = true
                loadingIndicator?.pause()
                loginButton.isHidden = false
                view.isUserInteractionEnabled = true
            }
        }
    }
    
    
    /// Updates the view controller's `isLoading` state with an optional animation.
    ///
    /// - Parameters:
    ///   - loading:  The new loading state
    ///   - animated: A boolean value indicating whether the update should be animated.
    open func setLoading(_ loading: Bool, animated: Bool) {
        if loading == isLoading { return }
        
        self.isLoading = loading
        
        if animated, let scrollView = self.scrollView {
            UIView.transition(with: scrollView, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    /// The preferred status bar style for the view controller.
    ///
    /// The default is `.lightContent`.
    /// `LoginViewController` extends UIViewController to allow setting this property.
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return _preferredStatusBarStyle
        }
        set {
            if newValue == _preferredStatusBarStyle { return }
            
            _preferredStatusBarStyle = newValue
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    /// Specifies whether the view controller prefers the status bar to be hidden or shown.
    ///
    /// The default is `false`.
    /// `LoginViewController` extends UIViewController to allow setting this property.
    open override var prefersStatusBarHidden: Bool {
        get {
            return _prefersStatusBarHidden
        }
        set {
            if newValue == _prefersStatusBarHidden { return }
            
            _prefersStatusBarHidden = newValue
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    /// Specifies whether the credentials view is added to the view hierarchy.
    public var loginMode: LoginMode {
        didSet {
            guard isViewLoaded else { return }
            updateLoginMode()
        }
    }
    
    // MARK: - Private properties
    
    private var _preferredStatusBarStyle: UIStatusBarStyle = .lightContent
    
    private var _prefersStatusBarHidden: Bool = false

    private var backgroundView: UIImageView?

    private var topLeftImageView: UIImageView?

    private var bottomLeftImageView: UIImageView?
    
    private var scrollView: UIScrollView?
    
    private var contentView: UIView?
    
    private var contentStackView: UIStackView?
    
    private var loginStackView: UIStackView?
    
    private var accessoryView: UIView?
    
    private lazy var loadingIndicator: LOTAnimationView? = {
        let spinner = MPOLSpinnerView(style: .regular)
        spinner.isHidden = true
        
        let heightConstraint = spinner.heightAnchor.constraint(equalToConstant: 48.0)
        heightConstraint.priority = UILayoutPriority.defaultHigh
        
        NSLayoutConstraint.activate([
            heightConstraint,
            spinner.widthAnchor.constraint(equalToConstant: 48.0)
        ])
        
        self.loginStackView?.insertArrangedSubview(spinner, at: 0)
        return spinner
    }()
    
    private var preferredLayoutGuideBottomConstraint: NSLayoutConstraint?
    
    private var showingHeaderConstraint: NSLayoutConstraint?
    
    private var showingAccessoryConstraint: NSLayoutConstraint?
    
    private var separatorHeightConstraint: NSLayoutConstraint?
    
    private var forgotPasswordSeparation: NSLayoutConstraint?
    
    private var keyboardInset: CGFloat = 0.0 {
        didSet {
            if keyboardInset ==~ oldValue { return }
            
            viewIfLoaded?.setNeedsLayout()
        }
    }
    
    private var isUsernameFieldLoaded: Bool = false
    
    private var isPasswordFieldLoaded: Bool = false
    
    private var isLoginButtonLoaded: Bool = false
    
    private var isHeaderAndAccessoryViewHidden: Bool = false {
        didSet {
            if isHeaderAndAccessoryViewHidden == oldValue { return }
            
            headerView?.alpha = isHeaderAndAccessoryViewHidden ? 0.0 : 1.0
            accessoryView?.alpha = isHeaderAndAccessoryViewHidden ? 0.0 : 1.0
            showingHeaderConstraint?.isActive = isHeaderAndAccessoryViewHidden == false
            showingAccessoryConstraint?.isActive = isHeaderAndAccessoryViewHidden == false
        }
    }
    
    private lazy var authenticationContext = LAContext()
    
    // MARK: - Initializers

    public init(mode: LoginMode) {
        loginMode = mode
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidHide(_:)),  name: .UIKeyboardDidHide,  object: nil)

    }
    
    public required convenience init(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    deinit {
        if isUsernameFieldLoaded {
            usernameField.textField.removeObserver(self, forKeyPath:#keyPath(UITextField.text), context: &kvoContext)
        }
        if isPasswordFieldLoaded {
            passwordField.textField.removeObserver(self, forKeyPath:#keyPath(UITextField.text), context: &kvoContext)
        }
    }
    
    // MARK: - View lifecycle
    
    open override func loadView() {
        let backgroundView = UIImageView(image: backgroundImage)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.isUserInteractionEnabled = true
        
        let scrollView = UIScrollView(frame: backgroundView.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let credentialsView: UIView = createCredentialsView()

        let versionLabel = self.versionLabel
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(versionLabel)
        
        let loginStackView = UIStackView(arrangedSubviews: [loginButton, changeUserButton, termsAndConditionsLabel])
        loginStackView.axis      = .vertical
        loginStackView.alignment = .fill
        loginStackView.spacing   = 20.0
        
        let contentViews = [headerView, credentialsView, loginStackView].removeNils()
        let contentStackView = UIStackView(arrangedSubviews: contentViews)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing   = 43.0
        contentStackView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        contentView.addSubview(contentStackView)
        
        let accessoryView = createAccessoryView()
        contentView.addSubview(accessoryView)
        
        self.backgroundView    = backgroundView
        self.scrollView        = scrollView
        self.contentView       = contentView
        self.contentStackView  = contentStackView
        self.accessoryView     = accessoryView
        self.credentialsView   = credentialsView
        self.loginStackView    = loginStackView
        
        self.view = backgroundView
        self.rightAccessoryView = versionLabel
        
        let preferredLayoutGuideBottomConstraint = contentView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor, constant: -20.0).withPriority(.defaultHigh - 1)
        
        let showingHeaderConstraint = contentStackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 20.0)
        let showingAccessoryConstraint = accessoryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24.0)

        var constraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            preferredLayoutGuideBottomConstraint,

            showingHeaderConstraint,
            contentStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).withPriority(.defaultHigh - 2),
            contentStackView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -20.0),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20.0),

            accessoryView.topAnchor.constraint(greaterThanOrEqualTo: contentStackView.bottomAnchor, constant: 15.0),
            accessoryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0),
            accessoryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0),
            showingAccessoryConstraint,

            termsAndConditionsLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 416),

            loginButton.widthAnchor.constraint(lessThanOrEqualToConstant: 384.0),
            loginButton.heightAnchor.constraint(equalToConstant: 64.0).withPriority(UILayoutPriority.defaultHigh),

            changeUserButton.widthAnchor.constraint(equalTo: loginButton.widthAnchor),
            changeUserButton.heightAnchor.constraint(equalToConstant: 20.0),

            loginStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.leadingAnchor),
            loginStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.readableContentGuide.trailingAnchor)
        ]

        if let topLeftImageView = self.topLeftImageView {
            topLeftImageView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(topLeftImageView)

            constraints += [
                NSLayoutConstraint(item: topLeftImageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
                                   toItem: topLeftImageView,attribute: NSLayoutAttribute.width,
                                   multiplier: topLeftImageView.frame.size.height / topLeftImageView.frame.size.width).withPriority(.required),
                topLeftImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.safeAreaOrFallbackLeadingAnchor, constant: 24).withPriority(.almostRequired),
                topLeftImageView.topAnchor.constraint(equalTo: contentView.safeAreaOrFallbackTopAnchor, constant: 24).withPriority(.almostRequired),
                topLeftImageView.bottomAnchor.constraint(lessThanOrEqualTo: headerView!.topAnchor, constant: -40).withPriority(.required),
                topLeftImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaOrFallbackTrailingAnchor, constant: contentView.frame.width * 0.666).withPriority(.required)
            ]
        }

        if let credentialsView = self.credentialsView {
            constraints += [
                credentialsView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 20.0),
                credentialsView.widthAnchor.constraint(lessThanOrEqualToConstant: 416.0),
                usernameField.widthAnchor.constraint(equalTo: credentialsView.widthAnchor),
                usernameField.leadingAnchor.constraint(equalTo: credentialsView.leadingAnchor)
            ]
        }

        NSLayoutConstraint.activate(constraints)
        
        self.preferredLayoutGuideBottomConstraint = preferredLayoutGuideBottomConstraint
        self.showingHeaderConstraint              = showingHeaderConstraint
        self.showingAccessoryConstraint           = showingAccessoryConstraint
    }
    
    private func createCredentialsView() -> UIView {
        let credentialsView = UIView(frame: .zero)
        
        // Creating views
        let forgotPasswordButton = self.forgotPasswordButton

        credentialsView.translatesAutoresizingMaskIntoConstraints = false
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false

        credentialsView.addSubview(usernameField)
        credentialsView.addSubview(passwordField)
        credentialsView.addSubview(forgotPasswordButton)
        
        // Creating constraints
        let forgotPasswordSeparation = forgotPasswordButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: forgotPasswordButton.isHidden ? 0.0 : 14.0)
        
        let constraints = [
            usernameField.topAnchor.constraint(equalTo: credentialsView.topAnchor),
            usernameField.leadingAnchor.constraint(equalTo: credentialsView.leadingAnchor),
            usernameField.trailingAnchor.constraint(equalTo: credentialsView.trailingAnchor),

            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor),
            passwordField.leadingAnchor.constraint(equalTo: credentialsView.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: credentialsView.trailingAnchor),

            forgotPasswordButton.topAnchor.constraint(greaterThanOrEqualTo: passwordField.bottomAnchor),
            forgotPasswordButton.leadingAnchor.constraint(equalTo: credentialsView.leadingAnchor),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: credentialsView.trailingAnchor),
            forgotPasswordButton.bottomAnchor.constraint(equalTo: credentialsView.bottomAnchor),
            forgotPasswordSeparation
        ]
        
        NSLayoutConstraint.activate(constraints)
        self.forgotPasswordSeparation  = forgotPasswordSeparation
        
        return credentialsView
    }
    
    private func createAccessoryView() -> UIView {
        let accessoryView = UIView()
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        
        var constraints: [NSLayoutConstraint] = []
        
        if let leftView = leftAccessoryView {
            leftView.translatesAutoresizingMaskIntoConstraints = false
            accessoryView.addSubview(leftView)
            
            constraints += [
                leftView.leadingAnchor.constraint(equalTo: accessoryView.leadingAnchor),
                leftView.bottomAnchor.constraint(equalTo: accessoryView.bottomAnchor),
                leftView.topAnchor.constraint(greaterThanOrEqualTo: accessoryView.topAnchor),
                leftView.trailingAnchor.constraint(lessThanOrEqualTo: accessoryView.centerXAnchor, constant: -5.0)
            ]
        }
        
        if let rightView = rightAccessoryView {
            rightView.translatesAutoresizingMaskIntoConstraints = false
            accessoryView.addSubview(rightView)
            
            constraints += [
                rightView.leadingAnchor.constraint(greaterThanOrEqualTo: accessoryView.centerXAnchor, constant: 5.0),
                rightView.bottomAnchor.constraint(equalTo: accessoryView.bottomAnchor),
                rightView.topAnchor.constraint(greaterThanOrEqualTo: accessoryView.topAnchor),
                rightView.trailingAnchor.constraint(equalTo: accessoryView.trailingAnchor)
            ]
        }
        
        NSLayoutConstraint.activate(constraints)
        
        return accessoryView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        updateLoginMode()
        updateLoginButtonState()
    }
    
    open override func viewWillLayoutSubviews() {
        let topLayoutInset    = topLayoutGuide.length
        let bottomLayoutInset = max(bottomLayoutGuide.length, statusTabBarInset, keyboardInset)
        
        preferredLayoutGuideBottomConstraint?.constant = (bottomLayoutInset + topLayoutInset) * -1.0
        
        let insets = UIEdgeInsets(top: topLayoutInset, left: 0.0, bottom: bottomLayoutInset, right: 0.0)
        scrollView?.contentInset = insets
        scrollView?.scrollIndicatorInsets = insets
        
        super.viewWillLayoutSubviews()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topLayoutInset    = topLayoutGuide.length
        let bottomLayoutInset = max(bottomLayoutGuide.length, statusTabBarInset, keyboardInset)
        
        isHeaderAndAccessoryViewHidden = keyboardInset >~ 0.0 && (view.frame.height - topLayoutInset - bottomLayoutInset < (contentStackView?.frame.height ?? 0.0))
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        separatorHeightConstraint?.constant = 1.0 / traitCollection.currentDisplayScale
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch loginMode {
        case .usernamePassword(let delegate):
            delegate?.loginViewControllerDidAppear(self)
        case .externalAuth(let delegate):
            delegate?.loginViewControllerDidAppear(self)
        case .usernamePasswordWithBiometric(let delegate):
            delegate?.loginViewControllerDidAppear(self)
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Action
    
    open func resetFields() {
        usernameField.textField.text = nil
        passwordField.textField.text = nil
    }
    
    
    // MARK: - Text field delegate
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isUsernameFieldLoaded && textField == usernameField.textField {
            passwordField.textField.becomeFirstResponder()
        } else if isPasswordFieldLoaded && textField == passwordField.textField {
            passwordField.textField.resignFirstResponder()
            
            if loginButton.isEnabled {
                loginButtonTriggered()
            }
        }
        return false
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == passwordField.textField {
            let text = textField.text as NSString?
            let newText = text?.replacingCharacters(in: range, with: string)
            textField.text = newText
            return false
        }
        return true
    }
    
    // MARK: - Overrides
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if keyPath == #keyPath(UITextField.text), let field = object as? UITextField {
                textFieldTextDidChange(field)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Keyboard notifications
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(resetKeyboardInset), object: nil)
        
        guard let animationDetails = notification.keyboardAnimationDetails() else { return }
        
        let rectInViewCoordinates = view.convert(animationDetails.endFrame, from: nil)
        let inset = max(0.0, view.bounds.maxY - rectInViewCoordinates.minY)
        
        setKeyboardInset(inset, animationDuration: animationDetails.duration, curve: animationDetails.curve)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if let animationDetails = notification.keyboardAnimationDetails(), animationDetails.duration >~ 0.0 {
            setKeyboardInset(0.0, animationDuration: animationDetails.duration, curve: animationDetails.curve)
        }
    }
    
    @objc private func keyboardDidHide(_ notification: Notification) {
        if let animationDetails = notification.keyboardAnimationDetails(), animationDetails.duration >~ 0.0 {
            // we already animated this.
            return
        }
        perform(#selector(resetKeyboardInset), with: nil, afterDelay: 0.1, inModes: [.commonModes])
    }
    
    
    // MARK: - Private methods
    
    private func setKeyboardInset(_ inset: CGFloat, animationDuration: TimeInterval, curve: UIViewAnimationOptions) {
        if keyboardInset == inset { return }
        keyboardInset = inset
        
        if let view = viewIfLoaded {
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [curve, .beginFromCurrentState], animations: {
                view.setNeedsLayout()
                view.layoutIfNeeded()
            })
        }
    }
    
    @objc private func resetKeyboardInset() {
        setKeyboardInset(0.0, animationDuration: 0.0, curve: .curveLinear)
    }

    @objc private func biometricButtonTriggered() {
        authenticateWithBiometric(title: "Login to account \"\(usernameField.textField.text!)\"")
    }

    @objc private func biometricButtonTouchDown() {
        HapticHelper.shared.prepare(.medium)
    }

    @objc private func changeUserButtonTriggered() {
        HapticHelper.shared.trigger(.medium)

        guard case .usernamePasswordWithBiometric(let delegate) = loginMode else { return }
        loginMode = .usernamePassword(delegate: delegate)
    }

    @objc private func changeUserButtonTouchDown() {
        HapticHelper.shared.prepare(.medium)
    }

    @objc private func loginButtonTouchDown() {
        HapticHelper.shared.prepare(.medium)
    }

    @objc private func loginButtonTriggered() {
        HapticHelper.shared.trigger(.medium)

        switch loginMode {
        case .usernamePassword(let delegate):
            guard let username = usernameField.textField.text, let password = passwordField.textField.text else { return }
            view.endEditing(true)
            delegate?.loginViewController(self, didFinishWithUsername: username, password: password)
        case .usernamePasswordWithBiometric(let delegate):
            guard let username = usernameField.textField.text, let password = passwordField.textField.text else { return }
            view.endEditing(true)
            delegate?.loginViewController(self, didFinishWithUsername: username, password: password)
        case .externalAuth(let delegate):
            delegate?.loginViewControllerDidCommenceExternalAuth(self)
        }
    }
    
    @objc private func forgotPasswordButtonTriggered() {
        if case let LoginMode.usernamePassword(delegate: delegate) = loginMode {
            delegate?.loginViewController(self, didTapForgotPasswordButton: forgotPasswordButton)
        }
    }
    
    @objc private func textFieldTextDidChange(_ textField: UITextField) {
        if (isUsernameFieldLoaded && textField == usernameField.textField) || (isPasswordFieldLoaded && textField == passwordField.textField) {
            updateLoginButtonState()
        }
    }
    
    private func updateLoginButtonState() {
        if isLoginButtonLoaded == false { return }

        switch loginMode {
        case .usernamePassword(let delegate):
            let isUsernameValid: Bool = isUsernameFieldLoaded && usernameField.textField.text?.count ?? 0 >= minimumUsernameLength
            let isPasswordValid: Bool = isPasswordFieldLoaded && passwordField.textField.text?.count ?? 0 >= minimumPasswordLength

            loginButton.isEnabled = isUsernameValid && isPasswordValid
            forgotPasswordButton.isHidden = !(delegate?.wantsForgotPassword ?? true)
        case .usernamePasswordWithBiometric(let delegate):
            let isUsernameValid: Bool = isUsernameFieldLoaded && usernameField.textField.text?.count ?? 0 >= minimumUsernameLength
            let isPasswordValid: Bool = isPasswordFieldLoaded && passwordField.textField.text?.count ?? 0 >= minimumPasswordLength

            loginButton.isEnabled = isUsernameValid && isPasswordValid
            forgotPasswordButton.isHidden = !(delegate?.wantsForgotPassword ?? true)
        case .externalAuth:
            loginButton.isEnabled = true
        }
    }
    
    private func newTextField() -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.font                 = .systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
        textField.textColor            = .white
        textField.clearButtonMode      = .whileEditing
        textField.autocorrectionType   = .no
        return textField
    }

    private func updateLoginMode() {
        switch loginMode {
        case .usernamePassword(_):
            credentialsView?.isHidden = false
            usernameField.textField.isEnabled = true
            passwordField.textField.rightView = nil
            usernameField.textField.textColor = .white

            changeUserButton.isHidden = true
        case .usernamePasswordWithBiometric(_):
            credentialsView?.isHidden = false
            usernameField.textField.isEnabled = false
            usernameField.textField.textColor = .lightGray
            changeUserButton.isHidden = false

            if authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                biometricButton.sizeToFit()
                passwordField.textField.rightView = biometricButton
                passwordField.textField.rightViewMode = .unlessEditing
            }
        case .externalAuth(_):
            credentialsView?.isHidden = true
            usernameField.textField.isEnabled = true
            changeUserButton.isHidden = true
        }
    }

    // MARK: - Biometric authentication

    private func authenticateWithBiometric(title: String) {
        guard case .usernamePasswordWithBiometric(let delegate) = loginMode else { return }

        authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: title, reply: { [weak self] (success, error) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if success {
                    delegate?.loginViewControllerDidAuthenticateWithBiometric(self, context: self.authenticationContext)
                }
            }
        })
    }

}

// MARK: - Login Mode and Delegates

public enum LoginMode {
    case usernamePassword(delegate: UsernamePasswordDelegate?)
    case usernamePasswordWithBiometric(delegate: BiometricDelegate?)
    case externalAuth(delegate: ExternalAuthDelegate?)
}

public protocol LoginViewControllerDelegate {
    func loginViewControllerDidAppear(_ controller: LoginViewController)
}

public protocol UsernamePasswordDelegate: LoginViewControllerDelegate {

    var wantsForgotPassword: Bool { get }

    func loginViewController(_ controller: LoginViewController, didFinishWithUsername username: String, password: String)
    func loginViewController(_ controller: LoginViewController, didTapForgotPasswordButton button: UIButton)
    
}

public protocol BiometricDelegate: UsernamePasswordDelegate {
    func loginViewControllerDidAuthenticateWithBiometric(_ controller: LoginViewController, context: LAContext)
}

public extension UsernamePasswordDelegate {

    public var wantsForgotPassword: Bool {
        return true
    }

}

public protocol ExternalAuthDelegate: LoginViewControllerDelegate {
    func loginViewControllerDidCommenceExternalAuth(_ controller: LoginViewController)
}
