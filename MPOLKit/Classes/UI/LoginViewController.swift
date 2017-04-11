//
//  LoginViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 9/4/17.
//
//

import UIKit

fileprivate var kvoContext = 1

open class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    /// The login delegate.
    ///
    /// This object receives callback notifications when the login button is triggered.
    open weak var delegate: LoginViewControllerDelegate?
    
    
    /// The image to present behind the login screen.
    open var backgroundImage: UIImage? {
        didSet {
            backgroundView?.image = backgroundImage
        }
    }
    
    /// The header view to show above the login credentials section.
    ///
    /// This view is generally used to present branding for the MPOL product,
    /// and will be positioned by AutoLayout.
    open var headerView: UIView? {
        didSet {
            guard headerView != oldValue, let contentStackView = self.contentStackView else { return }
            
            if oldValue?.superview == contentStackView {
                oldValue?.removeFromSuperview()
            }
            
            if let newHeader = headerView {
                contentStackView.insertArrangedSubview(newHeader, at: 0)
            }
        }
    }
    
    
    open private(set) lazy var usernameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = NSLocalizedString("Username", comment: "")
        label.font = .systemFont(ofSize: 14.0, weight: UIFontWeightRegular)
        label.textColor = .white
        return label
    }()
    
    
    /// The username field.
    open private(set) lazy var usernameField: UITextField = { [unowned self] in
        let usernameField = self.newTextField(forPassword: false)
        usernameField.returnKeyType      = .next
        usernameField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
        usernameField.addObserver(self, forKeyPath: #keyPath(UITextField.text), context: &kvoContext)
        self.isUsernameFieldLoaded = true
        
        return usernameField
    }()
    
    
    open private(set) lazy var passwordLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = NSLocalizedString("Password", comment: "")
        label.font = .systemFont(ofSize: 14.0, weight: UIFontWeightRegular)
        label.textColor = .white
        return label
    }()
    
    
    /// The password field.
    open private(set) lazy var passwordField: UITextField = { [unowned self] in
        let passwordField = self.newTextField(forPassword: true)
        passwordField.delegate = self
        passwordField.returnKeyType = .done
        passwordField.clearsOnBeginEditing = true
        passwordField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
        passwordField.addObserver(self, forKeyPath: #keyPath(UITextField.text), context: &kvoContext)
        self.isPasswordFieldLoaded = true
        
        return passwordField
    }()
    
    
    /// The login button.
    ///
    /// This is only availale after the view is loaded.
    /// To default background image for this button is a template image and will adapt to the standard tintColor.
    open private(set) lazy var loginButton: UIButton = { [unowned self] in
        let buttonBackground = UIImage.resizableRoundedImage(cornerRadius: 6.0, borderWidth: 0.0, borderColor: nil, fillColor: .white)
        
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
        button.setBackgroundImage(buttonBackground.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setTitle("Login Now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .disabled)
        button.adjustsImageWhenDisabled = true
        button.addTarget(self, action: #selector(loginButtonTriggered), for: .primaryActionTriggered)
        
        self.isLoginButtonLoaded = true
        return button
    }()
    
    
    /// The terms and conditions string to present at the bottom of login window.
    open private(set) lazy var termsAndConditionsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "By continuing you indicate that you have read\nand agree to the Terms of Service"
        label.font = .systemFont(ofSize: 14.0)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .lightGray
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
    
    
    // MARK: - Private properties
    
    private var _preferredStatusBarStyle: UIStatusBarStyle = .lightContent
    
    private var _prefersStatusBarHidden: Bool = false
    
    private var backgroundView: UIImageView?
    
    private var scrollView: UIScrollView?
    
    private var contentStackView: UIStackView?
    
    private var preferredLayoutGuideBottomConstraint: NSLayoutConstraint?
    
    private var separatorHeightConstraint: NSLayoutConstraint?
    
    private var keyboardInset: CGFloat = 0.0 {
        didSet {
            if isViewLoaded {
                view.setNeedsLayout()
                
                let hidden = keyboardInset !=~ 0.0
                headerView?.isHidden = hidden
                
                let scrollView = self.scrollView!
                scrollView.contentInset.bottom = keyboardInset
                scrollView.scrollIndicatorInsets.bottom = keyboardInset
                
                scrollView.alwaysBounceVertical = hidden
            }
        }
    }
    
    private var isUsernameFieldLoaded: Bool = false
    
    private var isPasswordFieldLoaded: Bool = false
    
    private var isLoginButtonLoaded: Bool = false
    
    
    
    // MARK: - Initializers
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidHide(_:)),  name: .UIKeyboardDidHide,  object: nil)
    }
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    deinit {
        if isUsernameFieldLoaded {
            usernameField.removeObserver(self, forKeyPath:#keyPath(UITextField.text), context: &kvoContext)
        }
        if isPasswordFieldLoaded {
            passwordField.removeObserver(self, forKeyPath:#keyPath(UITextField.text), context: &kvoContext)
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
        
        let contentGuide = UILayoutGuide()
        scrollView.addLayoutGuide(contentGuide)
        
        let usernameLabel = self.usernameLabel
        let passwordLabel = self.passwordLabel
        let usernameField = self.usernameField
        let passwordField = self.passwordField
        
        let usernameSeparator = UIView(frame: .zero)
        let passwordSeparator = UIView(frame: .zero)
        let credentialsView = UIView(frame: .zero)
        
        usernameSeparator.backgroundColor = #colorLiteral(red: 0.7630171865, green: 0.7580402272, blue: 0.7838609132, alpha: 0.8041923415)
        passwordSeparator.backgroundColor = #colorLiteral(red: 0.7630171865, green: 0.7580402272, blue: 0.7838609132, alpha: 0.8041923415)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        usernameSeparator.translatesAutoresizingMaskIntoConstraints = false
        passwordSeparator.translatesAutoresizingMaskIntoConstraints = false
        credentialsView.translatesAutoresizingMaskIntoConstraints = false
        
        credentialsView.addSubview(usernameSeparator)
        credentialsView.addSubview(passwordSeparator)
        credentialsView.addSubview(usernameLabel)
        credentialsView.addSubview(passwordLabel)
        credentialsView.addSubview(usernameField)
        credentialsView.addSubview(passwordField)
        
        let loginStackView = UIStackView(arrangedSubviews: [loginButton, termsAndConditionsLabel])
        loginStackView.axis = .vertical
        loginStackView.alignment = .center
        loginStackView.spacing   = 20.0
        
        var contentViews: [UIView] = [credentialsView, loginStackView]
        if let header = headerView {
            contentViews.insert(header, at: 0)
        }
        
        let contentStackView = UIStackView(arrangedSubviews: contentViews)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing   = 50.0
        contentStackView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        scrollView.addSubview(contentStackView)
        
        self.backgroundView   = backgroundView
        self.scrollView       = scrollView
        self.contentStackView = contentStackView
        
        self.view = backgroundView
        
        let preferredLayoutGuideBottomConstraint = NSLayoutConstraint(item: contentGuide, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: backgroundView, attribute: .height, priority: UILayoutPriorityRequired - 1)
        
        let separatorHeightConstraint = NSLayoutConstraint(item: usernameSeparator, attribute: .height, relatedBy: .equal, toConstant: 1.0 / traitCollection.currentDisplayScale)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: contentGuide, attribute: .width, relatedBy: .equal, toItem: backgroundView, attribute: .width),
            preferredLayoutGuideBottomConstraint,
            
            NSLayoutConstraint(item: scrollView, attribute: .leading,  relatedBy: .equal, toItem: contentGuide, attribute: .leading),
            NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: contentGuide, attribute: .trailing),
            NSLayoutConstraint(item: scrollView, attribute: .top,      relatedBy: .equal, toItem: contentGuide, attribute: .top),
            NSLayoutConstraint(item: scrollView, attribute: .bottom,   relatedBy: .equal, toItem: contentStackView, attribute: .bottom, constant: 20.0),
            
            NSLayoutConstraint(item: credentialsView, attribute: .width, relatedBy: .equal, toConstant: 256.0),
            NSLayoutConstraint(item: usernameLabel, attribute: .width,   relatedBy: .equal, toItem: credentialsView, attribute: .width),
            NSLayoutConstraint(item: usernameLabel, attribute: .leading, relatedBy: .equal, toItem: credentialsView, attribute: .leading),
            
            NSLayoutConstraint(item: contentStackView, attribute: .centerX, relatedBy: .equal, toItem: contentGuide, attribute: .centerX),
            NSLayoutConstraint(item: contentStackView, attribute: .centerY, relatedBy: .equal, toItem: contentGuide, attribute: .centerY),
            NSLayoutConstraint(item: contentStackView, attribute: .bottom,  relatedBy: .lessThanOrEqual, toItem: contentGuide, attribute: .bottom, constant: -20.0),
            NSLayoutConstraint(item: contentStackView, attribute: .width,   relatedBy: .lessThanOrEqual, toItem: contentGuide, attribute: .width, constant: -20.0),
            
            separatorHeightConstraint,
            
            NSLayoutConstraint(item: loginButton, attribute: .width,  relatedBy: .greaterThanOrEqual, toConstant: 160.0),
            NSLayoutConstraint(item: loginButton, attribute: .height, relatedBy: .greaterThanOrEqual, toConstant: 48.0),
        ] + NSLayoutConstraint.constraints(withVisualFormat: "V:|[ul]-4-[uf]-11-[us]-18-[pl]-4-[pf]-11-[ps(==us)]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: ["ul": usernameLabel, "uf": usernameField, "us": usernameSeparator, "pl": passwordLabel, "pf": passwordField, "ps": passwordSeparator]))
        
        self.preferredLayoutGuideBottomConstraint = preferredLayoutGuideBottomConstraint
        self.separatorHeightConstraint            = separatorHeightConstraint
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLoginButtonState()
    }
    
    open override func viewWillLayoutSubviews() {
        termsAndConditionsLabel.preferredMaxLayoutWidth = view.bounds.width - 20.0
        
        let topLayoutInset    = topLayoutGuide.length
        let bottomLayoutInset = max(bottomLayoutGuide.length, keyboardInset, 20.0)
        
        preferredLayoutGuideBottomConstraint?.constant = (bottomLayoutInset + topLayoutInset) * -1.0
        scrollView?.contentInset = UIEdgeInsets(top: topLayoutInset, left: 0.0, bottom: bottomLayoutInset, right: 0.0)
        super.viewWillLayoutSubviews()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        separatorHeightConstraint?.constant = 1.0 / traitCollection.currentDisplayScale
    }
    
    
    // MARK: - Text field delegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isUsernameFieldLoaded && textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if isPasswordFieldLoaded && textField == passwordField {
            passwordField.resignFirstResponder()
            
            if loginButton.isEnabled {
                loginButtonTriggered()
            }
        }
        return false
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
    
    @objc private func loginButtonTriggered() {
        guard let username = usernameField.text, let password = passwordField.text else { return }
        
        view.endEditing(true)
        
        delegate?.loginViewController(self, didFinishWithUsername: username, password: password)
    }
    
    @objc private func textFieldTextDidChange(_ textField: UITextField) {
        if (isUsernameFieldLoaded && textField == usernameField) || (isPasswordFieldLoaded && textField == passwordField) {
            updateLoginButtonState()
        }
    }
    
    private func updateLoginButtonState() {
        if isLoginButtonLoaded == false { return }
        
        let isUsernameValid: Bool = isUsernameFieldLoaded && usernameField.text?.characters.count ?? 0 >= minimumUsernameLength
        let isPasswordValid: Bool = isPasswordFieldLoaded && passwordField.text?.characters.count ?? 0 >= minimumPasswordLength
        
        loginButton.isEnabled = isUsernameValid && isPasswordValid
    }
    
    private func newTextField(forPassword password: Bool) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.font                 = .systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
        textField.textColor            = .white
        textField.isSecureTextEntry    = password
        textField.attributedPlaceholder = NSAttributedString(string: "Required", attributes: [NSForegroundColorAttributeName: UIColor(white: 0.7, alpha: 0.5)])
        textField.clearButtonMode      = .whileEditing
        textField.autocorrectionType   = .no
        return textField
    }
    
}


public protocol LoginViewControllerDelegate: class {
    
    func loginViewController(_ controller: LoginViewController, didFinishWithUsername username: String, password: String)
    
}



// MARK: - Keyboard animation conveniences

private struct KeyboardAnimationDetails {
    var startFrame: CGRect
    var endFrame: CGRect
    var duration: TimeInterval
    var curve: UIViewAnimationOptions
}

private extension Notification {
    
    /// Returns the keyboard animation details from the notification, if it is a keyboard update notification.
    func keyboardAnimationDetails() -> KeyboardAnimationDetails? {
        guard let userInfo = self.userInfo,
              let startFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect,
              let endframe   = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
              let duration   = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return nil }
        
        let animationCurve: UIViewAnimationOptions
        if let curveInt = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int,
            let curve = UIViewAnimationCurve(rawValue: curveInt) {
            animationCurve = curve.animationOption
        } else {
            animationCurve = .curveEaseInOut
        }
        
        return KeyboardAnimationDetails(startFrame: startFrame, endFrame: endframe, duration: duration, curve: animationCurve)
    }
    
}


private extension UIViewAnimationCurve {
    
    var animationOption: UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(self.rawValue << 16))
    }
    
}

