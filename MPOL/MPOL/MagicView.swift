//
//  MagicView.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import AVFoundation
import Accelerate

class MagicView: UIView {

    private var displayLink: CADisplayLink?
    private let audioEngine: AVAudioEngine = AVAudioEngine()

    let waveView: WaveformView = WaveformView()

    var averagePowerForChannel0 = 0.0
    var averagePowerForChannel1 = 0.0
    let LEVEL_LOWPASS_TRIG = 0.3

    override init(frame: CGRect) {
        super.init(frame: frame)
        waveView.frame = bounds

        addSubview(waveView)

        waveView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            waveView.topAnchor.constraint(equalTo: topAnchor),
            waveView.leftAnchor.constraint(equalTo: leftAnchor),
            waveView.rightAnchor.constraint(equalTo: rightAnchor),
            waveView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            displayLink?.invalidate()
            displayLink = nil
            stop()
        } else {
            displayLink = CADisplayLink(target: self, selector: #selector(updateAudioInput))
            displayLink?.add(to: RunLoop.current, forMode: .commonModes)
            start()
        }
    }

    func start() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.inputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            guard let `self` = self else {
                return
            }

//            self.audioMetering(buffer: buffer)

        }
        try? audioEngine.start()
    }

    /*
    private func audioMetering(buffer:AVAudioPCMBuffer) {
        buffer.frameLength = 1024
        let inNumberFrames:UInt = UInt(buffer.frameLength)
        if buffer.format.channelCount > 0 {
            let samples = (buffer.floatChannelData![0])
            var avgValue:Float32 = 0
            vDSP_meamgv(samples,1 , &avgValue, inNumberFrames)
            var v:Float = -100
            if avgValue != 0 {
                v = 20.0 * log10f(avgValue)
            }
            self.averagePowerForChannel0 = (self.LEVEL_LOWPASS_TRIG*v) + ((1-self.LEVEL_LOWPASS_TRIG)*self.averagePowerForChannel0)
            self.averagePowerForChannel1 = self.averagePowerForChannel0
        }

        if buffer.format.channelCount > 1 {
            let samples = buffer.floatChannelData![1]
            var avgValue:Float32 = 0
            vDSP_meamgv(samples, 1, &avgValue, inNumberFrames)
            var v:Float = -100
            if avgValue != 0 {
                v = 20.0 * log10f(avgValue)
            }
            self.averagePowerForChannel1 = (self.LEVEL_LOWPASS_TRIG*v) + ((1-self.LEVEL_LOWPASS_TRIG)*self.averagePowerForChannel1)
        }
    }
 */

    func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }

    @objc private func updateAudioInput() {

        
    }
}
