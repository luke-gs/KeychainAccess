//
//  QuantityPickerViewController.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

fileprivate let reuseIdentifier = "reuseIdentifier"

public struct QuantityPicked {
    let object: Pickable
    let count: Int
}

open class QuantityPickerViewController<T>: FormCollectionViewController where T: Pickable {

    private let headerHeight: CGFloat = 144

    open var items: [QuantityPicked] = []

    open var completionHandler: (([QuantityPicked]) -> Void)?

    public init(items: [T]) {
        super.init()

        self.items = items.map { (pickable) -> QuantityPicked in
            return QuantityPicked(object: pickable, count: 0)
        }

        wantsTransparentBackground = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone))

        title = "Add Equipment"

    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }


    // MARK: - View Lifecycle

    open override func loadView() {
        super.loadView()

        view.backgroundColor = UIColor.clear

        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.register(CollectionViewFormStepperCell.self)
        guard let collectionView = collectionView else { return }

        let header = SearchHeaderView()
        header.titleLabel.text = "3 Equipment"
        header.subtitleLabel.text = "Radar (1), Traffic Direction Cones (8), Tyre Deflation Device (2)"
        view.addSubview(header)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            header.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            header.heightAnchor.constraint(equalToConstant: headerHeight),

            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor),
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

    // MARK: - CollectionView

    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormStepperCell.self, for: indexPath)
        cell.separatorColor = iOSStandardSeparatorColor
        let item = self.items[indexPath.row]
        cell.titleLabel.text = item.object.title
        cell.stepper.value = Double(item.count)


    }

    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(of: CollectionViewFormStepperCell.self, for: indexPath)
    }

    override open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)

    }

    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            // Update title view based on new traits
//            if let subtitle = self.callsignListViewModel?.navSubtitle() {
//                self.setTitleView(title: self.viewModel.navTitle(), subtitle: subtitle)
//            }
        }, completion: nil)
    }

    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let item = self.items[indexPath.row]
        return CollectionViewFormStepperCell.minimumContentHeight(withTitle: item.object.title, value: Double(item.count), valueFont: .systemFont(ofSize: 17.0), numberOfDecimalPlaces: 0, inWidth: itemWidth, compatibleWith: traitCollection)
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        callsignListViewModel?.applyFilter(withText: searchText)
    }

}
