//
//  AlertSummaryViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class AlertSummaryViewModel {

    private var alert: Alert

    public var alertimage: UIImage {
        let image = AssetManager.shared.image(forKey: .alertFilled)!
            .resizeImageWith(newSize: CGSize(width: 64, height: 64))

        return image.withCircleBackground(tintColor: .black,
                                            circleColor: alert.level?.color,
                                            style: .auto(padding: CGSize(width: 32, height: 32),
                                            shrinkImage: false))!
    }

    public var levelText: StringSizable {

        let levelString = alert.level?.localizedDescription()?.uppercased() ?? "Unknown"

        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .bold),
            NSAttributedString.Key.foregroundColor: alert.level?.color ?? .black
        ]

        return NSAttributedString(string: levelString, attributes: attributes).sizing()
    }

    public var titleText: StringSizable {

        let titleText = alert.title ?? "Unknown"
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .bold)]

        return NSAttributedString(string: titleText, attributes: attributes).sizing()
    }

    public var dateLabel: StringSizable {

        return NSAttributedString(string: "Date Issued",
                                              attributes: [.font: UIFont.systemFont(ofSize: 17.0)])
                                                .sizing()
    }

    public var dateIssued: StringSizable {
        if let date = alert.dateCreated {
            let formatedDate = DateFormatter.preferredDateStyle.string(from: date)
            return NSAttributedString(string: formatedDate,
                                      attributes: [.font: UIFont.systemFont(ofSize: 17.0)])
                                        .sizing()
        }
        return "Unknown".sizing()
    }

    public var description: String {
        return alert.details ?? "details Unknown"
    }

    init(alert: Alert) {
        self.alert = alert
    }
}
