//
//  VoiceSearchWorkflowManager.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import AVFoundation
import VoiceSearchManager
import PublicSafetyKit

class VoiceSearchWorkflowManager: NSObject, VoiceSearchViewControllerDelegate {

    var viewController: VoiceSearchViewController = VoiceSearchViewController()

    private let voiceSearchManager: VoiceSearchManager = VoiceSearchManager(endScheme: .silence(after: 2))
    private lazy var speechSynthetizer: AVSpeechSynthesizer = {
        let synthetizer = AVSpeechSynthesizer()
        synthetizer.delegate = self
        return synthetizer
    }()
    private var isActive = false

    static let shared = VoiceSearchWorkflowManager()

    private override init() {
        super.init()
        voiceSearchManager.delegate = self
        viewController.delegate = self
    }

    func startListening() {
        isActive = true
        voiceSearchManager.start()
    }

    func stopListening() {
        isActive = false
        voiceSearchManager.pause()
    }

    func beginVoiceSearch() {
       try? voiceSearchManager.startRecognitionTask()
    }

    func speak(_ text: String) {

        return
        
        if voiceSearchManager.isActive {
            voiceSearchManager.pause()
        }
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setMode(AVAudioSessionModeSpokenAudio)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)

        } catch {
            print(#function, error)
        }

        let utterance = AVSpeechUtterance(string: text)
        if speechSynthetizer.isSpeaking {
            speechSynthetizer.stopSpeaking(at: .immediate)
        }
        speechSynthetizer.speak(utterance)

    }

    func cancelSearch() {
        voiceSearchManager.cancel()
    }

}

extension VoiceSearchWorkflowManager: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if isActive {
            voiceSearchManager.start()
        }
    }

}

extension VoiceSearchWorkflowManager: VoiceSearchManagerDelegate {

    var shouldBeginListening: Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.window?.rootViewController?.presentedViewController == nil
    }

    func voiceSearchManagerWillStartRecognisingSpeech(_ manager: VoiceSearchManager) {
        let vc = viewController
        vc.willStartRecognisingSpeech()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController?.present(vc, animated: false, completion: nil)
    }

    func voiceSearchManager(_ manager: VoiceSearchManager, recognisedSpeechWithResult result: String) {
        let vc = viewController
        vc.recognisedSpeechWithResult(result)
    }

    func voiceSearchManager(_ manager: VoiceSearchManager, didEndRecognisingSpeechWithFinalResult result: String?) {

        guard let result = result, !result.isEmpty else {
            viewController.dismiss(animated: true)
            return
        }

        let trans = VehicleRegistrationResultTransformer()

        var rightNow = false

        viewController.didEndRecognisingSpeechWithFinalResult(result)
        viewController.dismiss(animated: false)

        // Change to immediate search for now, to be defined later.
        rightNow = true
        /*
        if let currentRecognition = result {
            let words = currentRecognition.components(separatedBy: " ")
            if let lastWord = words.last {
                if lastWord.localizedCaseInsensitiveCompare("search") == .orderedSame {
                    text = words.dropLast().joined(separator: " ")
                    rightNow = true
                }
            }
        }

        */


        let text = trans.transform(result)


        let searchable = Searchable(text: text, type: "Vehicle")
        if rightNow {
            searchable.options = [100: "OK"]
        }

        let activity = SearchActivity.searchEntity(term: searchable)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        try? appDelegate.searchLauncher.launch(activity, using: appDelegate.navigator)
    }

    func voiceSearchManager(_ manager: VoiceSearchManager, didEndRecognisingSpeechWithError error: Error) {
        let vc = viewController

        vc.didEndRecognisingSpeechWithError(error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            vc.dismiss(animated: false)
        }
    }
}
