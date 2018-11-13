//
//  SearchNoContentView.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

public class SearchNoContentView: LoadingStateNoContentView {

    override public init(frame: CGRect) {
        super.init(frame: frame)

        let officer: Officer? = UserSession.current.userStorage?.retrieve(key: UserSession.currentOfficerKey)

        let hours = Calendar.current.component(.hour, from: Date())

        var greetingText: String

        if hours >= 0 && hours < 12 {
            greetingText = NSLocalizedString("Good Morning", comment: "")
        } else if hours >= 12 && hours < 17 {
            greetingText = NSLocalizedString("Good Afternoon", comment: "")
        } else {
            greetingText = NSLocalizedString("Good Evening", comment: "")
        }

        if let officerFirstName = officer?.givenName {
            greetingText += " " + officerFirstName + "!"
        } else {
            greetingText += "!"
        }

        titleLabel.text = greetingText

        let theme = ThemeManager.shared.theme(for: userInterfaceStyle)
        subtitleLabel.textColor = theme.color(forKey: .primaryText)
        subtitleLabel.text = NSLocalizedString("Looks like it's a new day for you. We don't have any Recently Viewed Entities or Recent Searches to show you right now.", comment: "")
        actionButton.setTitle(NSLocalizedString("New Search", comment: ""), for: .normal)
        actionButton.roundingStyle = .max
        NSLayoutConstraint.activate([actionButton.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 0.5)])
    }

    @objc override public func interfaceStyleDidChange() {
        let theme = ThemeManager.shared.theme(for: userInterfaceStyle)
        titleLabel.textColor = theme.color(forKey: .primaryText)
        subtitleLabel.textColor = theme.color(forKey: .primaryText)
    }

    required public init(coder: NSCoder) {
        MPLCodingNotSupported()
    }
}
