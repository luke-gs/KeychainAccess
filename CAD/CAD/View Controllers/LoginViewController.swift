//
//  LoginViewController.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 20/10/17.
//  Copyright © 2017 Trent Fitzgibbon. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    private var backgroundView: UIImageView!
    private var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView = UIImageView(image: UIImage(named: "Login"))
        backgroundView.frame = view.frame
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        loginButton = UIButton(type: .custom)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitle("Login in using Search", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func didTapLogin() {
        // Open search app using URL type
        if let url = URL(string: "\(SEARCH_APP_SCHEME)://") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}
