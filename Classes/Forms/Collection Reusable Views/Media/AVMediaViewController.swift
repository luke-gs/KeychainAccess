//
//  AVMediaViewController.swift
//  MPOLKit
//
//  Created by QHMW64 on 24/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import AVKit

/// This is used to present audio and visual content in the same gallery
/// as the photos 
public class AVMediaViewController: MediaViewController {

    public let playButton: UIButton = UIButton()

    override public func viewDidLoad() {
        super.viewDidLoad()

        playButton.setImage(AssetManager.shared.image(forKey: .play), for: .normal)
        playButton.alpha = 0.9
        playButton.imageView?.contentMode = .center
        playButton.titleLabel?.font = UIFont.systemFont(ofSize: 70, weight: .bold)
        playButton.frame = view.frame
        playButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        view.addSubview(playButton)
    }

    @objc private func playTapped() {
        guard let url = mediaAsset.assetURL else { return }
        let player = AVPlayer(url: url)
        let viewController = AVPlayerViewController()
        viewController.player = player
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        present(viewController, animated: true, completion: {
            viewController.player?.play()
        })
    }
}
