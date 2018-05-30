//
//  PropertyDetailsViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class PropertyDetailsViewController: ThemedPopoverViewController, EvaluationObserverable {

    private(set) var addPropertyViewController: SearchDisplayableViewController<PropertyDetailsViewController, PropertySearchDisplayableViewModel>!
    private(set) var propertyDetailsGeneralViewController: IntrinsicHeightFormBuilderViewController!
    private(set) var propertyDetailsMediaViewController: IntrinsicHeightFormBuilderViewController!
    private(set) var propertyDetailsDetailsViewController: IntrinsicHeightFormBuilderViewController!

    let viewModel: PropertyDetailsViewModel

    private var addPropertyView = UIView()
    private let scrollView = UIScrollView()
    private let containerStackView = UIStackView()

    private lazy var decorator = {
        PropertyDetailsViewControllerDecorator(addPropertyView: addPropertyView,
                                               detailsScrollView: scrollView,
                                               stackView: containerStackView)
    }()

    private lazy var presenter = {
        PropertyDetailsPresenter(containerViewController: self,
                                 addPropertyView: addPropertyView,
                                 displayPropertyView: scrollView)
    }()

    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(viewModel: PropertyDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        let searchViewModel = PropertySearchDisplayableViewModel(properties: viewModel.properties())

        addPropertyViewController = SearchDisplayableViewController<PropertyDetailsViewController, PropertySearchDisplayableViewModel>(viewModel: searchViewModel)
        addPropertyViewController.delegate = self
        addPropertyViewController.title = "Property"

        propertyDetailsGeneralViewController = DefaultPropertyViewController(plugins: [AddPropertyGeneralPlugin(viewModel: viewModel, delegate: self)])
        propertyDetailsMediaViewController = DefaultPropertyViewController(plugins: [AddPropertyMediaPlugin(viewModel: viewModel, delegate: self)])
        propertyDetailsDetailsViewController = DefaultPropertyViewController(plugins: [AddPropertyDetailsPlugin(viewModel: viewModel, delegate: self)])
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        addMainViewController()
        addContentController(propertyDetailsGeneralViewController)
        addContentController(propertyDetailsDetailsViewController)
        addContentController(propertyDetailsMediaViewController)

        decorator.constrain(self)
        decorator.constrainChild(addPropertyViewController)
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }

    // MARK: Private

    private func addMainViewController() {
        addChildViewController(addPropertyViewController)
        addPropertyViewController.didMove(toParentViewController: self)
    }

    private func addContentController(_ child: IntrinsicHeightFormBuilderViewController) {
        addChildViewController(child)
        containerStackView.addArrangedSubview(child.view)
        child.didMove(toParentViewController: self)
    }

    private func removeContentController(_ child: IntrinsicHeightFormBuilderViewController) {
        child.willMove(toParentViewController: nil)
        containerStackView.removeArrangedSubview(child.view)
        child.view.removeFromSuperview()
        child.removeFromParentViewController()
    }
}

extension PropertyDetailsViewController: AddPropertyDelegate {
    func didTapOnPropertyType() {
        presenter.switchState()
    }

    func didTapOnPropertySubtype() {
        presenter.switchState()
    }
}

extension PropertyDetailsViewController: SearchDisplayableDelegate {
    public typealias Object = Property

    public func genericSearchViewController(_ viewController: UIViewController,
                                            didSelectRowAt indexPath: IndexPath,
                                            withObject object: Property) {
        viewModel.report.type = object.type
        viewModel.report.subtype = object.subType

        presenter.switchState()
        propertyDetailsGeneralViewController.reloadForm()
        propertyDetailsDetailsViewController.reloadForm()
    }
}

public class DefaultPropertyViewController: IntrinsicHeightFormBuilderViewController, EvaluationObserverable {
    let plugins: [FormBuilderPlugin]

    public required convenience init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(plugins: [FormBuilderPlugin]) {
        self.plugins = plugins
        super.init()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.isScrollEnabled = false
    }

    override public func construct(builder: FormBuilder) {
        builder.title = title
        plugins.forEach{builder += $0.decorator.formItems()}
    }

    // MARK: Eval
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }
}

protocol AddPropertyDelegate {
    func didTapOnPropertyType()
    func didTapOnPropertySubtype()
}

