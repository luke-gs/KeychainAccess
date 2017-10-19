//
//  ResultsViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 21/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit


class ResultsViewController: FormBuilderViewController {

    override init() {
        super.init()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }

    override func construct(builder: FormBuilder) {

        formLayout.distribution = .none

        builder.title = "Results"

        builder += HeaderFormItem(text: "DETAIL")

        let person = Person()
        builder += SummaryDetailFormItem()
            .category(person.category)
            .title(person.title)
            .subtitle(person.subtitle)
            .detail(person.detail)
            .buttonTitle("MORE DESCRIPTION")
            .borderColor(person.badgeColor)
            .image(FakeImageLoader(initials: "HH"))
            .onButtonTapped({
                print("Button tapped")
            })
            .onImageTapped({
                print("Image tapped")
            })

        builder += HeaderFormItem(text: "SOURCE 01")
        for _ in 1...4 {
            let person = Person()
            builder += SummaryThumbnailFormItem()
                .category(person.category)
                .title(person.title)
                .subtitle(person.subtitle)
                .detail(person.detail)
                .badge(person.badge)
                .badgeColor(person.badgeColor)
                .borderColor(person.badgeColor)
                .image(FakeImageLoader(initials: "HH"))
                .onSelection({ [unowned self] _ in
                    self.showSecretScreen()
                })
        }

        builder += HeaderFormItem(text: "SOURCE 02")
        for _ in 1...4 {
            let person = Person()
            builder += SummaryThumbnailFormItem()
                .style(.detail)
                .category(person.category)
                .title(person.title)
                .subtitle(person.subtitle)
                .detail(person.detail)
                .badge(person.badge)
                .badgeColor(person.badgeColor)
                .borderColor(person.badgeColor)
                .image(FakeImageLoader(initials: "HH"))
                .onSelection({ [unowned self] _ in
                    self.showSecretScreen()
                })
        }

        builder += HeaderFormItem(text: "SOURCE 03")
        for _ in 1...5 {
            let person = Person()
            builder += SummaryThumbnailFormItem()
                .style(.thumbnail)
                .category(person.category)
                .title(person.title)
                .subtitle(person.subtitle)
                .detail(person.detail)
                .badge(person.badge)
                .badgeColor(person.badgeColor)
                .borderColor(person.badgeColor)
                .image(FakeImageLoader(initials: "HH"))
                .onSelection({ [unowned self] _ in
                    self.showSecretScreen()
                })
        }

        builder += HeaderFormItem(text: "SOURCE 04")
        for _ in 1...6 {
            let person = Person()
            builder += SummaryListFormItem()
                .category(person.category)
                .title(person.title)
                .subtitle("\(person.subtitle!), \(person.detail!)")
                .badge(person.badge)
                .badgeColor(person.badgeColor)
                .borderColor(person.badgeColor)
                .image(FakeImageLoader(initials: "HH"))
                .onSelection({ [unowned self] _ in
                    self.showSecretScreen()
                })
        }

    }

    // MARK: - Private

    @objc private func refresh() {
        reloadForm()
    }

    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

    private func showSecretScreen() {
        let resultsViewController = ResultsViewController()
        resultsViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))

        let viewController = UINavigationController(rootViewController: resultsViewController)
        viewController.modalPresentationStyle = .formSheet

        self.present(viewController, animated: true, completion: nil)
    }

}


class Person {

    var category: String? = "NOOB"

    var title: String? = "Herli Halim"

    var subtitle: String? = "(27) Male"

    var detail: String? = "44 Heartlands Bld, Tarneit VIC 3029"

    var badgeColor: UIColor? = .red

    var badge: UInt = UInt(arc4random_uniform(100))

}


public class FakeImageLoader: ImageLoadable {

    public private(set) var image: UIImage?

    private var attemptToRequest: Bool = false

    private var completion: ((ImageSizable) -> ())?

    public let initials: String

    public init(initials: String) {
        self.initials = initials
        self.image = UIImage.thumbnail(withInitials: initials)
    }

    public func requestImage(completion: @escaping (ImageSizable) -> ()) {
        self.completion = completion

        if attemptToRequest == true {
            return
        }

        let randomSeconds = (Double(arc4random_uniform(2000)) / 1000.0) + 0.3
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + randomSeconds) { [weak self] in
            guard let `self` = self else {
                return
            }

            self.attemptToRequest = true
            self.image = AssetManager.shared.image(forKey: .entityPerson)
            self.completion?(self)
        }
    }

    public func sizing() -> ImageSizing {
        return image?.sizing() ?? ImageSizing(image: nil, size: .zero)
    }

}
