//
//  DefaultPropertyViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class AddPropertyViewController: ThemedPopoverViewController, EvaluationObserverable {

    let addPropertyViewController: SearchDisplayableViewController<DefaultPropertyViewControllerSelectionHandler, DefaultSearchDisplayableViewModel>
    let addPropertyGeneralViewController: IntrinsicHeightFormBuilderViewController
    let addPropertyMediaViewController: IntrinsicHeightFormBuilderViewController
    let addPropertyDetailsViewController: IntrinsicHeightFormBuilderViewController

    let viewModel: DefaultPropertyViewModel

    let scrollView = UIScrollView()
    let containerStackView = UIStackView()

    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(viewModel: DefaultPropertyViewModel) {
        self.viewModel = viewModel
        self.addPropertyViewController = SearchDisplayableViewController<DefaultPropertyViewControllerSelectionHandler, DefaultSearchDisplayableViewModel>(viewModel: DefaultSearchDisplayableViewModel(items: Array(repeating: "TEST", count: 20)))
        self.addPropertyGeneralViewController = DefaultPropertyViewController(viewModel: viewModel)
        self.addPropertyMediaViewController = DefaultPropertyViewController(viewModel: viewModel)
        self.addPropertyDetailsViewController = DefaultPropertyViewController(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)

        self.viewModel.report.evaluator.addObserver(self)

        title = viewModel.title

        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.alert)!
        sidebarItem.color = self.viewModel.tabColor
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        containerStackView.axis = .vertical
        containerStackView.alignment = .fill
        containerStackView.distribution = .fillProportionally
        scrollView.backgroundColor = .magenta
        containerStackView.backgroundColor = .green

        createConstraints()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.report.viewed = true

        addContentController(addPropertyGeneralViewController)
        addContentController(addPropertyMediaViewController)
        addContentController(addPropertyDetailsViewController)
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }

    // MARK: Private

    private func createConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(containerStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            ])
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


public class DefaultPropertyViewController: IntrinsicHeightFormBuilderViewController, EvaluationObserverable {

    let viewModel: DefaultPropertyViewModel
    let delegate = DefaultPropertyViewControllerSelectionHandler()

    public required convenience init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(viewModel: DefaultPropertyViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.report.viewed = true
        collectionView?.isScrollEnabled = false
    }

    override public func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true
        builder += HeaderFormItem(text: "General")
        builder += HeaderFormItem(text: "Media").actionButton(title: "Manage", handler: {_ in})
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
        builder += HeaderFormItem(text: "Property Details")
    }

    // MARK: Eval
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColor
        loadingManager.state = viewModel.loadingManagerState
    }
}

// Separate class for SearchDisplayableDelegate implementation, due to cyclic reference in generic type inference
open class DefaultPropertyViewControllerSelectionHandler: SearchDisplayableDelegate {
    public typealias Object = CustomSearchDisplayable

    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: CustomSearchDisplayable) {
        print(object)
    }
}
