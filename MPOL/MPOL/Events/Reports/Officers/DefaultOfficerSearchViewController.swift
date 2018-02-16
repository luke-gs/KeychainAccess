//
//  DefaultOfficerSearchViewController.swift
//  MPOL
//
//  Created by QHMW64 on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

open class DefaultOfficerSearchViewController: FormBuilderViewController, UISearchBarDelegate {

    var tempOfficer: Officer  {
        let x = Officer()
        x.givenName = "Pavel"
        x.involvements = ["Reporting officer"]
        x.surname = "Boryseiko"
        x.rank = "Seargant"
        x.employeeNumber = "#12324234"
        return x
    }

    let involvements = [
        "Reporting Officer",
        "Assisting Officer",
        "Case Officer",
        "Forensic Intelligence Officer",
        "Interviewing Officer",
        "Accident Officer",
        "Action Officer",
    ]

    lazy var officers: [Officer] = Array<Officer>(repeating: tempOfficer, count: 5)

    public override init() {
        super.init()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped(sender:)))
    }

    public var finishHandler: ((Officer) -> ())?

    open override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []
        let searchBarView = StandardSearchBarView(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 64.0)))
        searchBarView.searchBar.delegate = self
        searchBarView.autoresizingMask = [.flexibleWidth]

        view.addSubview(searchBarView)

        let additionalInsets = UIEdgeInsets(top: 64.0, left: 0.0, bottom: 0.0, right: 0.0)
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = additionalInsets
        } else {
            legacy_additionalSafeAreaInsets = additionalInsets
        }
    }

    @objc private func cancelTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    open override func construct(builder: FormBuilder) {
        officers.map { OfficerSearchDisplayable($0) }.forEach { displayable in
            builder += SummaryListFormItem()
                .title(displayable.title)
                .subtitle(displayable.detail1)
                .image(displayable.thumbnail(ofSize: .small))
                .accessory(ItemAccessory.disclosure)
                .onSelection({ (cell) in

                    let summaryDisplayable = OfficerSummaryDisplayable(displayable.officer)

                    let headerConfig = SearchHeaderConfiguration(title: displayable.title,
                                                                 subtitle: summaryDisplayable.detail1?.ifNotEmpty() ?? "No involvements selected",
                                                                 image: displayable.thumbnail(ofSize: .small)?.sizing().image)

                    let datasource = OfficerInvolvementSearchDatasource(objects: self.involvements,
                                                                        selectedObjects: displayable.officer.involvements,
                                                                        allowsMultipleSelection: true,
                                                                        configuration: headerConfig)
                    datasource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))

                    let viewController = CustomPickerController(datasource: datasource)
                    viewController.finishUpdateHandler = { controller, index in
                        let officer = displayable.officer
                        officer.involvements = controller.objects.enumerated().filter { index.contains($0.offset) }.flatMap { $0.element.title }
                        self.finishHandler?(officer)
                    }

                    self.navigationController?.pushViewController(viewController, animated: true)
                })
        }
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let searchParameters = OfficerSearchParameters(familyName: "Black")
        let request = OfficerSearchRequest(source: MPOLSource.mpol, request: searchParameters)
        request.searchPromise().then {
            print($0.results)

        }
    }

}
