//
//  PropertyDetailsViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

protocol AddPropertyDelegate {
    func didTapOnAddProperty()
    func didAddProperty()
}

private enum AddPropertyState {
    case add
    case display
}

public class PropertyDetailsViewController: ThemedPopoverViewController, EvaluationObserverable {

    private(set) var addPropertyViewController: SearchDisplayableViewController<PropertyDetailsViewController, DefaultSearchDisplayableViewModel>!
    private(set) var addPropertyGeneralViewController: IntrinsicHeightFormBuilderViewController!
    private(set) var addPropertyMediaViewController: IntrinsicHeightFormBuilderViewController!
    private(set) var addPropertyDetailsViewController: IntrinsicHeightFormBuilderViewController!

    private var addPropertyView = UIView()
    private let scrollView = UIScrollView()
    private let containerStackView = UIStackView()
    private lazy var decorator = {
        PropertyDetailsViewControllerDecorator(addPropertyView: addPropertyView,
                                               detailsScrollView: scrollView,
                                               stackView: containerStackView)
    }()

    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(viewModel: PropertyDetailsViewModel) {
        super.init(nibName: nil, bundle: nil)

        addPropertyViewController = SearchDisplayableViewController<PropertyDetailsViewController, DefaultSearchDisplayableViewModel>(viewModel: DefaultSearchDisplayableViewModel(items: Array(repeating: "TEST", count: 20)))
        addPropertyViewController.delegate = self

        addPropertyGeneralViewController = DefaultPropertyViewController(plugins: [AddPropertyGeneralPlugin(viewModel: viewModel, delegate: self)])
        //        self.addPropertyMediaViewController = DefaultPropertyViewController(plugins: [])
        //        self.addPropertyDetailsViewController = DefaultPropertyViewController(plugins: [])
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        decorator.constrain(viewController: self)
        addMainViewController()
        addContentController(addPropertyGeneralViewController)
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchTo(.add)
    }

    // MARK: Private

    private func switchTo(_ state: AddPropertyState) {
        //TODO: ANIMATE THIS SHIT
        switch state {
        case .add:
            view.bringSubview(toFront: addPropertyView)
        case .display:
            view.bringSubview(toFront: scrollView)
        }
    }

    private func addMainViewController() {
        addChildViewController(addPropertyViewController)
        decorator.constrainChild(addPropertyViewController)
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
    func didTapOnAddProperty() {

    }

    func didAddProperty() {

    }
}

extension PropertyDetailsViewController: SearchDisplayableDelegate {
    public typealias Object = CustomSearchDisplayable

    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: CustomSearchDisplayable) {
        switchTo(.display)
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
