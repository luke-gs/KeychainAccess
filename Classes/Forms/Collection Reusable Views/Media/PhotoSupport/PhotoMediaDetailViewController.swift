//
//  PhotoMediaDetailViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public protocol PhotoMediaDetailViewControllerDelegate: class {

    func photoMediaDetailViewControllerDidUpdatePhotoMedia(_ detailViewController: PhotoMediaDetailViewController)

}

public class PhotoMediaDetailViewController: FormBuilderViewController {

    public let photoMedia: PhotoMedia

    public weak var delegate: PhotoMediaDetailViewControllerDelegate?

    private var titleText: String?

    private var sensitive: Bool

    public init(photoMedia: PhotoMedia) {
        self.photoMedia = photoMedia

        titleText = photoMedia.title
        sensitive = photoMedia.sensitive

        super.init()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped(_:)))
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            photoMedia.title = titleText
            photoMedia.sensitive = sensitive
            delegate?.photoMediaDetailViewControllerDidUpdatePhotoMedia(self)
            dismiss(animated: true, completion: nil)
        case .invalid:
            builder.validateAndUpdateUI()
        }
    }

}
