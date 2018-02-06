//
//  MediaDetailViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol MediaDetailViewControllerDelegate: class {

    func mediaDetailViewControllerDidUpdatePhotoMedia(_ detailViewController: MediaDetailViewController)

}

public class MediaDetailViewController: FormBuilderViewController {

    public let mediaAsset: MediaAsset

    public weak var delegate: MediaDetailViewControllerDelegate?

    private var titleText: String?
    private var commentsText: String?

    private var sensitive: Bool

    public init(mediaAsset: MediaAsset) {
        self.mediaAsset = mediaAsset

        titleText = mediaAsset.title
        commentsText = mediaAsset.comments
        sensitive = mediaAsset.sensitive

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

        builder += TextFieldFormItem(title: "Comments")
            .text(commentsText)
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
            mediaAsset.title = titleText
            mediaAsset.comments = commentsText
            mediaAsset.sensitive = sensitive
            delegate?.mediaDetailViewControllerDidUpdatePhotoMedia(self)
            dismiss(animated: true, completion: nil)
        case .invalid:
            builder.validateAndUpdateUI()
        }
    }

}
