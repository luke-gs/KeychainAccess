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

    public override class func controller(forPreview preview: MediaPreviewable) -> (UIViewController & MediaViewPresentable)? {
        if let audioPreview = preview as? AudioPreview {
            return AVMediaViewController(audioPreview: audioPreview)
        } else if let videoPreview = preview as? VideoPreview {
            return AVMediaViewController(videoPreview: videoPreview)
        }
        return nil
    }

    public init(audioPreview: AudioPreview) {
        super.init(preview: audioPreview)
    }

    public init(videoPreview: VideoPreview) {
        super.init(preview: videoPreview)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

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
        let player = AVPlayer(url: preview.media.url)
        let viewController = AVPlayerViewController()
        viewController.player = player
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        present(viewController, animated: true, completion: {
            viewController.player?.play()
        })
    }
}
