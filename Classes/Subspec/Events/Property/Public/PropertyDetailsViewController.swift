//
//  PropertyDetailsViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public class PropertyDetailsViewController: ThemedPopoverViewController, EvaluationObserverable {

    private(set) var addPropertyViewController: SearchDisplayableViewController<PropertyDetailsViewController, PropertySearchDisplayableViewModel>!
    private(set) var propertyDetailsGeneralViewController: DefaultPropertyViewController!
    private(set) var propertyDetailsMediaViewController: DefaultPropertyViewController!
    private(set) var propertyDetailsDetailsViewController: DefaultPropertyViewController!

    let viewModel: PropertyDetailsViewModel

    private var addPropertyView = UIView()
    private let scrollView = UIScrollView()
    private let containerStackView = UIStackView()
    private var presenter: PropertyDetailsPresenter!

    lazy var decorator = {
        PropertyDetailsViewControllerDecorator(addPropertyView: addPropertyView,
                                               detailsScrollView: scrollView,
                                               stackView: containerStackView)
    }()


    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(viewModel: PropertyDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Add Property"

        let searchViewModel = PropertySearchDisplayableViewModel(properties: viewModel.properties)
        addPropertyViewController = SearchDisplayableViewController<PropertyDetailsViewController, PropertySearchDisplayableViewModel>(viewModel: searchViewModel)
        addPropertyViewController.delegate = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        presenter = PropertyDetailsPresenter(containerViewController: self,
                                             addPropertyView: addPropertyView,
                                             displayPropertyView: scrollView)

        let generalPlugins: [FormBuilderPlugin] = [AddPropertyGeneralPlugin(viewModel: viewModel, delegate: self)]
        propertyDetailsGeneralViewController = DefaultPropertyViewController(plugins: generalPlugins)

        let mediaPlugins: [FormBuilderPlugin] = [AddPropertyMediaPlugin(viewModel: viewModel, context: self)]
        propertyDetailsMediaViewController = DefaultPropertyViewController(plugins: mediaPlugins)

        let detailPlugins: [FormBuilderPlugin] = [AddPropertyDetailsPlugin(viewModel: viewModel)]
        propertyDetailsDetailsViewController = DefaultPropertyViewController(plugins: detailPlugins)

        addMainViewController()
        addContentController(propertyDetailsGeneralViewController)
        addContentController(propertyDetailsMediaViewController)
        addContentController(propertyDetailsDetailsViewController)

        decorator.constrain(self)
        decorator.constrainChild(addPropertyViewController)
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }

    public override func apply(_ theme: Theme) {
        super.apply(theme)
        decorator.apply(theme)
    }

    // MARK: Internal

    @objc func didTapOnDone() {
        dismissAnimated()
        viewModel.completion?(viewModel.report)
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
}


// MARK: AddPropertyDelegate

extension PropertyDetailsViewController: AddPropertyDelegate {
    func didTapOnPropertyType() {
        presenter.switchState()
    }
}


// MARK: SearchDisplayableDelegate

extension PropertyDetailsViewController: SearchDisplayableDelegate {
    public typealias Object = Property

    public func genericSearchViewController(_ viewController: UIViewController,
                                            didSelectRowAt indexPath: IndexPath,
                                            withObject object: Property) {
        viewModel.updateDetails(with: object)
        propertyDetailsDetailsViewController.plugins = [AddPropertyDetailsPlugin(viewModel: viewModel)]
        propertyDetailsGeneralViewController.plugins = [AddPropertyGeneralPlugin(viewModel: viewModel, delegate: self)]
        presenter.switchState()
    }
}
