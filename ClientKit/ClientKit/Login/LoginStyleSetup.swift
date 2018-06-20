//
//  LoginStyleSetup.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public extension FancyLoginViewController {
    public func setupDefaultStyle(with username: String?) {
        let subtitleContainer = HighlightTextContainerThing(text: "By continuing you are agreeing to the Terms and Conditions of Use previously presented to you.",
                                                            highlightText: "Terms and Conditions of Use") { vc in
                                                                print("HELLO!!")
        }

        let detailContainer = HighlightTextContainerThing(text: "Forgot Your Password?",
                                                          highlightText: "Forgot Your Password?") { vc in
                                                            print("HELLO PASSWORD!!")
        }

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

        let usernameCred = UsernameCredential()
        let passwordCred = PasswordCredential()

        usernameCred.inputField.textField.text = username

        #if DEBUG
        usernameCred.inputField.textField.text = "gridstone"
        passwordCred.inputField.textField.text = "mock"
        #endif

        credentials = [
            usernameCred,
            passwordCred
        ]

        let buttonBackground = UIImage.resizableRoundedImage(cornerRadius: 24, borderWidth: 0.0, borderColor: nil, fillColor: .white)
        loginButton.titleLabel?.font = .systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
        loginButton.setBackgroundImage(buttonBackground.withRenderingMode(.alwaysTemplate), for: .normal)
        loginButton.setTitle("Login Now", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .disabled)
        loginButton.adjustsImageWhenDisabled = true
    }
}

public extension LoginContainerViewController {
    public func setupDefaultStyle() {

        var versionLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.font = .systemFont(ofSize: 13.0, weight: UIFont.Weight.bold)
            label.textColor = UIColor(white: 1.0, alpha: 0.64)

            if let info = Bundle.main.infoDictionary {
                let version = info["CFBundleShortVersionString"] as? String ?? ""
                let build   = info["CFBundleVersion"] as? String ?? ""

                label.text = "v\(version) #\(build)"
            }

            label.textAlignment = .right
            return label
        }()

        let imageView = UIImageView(image: #imageLiteral(resourceName: "GSMotoLogo"))
        imageView.contentMode = .bottomLeft

        let loginHeader = LoginHeaderView(title: NSLocalizedString("PSCore", comment: "Login screen header title"),
                                          subtitle: NSLocalizedString("Public Safety Mobile Platform", comment: "Login screen header subtitle"), image: #imageLiteral(resourceName: "MPOLIcon"))

        backgroundImage = #imageLiteral(resourceName: "Login")

        setHeaderView(loginHeader, at: .left)
        setFooterView(imageView, at: .left)
        setFooterView(versionLabel, at: .right)
    }
}
