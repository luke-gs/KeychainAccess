//
//  LoginStyleSetup.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

public extension LoginViewController {
    public func setupDefaultStyle(with username: String?) {

        let imageView = UIImageView(image: #imageLiteral(resourceName: "PSCore"))
        imageView.contentMode = .top
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: titleView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: titleView.rightAnchor),
            imageView.topAnchor.constraint(equalTo: titleView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
        ])

        let usernameCred = UsernameCredential(username: username)
        let passwordCred = PasswordCredential()

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

        let detailContainer = HighlightTextModel(text: "By continuing you are agreeing to the Terms and \n Conditions previously presented to you.", highlightText: nil)

        detailTextView.highlightTextModel = detailContainer
        detailTextView.textColor = .secondaryGray
        detailTextView.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        detailTextView.textAlignment = .center
        detailTextView.delegate = self
    }
}

public extension LoginContainerViewController {
    public func setupDefaultStyle() {
        
        let versionLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.font = .systemFont(ofSize: 13.0, weight: UIFont.Weight.bold)
            label.textColor = .secondaryGray

            if let info = Bundle.main.infoDictionary {
                let version = info["CFBundleShortVersionString"] as? String ?? ""
                let build   = info["CFBundleVersion"] as? String ?? ""

                label.text = "Version \(version) #\(build)"
            }

            label.textAlignment = .center
            return label
        }()

        let gridstoneImageView = UIImageView(image: AssetManager.shared.image(forKey: .GSLogo))
        gridstoneImageView.contentMode = .bottomLeft

        let motoImageView = UIImageView(image: AssetManager.shared.image(forKey: .MotoLogo))
        motoImageView.contentMode = .bottomRight

        backgroundImage = #imageLiteral(resourceName: "Login")

        let imageStackView = UIStackView(arrangedSubviews: [gridstoneImageView, motoImageView])
        imageStackView.axis = .horizontal
        imageStackView.alignment = .center
        imageStackView.spacing = 16.0

        let footerStackView = UIStackView(arrangedSubviews: [versionLabel, imageStackView])
        footerStackView.axis = .vertical
        footerStackView.alignment = .center
        footerStackView.spacing = 16.0

        setFooterView(footerStackView, at: .center)
    }
}
