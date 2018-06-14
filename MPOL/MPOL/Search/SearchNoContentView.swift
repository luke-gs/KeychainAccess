//
//  SearchNoContentView.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import ClientKit

public class SearchNoContentView: LoadingStateNoContentView {

    public var tasksButton = UIButton(frame: .zero)

    override public init(frame: CGRect) {
        super.init(frame: frame)

        let officer = UserSession.current.userStorage?.retrieve(key: UserSession.currentOfficerKey) as? Officer

        let hours = Calendar.current.component(.hour, from: Date())

        var greetingText: String

        if hours >= 0 && hours < 12 {
            greetingText = "Good Morning"
        } else if hours >= 12 && hours < 17 {
            greetingText = "Good Afternoon"
        } else {
            greetingText = "Good Evening"
        }

        if let officerFirstName = officer?.givenName {
            greetingText += " " + officerFirstName + "!"
        } else {
            greetingText += "!"
        }

        titleLabel.text = greetingText
        subtitleLabel.text = "Looks like it's a new day for you. We don't have any Recently Viewed Entities or Recent Searches to show you right now."
        actionButton.setTitle("New Search", for: .normal)

        tasksButton.setTitle("View My Tasks", for: .normal)
        tasksButton.setTitleColor(tintColor, for: .normal)

        addArrangedSubview(tasksButton)
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
