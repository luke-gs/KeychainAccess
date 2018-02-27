//
//  AudioRecordingViewController.swift
//  MPOLKit
//
//  Created by QHMW64 on 25/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import AVKit
import Lottie

public protocol AudioRecorderControllerDelegate: class {
    func controller(_ controller: AudioRecordingViewController, didFinishWithRecordingURL url: URL)
    func controllerDidCancel(_ controller: AudioRecordingViewController)
}

public class AudioRecordingViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    private enum AudioMode {
        case record
        case play
    }

    public weak var delegate: AudioRecorderControllerDelegate?

    public let waveformView = WaveformView()
    private let url: URL

    private let recordButton: RecordButton = RecordButton()
    private let playButton: UIButton = UIButton()
    private var mode: AudioMode = .record

    private(set) var recorder: AVAudioRecorder?
    private(set) var player: AVAudioPlayer?

    private(set) lazy var sessionConfigurer: AudioSessionConfigurer =
        AudioSessionConfigurer(configuration: AVConfigurations(isMeteringEnabled: true))

    private lazy var doneButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped(item:)))
        barButtonItem.isEnabled = false
        return barButtonItem
    }()

    // Reference to a displayLink - used to ensure deallocation on cleanup
    private var displayLink: CADisplayLink?

    // Initialise with a location at which to save the file
    public init(saveLocation: URL) {
        url = saveLocation

        super.init(nibName: nil, bundle: nil)
        sessionConfigurer.configureActiveSession()

        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelTapped(item:)))

        let defaultSettings = AudioSessionConfigurer.defaultSettings(fromConfigs: sessionConfigurer.configuration)

        recorder = sessionConfigurer.configuredRecorder(forURL: url, withSettings: defaultSettings)
        recorder?.delegate = self

        player = sessionConfigurer.player(forURL: url)
        player?.delegate = self

    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red:0.16, green:0.16, blue:0.17, alpha:1.00)

        [waveformView, recordButton, playButton].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subView)
        }

        recordButton.addTarget(self, action: #selector(recordTapped(button:)), for: .touchUpInside)

        playButton.setImage(AssetManager.shared.image(forKey: .iconPlay), for: .normal)
        playButton.isEnabled = false
        playButton.addTarget(self, action: #selector(playTapped(button:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            waveformView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            waveformView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            waveformView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waveformView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),

            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor, constant: -8.0),
            recordButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -16.0),
            recordButton.widthAnchor.constraint(equalToConstant: 60.0),
            recordButton.heightAnchor.constraint(equalTo: recordButton.widthAnchor),

            playButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor),
            playButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 16.0),
            playButton.widthAnchor.constraint(equalToConstant: 50.0),
            playButton.heightAnchor.constraint(equalTo: playButton.widthAnchor),
        ])
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        displayLink = CADisplayLink(target: self, selector: #selector(updateAudioInput))
        displayLink?.add(to: RunLoop.current, forMode: .commonModes)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        displayLink?.invalidate()
        displayLink = nil
    }

    // Let the delegate handle the dismissal of the controller
    // They may want to do some check before it is saved and if it
    // fails, do not dismiss for example.
    @objc private func doneTapped(item: UIBarButtonItem) {
        recorder?.stop()
        player?.stop()

        delegate?.controller(self, didFinishWithRecordingURL: url)
    }

    @objc private func cancelTapped(item: UIBarButtonItem) {
        recorder?.stop()
        player?.stop()

        // Remove the file if they cancel
        recorder?.deleteRecording()

        delegate?.controllerDidCancel(self)
        dismiss(animated: true, completion: nil)
    }

    @objc private func updateAudioInput() {
        switch mode {
        case .play:
            player?.updateMeters()
            waveformView.updateWave(
            for: AudioOutputFormatter.normalisedOutputValue(
                from: player?.averagePower(forChannel: 0)))
        case .record:
            recorder?.updateMeters()
            waveformView.updateWave(
            for: AudioOutputFormatter.normalisedOutputValue(
                from: recorder?.averagePower(forChannel: 0)))
        }
    }
    
    // MARK: - Touch Handling

    @objc private func recordTapped(button: UIButton) {
        mode = .record

        if recorder?.isRecording == true {
            recorder?.stop()
        } else {
            recorder?.record(forDuration: sessionConfigurer.configuration.maxRecordLength)
            playButton.isEnabled = false
        }
    }

    @objc private func playTapped(button: UIButton) {
        mode = .play
        recorder?.stop()

        if player?.isPlaying == true {
            player?.stop()
            playButton.setImage(AssetManager.shared.image(forKey: .iconPlay), for: .normal)
        } else {
            player = sessionConfigurer.player(forURL: url)
            player?.delegate = self
            player?.play()
            playButton.setImage(AssetManager.shared.image(forKey: .iconPause), for: .normal)
        }
    }

    // MARK: - AVAudioRecorderDelegate

    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }

    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

        // Update controller state
        recordButton.isSelected = false
        doneButton.isEnabled = true
        playButton.isEnabled = true

        let pulseAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.3
        pulseAnimation.toValue = 1.2
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        playButton.layer.add(pulseAnimation, forKey: "pulse")
    }

    // MARK: - AVAudioPlayerDelegate

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(AssetManager.shared.image(forKey: .iconPlay), for: .normal)
    }

    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        // Handle when error occurs during playBack
        if let error = error {
            print(error.localizedDescription)
        }
    }
}
