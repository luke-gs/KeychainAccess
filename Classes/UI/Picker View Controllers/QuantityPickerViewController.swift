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

public struct QuantityPicked: Equatable {
    public let object: Pickable
    public var count: Int

    public init(object: Pickable, count: Int = 0) {
        self.object = object
        self.count = count
    }

    public static func ==(lhs: QuantityPicked, rhs: QuantityPicked) -> Bool {
        return lhs.object.title == rhs.object.title
    }
}

open class QuantityPickerViewController: FormBuilderViewController {

    private let headerHeight: CGFloat = 144
    private let cellFont: UIFont = .systemFont(ofSize: 17.0, weight: .semibold)
    public let headerView = SearchHeaderView()

    private var filterText: String?

    private let viewModel: QuantityPickerViewModel

    private var initialItems: [QuantityPicked]

    // Closure called when user cancels selection. Argument is initial items before any changes
    open var cancelHandler: (([QuantityPicked]) -> Void)?

    // Closure called when user accepts selection. Argument is updated items
    open var doneHandler: (([QuantityPicked]) -> Void)?

    // MARK: - Initializers
    public init(viewModel: QuantityPickerViewModel) {
        self.viewModel = viewModel

        // Keep a copy of initial item counts, for cancellation case
        self.initialItems = viewModel.items

        super.init()

        builder.title = builder.title ?? viewModel.subjectMatter

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

        headerView.titleLabel.text = "0 \(viewModel.subjectMatter)"
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

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateHeaderText()
    }

    // MARK: - Actions

    @objc
    private func onCancel() {
        cancelHandler?(initialItems)
    }

    @objc
    private func onDone() {
        doneHandler?(viewModel.items)
    }

    // MARK: - Convenience

    /// Updates the title and subtitle based on the selected values of items
    open func updateHeaderText() {
        let items = viewModel.items
        let includedItems = items.flatMap {
            guard let title = $0.object.title else { return nil }
            guard $0.count != 0 else { return nil }
            return "\(title) (\($0.count))"
        } as [String?]

        headerView.titleLabel.text = "\(includedItems.count) \(viewModel.subjectMatter)"
        headerView.subtitleLabel.text = includedItems.joined(separator: ", ")
    }

    public func shouldDisplayItem(_ item: QuantityPicked) -> Bool {
        guard let filterText = filterText?.lowercased() else { return true }
        guard filterText.count > 0 else { return true }
        guard let title = item.object.title?.lowercased() else { return false }

        return title.hasPrefix(filterText)
    }

    // MARK: - Form

    override open func construct(builder: FormBuilder) {
        let items = viewModel.items
        for index in 0..<items.count {
            let item = items[index]

            // Rule is that matched items start with the search term.

            guard shouldDisplayItem(item) == true else { continue }

            let formItem = StepperFormItem(title: item.object.title)
            .minimumValue(0)
            .value(Double(item.count))
            .width(.column(1))
            .displaysZeroValue(false)
            .onValueChanged { [unowned self] (value) in
                self.viewModel.items[index].count = Int(value)
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
