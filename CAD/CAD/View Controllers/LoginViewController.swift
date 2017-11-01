//
//  LoginViewController.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 20/10/17.
//  Copyright © 2017 Trent Fitzgibbon. All rights reserved.
//

import UIKit
import MPOLKit

class LoginViewController: UIViewController {

    private var backgroundView: UIImageView!
    private var loginButton: UIButton!
    private let searchAppUrl = URL(string: "\(SEARCH_APP_SCHEME)://")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView = UIImageView(image: UIImage(named: "Login"))
        backgroundView.frame = view.frame
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        loginButton = UIButton(type: .custom)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .disabled)
        loginButton.setTitle("Login in using Search", for: .normal)
        loginButton.setTitle("Please install the Search app to log in", for: .disabled)
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
        
        updateUIForAppExists()
        
        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) { _ in
            self.updateUIForAppExists()
        }
    }
    
    @objc private func updateUIForAppExists() {
        if let url = searchAppUrl, UIApplication.shared.canOpenURL(url) {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }

    @objc private func didTapLogin() {
        // Open search app using URL type
        if let url = searchAppUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                AlertQueue.shared.addErrorAlert(message: NSLocalizedString("Failed to open Search app", comment: ""))
            })
        }
    }

}
