//
//  DomesticViolencePropertyViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

open class DomesticViolencePropertyViewController: FormBuilderViewController, EvaluationObserverable {

    private(set) var viewModel: DomesticViolencePropertyViewModel

    public init(viewModel: DomesticViolencePropertyViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.addObserver(self)

        //set initial loading manager state
        self.updateLoadingManagerState()

        title = "Property"

        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.list)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor

        loadingManager.noContentView.titleLabel.text = "No Property Added"
        loadingManager.noContentView.subtitleLabel.text = "Optional"
        loadingManager.noContentView.actionButton.setTitle("Add Property", for: .normal)
        loadingManager.noContentView.actionButton.addTarget(self, action: #selector(addProperty), for: .touchUpInside)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.report.viewed = true
    }

    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: viewModel.headerTitle, style: .plain)
            .actionButton(title: "Add", handler: { _ in
                self.addProperty()
            })

        for property in viewModel.report.propertyList {
            builder += DetailFormItem(title: property.property?.subType,
                                      subtitle: property.property?.type,
                                      detail: property.involvements?.joined(separator: ", "),
                                      image: nil)
                .accessory(FormAccessoryView(style: .pencil))
                .editActions([CollectionViewFormEditAction(title: "Delete", color: .orangeRed, handler: { cell, indexPath in
                    self.viewModel.report.propertyList.remove(at: indexPath.row)
                    self.updateLoadingManagerState()
                    self.reloadForm()
                })])
                .onSelection { _ in
                    // TODO: Edit Property
            }
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    @objc public func addProperty() {
        let detailsViewModel = PropertyDetailsViewModel(properties: props, involvements: involvs)
        detailsViewModel.completion = { [unowned self] propertyDetails in
            self.viewModel.report.add(propertyDetails)
            self.updateLoadingManagerState()
            self.reloadForm()
        }

        let viewController = PropertyDetailsViewController(viewModel: detailsViewModel)
        let navigationController = PopoverNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true, completion: nil)
    }

    // MARK: Private

    private func updateLoadingManagerState() {
        self.loadingManager.state = viewModel.hasProperty ? .loaded : .noContent
    }
}

//TODO: FIX THIS SHIT WITH PROPER PROPERTIES
private let props: [Property] = [
    Property(type: "General", subType: "Mobile Phone", detailNames: [("Make", .picker(options: ["Apple", "Google"])),
                                                                     ("Model", .text),
                                                                     ("Model Year", .text),
                                                                     ("Serial Number", .text)]),
    Property(type: "General", subType: "Clock"),
    Property(type: "General", subType: "Furniture", detailNames: [("Colour", .picker(options: ["Black", "Blue", "Green"]))]),
    Property(type: "General", subType: "Electrical materials"),
    Property(type: "General", subType: "Laptop computer", detailNames: [("Make", .picker(options: ["HP", "Alienware"])),
                                                                        ("Model", .text),
                                                                        ("Serial Number", .text)]),
    Property(type: "Drug", subType: "Oil - Cannabis", detailNames: [("Weight", .text)]),
    Property(type: "Drug", subType: "Hashish - Cannabis", detailNames: [("Weight", .text)]),
    Property(type: "Drug", subType: "LSD strips - Amphetamine/methylphetamine", detailNames: [("Quantity", .text)]),
    Property(type: "Firearm", subType: "Air rifle", detailNames: [("Category", .picker(options: ["A", "B", "C"])),
                                                                  ("Condition", .picker(options: ["New", "Old", "Used", "Broken"]))]),
    Property(type: "Firearm", subType: "Shotgun - Category B", detailNames: [("Category", .picker(options: ["Combat", "Combination", "Sports"])),
                                                                             ("Condition", .text),
                                                                             ("Loaded", .picker(options: ["Yes", "No"]))]),
    Property(type: "Animal", subType: "Dog - Pitbull", detailNames: [("Colour", .picker(options: ["Black", "Fawn", "Blue", "Brindle"])),
                                                                     ("Markings", .text),
                                                                     ("Gender", .picker(options: ["Male", "Female", "Unknown"]))])
]

//TODO: FIX THIS SHIT WITH PROPER INVOLVEMENTS
private let involvs: [String] = ["Broken", "Damaged", "Lost", "Killed"]
