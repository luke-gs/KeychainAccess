//
//  MediaDetailViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol MediaDetailViewControllerDelegate: class {

    func mediaDetailViewControllerDidUpdateMedia(_ detailViewController: MediaDetailViewController)

}

public class MediaDetailViewController: FormBuilderViewController {

    public let media: Media

    public weak var delegate: MediaDetailViewControllerDelegate?

    private var titleText: String?
    private var commentsText: String?

    private var sensitive: Bool

    public init(media: Media) {
        self.media = media

        titleText = media.title
        commentsText = media.comments
        sensitive = media.sensitive

        super.init()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped(_:)))
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public override func construct(builder: FormBuilder) {

        builder.title = "Details"

        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "DETAILS")

        builder += TextFieldFormItem(title: "Title")
            .text(titleText)
            .onValueChanged({ [weak self] (text) in
                self?.titleText = text
            })

        builder += TextViewFormItem(title: "Comments")
            .text(commentsText)
            // James promises that one day, this thing will be able to grow dynamically.
            // Until such day, enjoy the 88.
            .height(.fixed(88))
            .onValueChanged({ [weak self] (text) in
                self?.commentsText = text
            })

        builder += OptionFormItem(title: "Sensitive")
            .isChecked(sensitive)
            .onValueChanged({ [weak self] (isChecked) -> (Void) in
                self?.sensitive = isChecked
            })

    }

    // MARK: - Private

    @objc private func cancelButtonTapped(_ item: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func doneButtonTapped(_ item: UIBarButtonItem) {
        let result = builder.validate()
        switch result {
        case .valid:
            media.title = titleText
            media.comments = commentsText
            media.sensitive = sensitive
            delegate?.mediaDetailViewControllerDidUpdateMedia(self)
            dismiss(animated: true, completion: nil)
        case .invalid:
            builder.validateAndUpdateUI()
        }
    }

}
