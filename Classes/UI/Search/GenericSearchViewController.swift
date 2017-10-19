//
//  GenericSearchViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol GenericSearchDelegate {
    func genericSearchViewControllerDidSelectRow(at indexPath: IndexPath)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
}

public protocol GenericSearchDatasource {
    func numberOfSections() -> Int
    func numberOfRows(in section: Int) -> Int
    func title(for section: Int) -> String
    func name(for indexPath: IndexPath) -> String
    func description(for indexPath: IndexPath) -> String
    func image(for indexPath: IndexPath) -> UIImage
}

public struct GenericSearchViewModel<T: Any> {
    var title: String
    var expandableSections: Bool
    var datasource: GenericSearchDatasource
    var delegate: GenericSearchDelegate?

    public init(title: String, expandableSections: Bool, delegate: GenericSearchDelegate, dataSource: GenericSearchDatasource) {
        self.title = title
        self.expandableSections = expandableSections
        self.delegate = delegate
        self.datasource = dataSource
    }
}

open class GenericSearchViewController<T: Any>: FormBuilderViewController, UISearchBarDelegate {

    private lazy var testHeader: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 80))
        searchBar.delegate = self
        return searchBar
    }()

    private var viewModel: GenericSearchViewModel<T>

    public required init(viewModel: GenericSearchViewModel<T>) {
        self.viewModel = viewModel
        super.init()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func construct(builder: FormBuilder) {
        builder.title = viewModel.title

        for section in 0..<viewModel.datasource.numberOfSections() {
            builder += HeaderFormItem(text: viewModel.datasource.title(for: section))

            for row in 0..<viewModel.datasource.numberOfRows(in: section) {
                let indexPath = IndexPath(row: row, section: section)
                builder += SubtitleFormItem(title: viewModel.datasource.name(for: indexPath),
                                            subtitle: viewModel.datasource.description(for: indexPath),
                                            image: viewModel.datasource.image(for: indexPath),
                                            style: .default)
                    .width(.column(1))
                    .accessory(ItemAccessory.disclosure)
                    .height(.fixed(60))
                    .onSelection { [unowned self] cell in
                        self.viewModel.delegate?.genericSearchViewControllerDidSelectRow(at: indexPath)
                    }
            }
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(testHeader)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11.0, *) {
            testHeader.frame.origin.y = self.view.safeAreaInsets.top - testHeader.frame.height
            additionalSafeAreaInsets.top = testHeader.frame.height
        } else {
            // Fallback on earlier versions
        }
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text \(searchText)")
    }
}

