//
//  ViewController.swift
//
//  Created by Herli Halim on 16/8/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var titleLabel = UILabel(frame: .zero)
    let inputLabel = UILabel(frame: .zero)
    let resultLabel = UILabel(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)

        inputLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        inputLabel.numberOfLines = 0

        resultLabel.font = UIFont.preferredFont(forTextStyle: .title2)

        let spacing: CGFloat = 12.0

        let views = ["tl": titleLabel, "il": inputLabel, "rl": resultLabel]

        for (_, subview) in views {
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.setContentHuggingPriority(.required, for: .vertical)
            subview.layer.cornerRadius = 8
            subview.clipsToBounds = true
            view.addSubview(subview)
        }

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[tl]-spacing-[il]-spacing-[rl]", options: [ .alignAllLeading, .alignAllTrailing ], metrics: ["spacing": spacing], views: views)

        // No VFL for safe area insets, cool story!
        constraints.append(contentsOf: [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            titleLabel.leftAnchor.constraint(equalTo: view.readableContentGuide.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: view.readableContentGuide.rightAnchor),

            resultLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -spacing),
        ])

        NSLayoutConstraint.activate(constraints)
    }
}

extension ViewController {

    func willStartRecognisingSpeech() {
        UIView.animate(withDuration: 0.2) {
            self.titleLabel.text = "I'm listening"
            self.inputLabel.text = nil
            self.resultLabel.text = nil

            self.view.backgroundColor = .black
            self.titleLabel.backgroundColor = .yellow
            self.inputLabel.backgroundColor = .yellow
            self.resultLabel.backgroundColor = .yellow
        }
    }

    func didEndRecognisingSpeechWithFinalResult(_ result: String?) {
        resultLabel.text = result

        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = .white

            self.titleLabel.text = "Say \"Bumblebee\" to start"
            self.titleLabel.backgroundColor = .clear
            self.inputLabel.backgroundColor = .clear
            self.resultLabel.backgroundColor = .clear
        }
    }

    func recognisedSpeechWithResult(_ result: String) {
        inputLabel.text = result
    }

    func didEndRecognisingSpeechWithError(_ error: Error) {
        inputLabel.text = error.localizedDescription

        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = .white

            self.titleLabel.text = "Say \"Bumblebee\" to start"
            self.titleLabel.backgroundColor = .clear
            self.inputLabel.backgroundColor = .clear
            self.resultLabel.backgroundColor = .clear
        }
    }
}
