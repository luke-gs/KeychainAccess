//
//  DomesticViolencePropertyViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

open class DomesticViolencePropertyViewController: FormBuilderViewController, EvaluationObserverable {

    private(set) var viewModel: DomesticViolencePropertyViewModel

    public init(viewModel: DomesticViolencePropertyViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.addObserver(self)

        // set initial loading manager state
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
        builder.enforceLinearLayout = .always

        builder += LargeTextHeaderFormItem(text: viewModel.headerTitle).separatorColor(.clear)
            .actionButton(title: "Add", handler: { _ in
                self.addProperty()
            })

        for property in viewModel.report.propertyList {
            builder += DetailFormItem(title: property.property?.subType,
                                      subtitle: property.property?.type,
                                      detail: property.involvements?.joined(separator: ", "),
                                      image: nil)
                .accessory(ItemAccessory.pencil)
                .editActions([CollectionViewFormEditAction(title: "Delete", color: .orangeRed, handler: { _, indexPath in
                    self.viewModel.report.propertyList.remove(at: indexPath.row)
                    self.updateLoadingManagerState()
                    self.reloadForm()
                })])
                .onSelection { cell in
                    guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
                    self.update(self.viewModel.report.propertyList[indexPath.row])
            }
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    @objc public func addProperty() {
        let detailsViewModel = PropertyDetailsViewModel(properties: props, involvements: involvs)
        present(with: detailsViewModel)
    }

    public func update(_ propertyDetails: PropertyDetailsReport) {
        let detailsViewModel = PropertyDetailsViewModel(properties: props, involvements: involvs, report: propertyDetails)
        present(with: detailsViewModel)
    }

    // MARK: Private

    private func present(with detailsViewModel: PropertyDetailsViewModel) {
        detailsViewModel.completion = { [unowned self] propertyDetails in
            self.viewModel.add(propertyDetails)
            self.updateLoadingManagerState()
            self.reloadForm()
        }

        let viewController = PropertyDetailsViewController(viewModel: detailsViewModel)
        detailsViewModel.plugins = [
            AddPropertyGeneralPlugin(viewModel: detailsViewModel, context: viewController),
            AddPropertyMediaPlugin(report: detailsViewModel.report, context: viewController),
            AddPropertyDetailsPlugin(report: detailsViewModel.report)
        ]

        let navigationController = PopoverNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true, completion: nil)
    }

    private func updateLoadingManagerState() {
        self.loadingManager.state = viewModel.hasProperty ? .loaded : .noContent
    }
}

// TODO: FIX THIS SHIT WITH PROPER PROPERTIES
private let props: [Property] = [
    Property(type: "General", subType: "Mobile Phone", detailNames: [PropertyDetail(title: "Make", type: .picker(options: ["Apple", "Google"])),
                                                                     PropertyDetail(title: "Model", type: .text),
                                                                     PropertyDetail(title: "Model Year", type: .text),
                                                                     PropertyDetail(title: "Serial Number", type: .text)]),
    Property(type: "General", subType: "Clock"),
    Property(type: "General", subType: "Furniture", detailNames: [PropertyDetail(title: "Colour", type: .picker(options: ["Black", "Blue", "Green"]))]),
    Property(type: "General", subType: "Electrical materials"),
    Property(type: "General", subType: "Laptop computer", detailNames: [PropertyDetail(title: "Make", type: .picker(options: ["HP", "Alienware"])),
                                                                        PropertyDetail(title: "Model", type: .text),
                                                                        PropertyDetail(title: "Serial Number", type: .text)]),
    Property(type: "Drug", subType: "Oil - Cannabis", detailNames: [PropertyDetail(title: "Weight", type: .text)]),
    Property(type: "Drug", subType: "Hashish - Cannabis", detailNames: [PropertyDetail(title: "Weight", type: .text)]),
    Property(type: "Drug", subType: "LSD strips - Amphetamine/methylphetamine", detailNames: [PropertyDetail(title: "Quantity", type: .text)]),
    Property(type: "Firearm", subType: "Air rifle", detailNames: [PropertyDetail(title: "Category", type: .picker(options: ["A", "B", "C"])),
                                                                  PropertyDetail(title: "Condition", type: .picker(options: ["New", "Old", "Used", "Broken"]))]),
    Property(type: "Firearm", subType: "Shotgun - Category B", detailNames: [PropertyDetail(title: "Category", type: .picker(options: ["Combat", "Combination", "Sports"])),
                                                                             PropertyDetail(title: "Condition", type: .text),
                                                                             PropertyDetail(title: "Loaded", type: .picker(options: ["Yes", "No"]))]),
    Property(type: "Animal", subType: "Dog - Pitbull", detailNames: [PropertyDetail(title: "Colour", type: .picker(options: ["Black", "Fawn", "Blue", "Brindle"])),
                                                                     PropertyDetail(title: "Markings", type: .text),
                                                                     PropertyDetail(title: "Gender", type: .picker(options: ["Male", "Female", "Unknown"]))])
]

// TODO: FIX THIS SHIT WITH PROPER INVOLVEMENTS
private let involvs: [String] = ["Broken", "Damaged", "Lost", "Killed", "Stolen"]
