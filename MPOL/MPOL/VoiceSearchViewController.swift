//
//  VoiceSearchViewController.swift
//
//  Created by Herli Halim on 16/8/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PatternKit

class VoiceSearchViewController: FormBuilderViewController {

    public var delegate: VoiceSearchViewControllerDelegate?

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Event", style: .plain, target: self, action: nil)

        // Styling
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.mic)

        loadingManager.noContentView.actionButton.tintColor = view.backgroundColor
        loadingManager.noContentView.actionButton.setTitleColor(view.tintColor, for: .normal)
        loadingManager.noContentView.actionButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)

        loadingManager.state = .noContent
    }

    override func construct(builder: FormBuilder) { }

    @objc private func didTapCancelButton() {
        delegate?.cancelVoiceSearch()
        self.dismissAnimated()
    }
}

extension VoiceSearchViewController {

    func willStartRecognisingSpeech() {
        UIView.animate(withDuration: 0.2) {
            self.loadingManager.noContentView.titleLabel.text = "I'm Listening"
            self.loadingManager.noContentView.subtitleLabel.text = "Input characters/numbers or use the phonetic alphabet."
            self.loadingManager.noContentView.actionButton.setTitle("Cancel Voice Search", for: .normal)
        }
    }

    func didEndRecognisingSpeechWithFinalResult(_ result: String?) {
        if let result = result {
            self.loadingManager.noContentView.subtitleLabel.text = "\"\(result)\""
        }
    }

    func recognisedSpeechWithResult(_ result: String) {
        self.loadingManager.noContentView.subtitleLabel.text = "\"\(result)\""
    }

    func didEndRecognisingSpeechWithError(_ error: Error) {
        self.loadingManager.noContentView.subtitleLabel.text = error.localizedDescription
    }
}

public protocol VoiceSearchViewControllerDelegate: class {
    func cancelVoiceSearch()
}

