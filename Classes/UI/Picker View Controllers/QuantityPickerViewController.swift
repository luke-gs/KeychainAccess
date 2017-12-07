//
//  QuantityPickerViewController.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol QuantityPickable: Pickable {
    var maximumQuantity: Int? { get }
    var minimumQuantity: Int? { get }
}

public struct QuantityPicked {
    let object: Pickable
    var value: Int
}

open class QuantityPickerViewController<T: Pickable>: FormBuilderViewController {

    private let headerHeight: CGFloat = 144
    private let cellFont: UIFont = .systemFont(ofSize: 17.0, weight: .semibold)
    private let headerView = SearchHeaderView()

    private var filterText: String?

    open var subjectMatter: String = NSLocalizedString("Items", comment: "Default Quantity Picker Subject Matter") {
        didSet {
            let format = NSLocalizedString("Add %@", comment:"Action of Add")
            builder.title = String.localizedStringWithFormat(format, subjectMatter)
        }
    }

    open var items: [QuantityPicked] = []

    open var completionHandler: (([QuantityPicked]) -> Void)?

    // MARK: - Initializers

    public init(items: [T]) {
        super.init()

        self.items = items.map { QuantityPicked(object: $0, value: 0) }

        wantsTransparentBackground = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone))
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View Lifecycle

    open override func loadView() {
        super.loadView()

        view.backgroundColor = UIColor.clear

        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        guard let collectionView = collectionView else { return }

        headerView.titleLabel.text = "0 \(subjectMatter)"
        headerView.subtitleLabel.text = ""
        headerView.searchHandler = { [unowned self] (searchText) in
            self.filterText = searchText
            self.reloadForm()
        }
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),

            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor).withPriority(.almostRequired)
            ])
    }

    // MARK: - Actions

    @objc
    func onCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    func onDone() {
        completionHandler?(items)
    }

    // MARK: - Convenience

    /// Updates the title and subtitle based on the selected values of items
    private func updateHeaderText() {
        var string = ""
        var count = 0

        for item in items {
            guard item.value > 0 else { continue }
            if string.count > 0 {
                string += ", "
            }
            string += "\(item.object.title ?? "")(\(item.value))"
            count += 1
        }
        headerView.titleLabel.text = "\(count) \(subjectMatter)"
        headerView.subtitleLabel.text = string
    }

    // MARK: - Form

    override open func construct(builder: FormBuilder) {
        for index in 0..<items.count {
            let item = items[index]

            // Skip if there is a search term that is not matched with item title.
            if let text = filterText, text.count > 0 && item.object.title?.range(of: text, options: .caseInsensitive) == nil {
                continue
            }

            let formItem = StepperFormItem(title: item.object.title)
            .minimumValue(0)
            .value(Double(item.value))
            .width(.column(1))
            .displaysZeroValue(false)
            .onValueChanged { [unowned self] (value) in
                self.items[index].value = Int(value)
                self.updateHeaderText()
            }

            if let quantityPickable = item.object as? QuantityPickable {
                if let maximumQuantity = quantityPickable.maximumQuantity {
                    formItem.maximumValue(Double(maximumQuantity))
                }

                if let minimumQuantity = quantityPickable.minimumQuantity {
                    formItem.maximumValue(Double(minimumQuantity))
                }
            }

            builder += formItem
        }
    }

}
