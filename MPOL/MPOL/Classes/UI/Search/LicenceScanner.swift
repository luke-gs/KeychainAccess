//
//  LicenceScanner.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import Firebase

public class LicenceScanner {

    public func startScan(with image: UIImage, completion: @escaping ((String) -> ())) {
        let vision = Vision.vision()
        let textRecognizer = vision.onDeviceTextRecognizer()
        let visionImage = VisionImage(image: image)

        textRecognizer.process(visionImage) { [unowned self] result, error in
            guard error == nil else { return }
            guard let result = result else { return }

            completion(self.filterLicence(from: result.text) ?? "")
        }
    }

    private func filterLicence(from text: String) -> String? {
        let filteredText = text.filter {$0 != " "}
        let regex = try! NSRegularExpression(pattern: "\\d{9}", options: .caseInsensitive)
        guard let result = regex.firstMatch(in: filteredText, range: NSRange(location: 0, length: filteredText.count)) else { return nil }

        return (filteredText as NSString).substring(with: result.range)
    }
}
