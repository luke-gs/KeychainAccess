//
//  PropertyDetailsViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public class PropertyDetailsViewController: ThemedPopoverViewController, EvaluationObserverable {

    private(set) var addPropertyViewController: SearchDisplayableViewController<PropertyDetailsViewController, PropertySearchDisplayableViewModel>
    private(set) var propertyDetailsGeneralViewController: DefaultPropertyViewController
    private(set) var propertyDetailsMediaViewController: DefaultPropertyViewController
    private(set) var propertyDetailsDetailsViewController: DefaultPropertyViewController

    let viewModel: PropertyDetailsViewModel

    private var presenter: PropertyDetailsPresenter!
    private var addPropertyView = UIView()
    private let scrollView = UIScrollView()
    private let containerStackView = UIStackView()

    lazy var decorator = {
        PropertyDetailsViewControllerDecorator(addPropertyView: addPropertyView,
                                               detailsScrollView: scrollView,
                                               stackView: containerStackView)
    }()


    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(viewModel: PropertyDetailsViewModel) {
        self.viewModel = viewModel

        let searchViewModel = PropertySearchDisplayableViewModel(properties: viewModel.properties)
        addPropertyViewController = SearchDisplayableViewController<PropertyDetailsViewController, PropertySearchDisplayableViewModel>(viewModel: searchViewModel)

        propertyDetailsGeneralViewController = DefaultPropertyViewController()
        propertyDetailsMediaViewController = DefaultPropertyViewController()
        propertyDetailsDetailsViewController = DefaultPropertyViewController()

        super.init(nibName: nil, bundle: nil)
        title = "Add Property"
        
        propertyDetailsGeneralViewController.plugins = [AddPropertyGeneralPlugin(viewModel: viewModel, delegate: self)]
        propertyDetailsMediaViewController.plugins = [AddPropertyMediaPlugin(viewModel: viewModel, context: self)]
        propertyDetailsDetailsViewController.plugins = [AddPropertyDetailsPlugin(viewModel: viewModel)]

        addPropertyViewController.delegate = self

        presenter = PropertyDetailsPresenter(containerViewController: self,
                                             addPropertyView: addPropertyView,
                                             displayPropertyView: scrollView)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

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
