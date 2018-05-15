//
//  TrafficInfringementOffencesViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class TrafficInfringementOffencesViewController: FormBuilderViewController, EvaluationObserverable {
    
    var viewModel: TrafficInfringementOffencesViewModel
    var totalsView: OffencePointAndFineTotalsView = OffencePointAndFineTotalsView(frame: .zero)
    
    public init(viewModel: TrafficInfringementOffencesViewModel) {
        self.viewModel = viewModel
        super.init()
        self.viewModel.report.evaluator.addObserver(self)
        
        title = viewModel.title
        
        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.alert)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        //set initial state
        setLoadingManagerState()
        
        //text and image for "noContent" state
        loadingManager.noContentView.titleLabel.text = "No Offences Added"
        loadingManager.noContentView.subtitleLabel.text = "This report requires at least one offence"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.dialogAlert)
        loadingManager.noContentView.actionButton.setTitle("Add Offence", for: .normal)
        loadingManager.noContentView.actionButton.addTarget(self, action: #selector(presentOffenceSearchVC), for: .touchUpInside)

        //add totals view and constraints
        view.addSubview(totalsView)
        totalsView.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalsView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
            (collectionView?.topAnchor.constraint(equalTo: view.topAnchor))!,
            (collectionView?.leadingAnchor.constraint(equalTo: view.leadingAnchor))!,
            (collectionView?.trailingAnchor.constraint(equalTo: view.trailingAnchor))!, 
            (collectionView?.bottomAnchor.constraint(equalTo: totalsView.topAnchor))!
        ])
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: viewModel.headerFormItemTitle)
            .actionButton(title: "Add", handler: {_ in
                self.presentOffenceSearchVC()
            })

        //create item for each offence
        viewModel.report.offences.forEach { offence in
            //we can create an OffenceListDisplayable here to get the subtitle property that we need, saves re-creating it
            let displayable = OffenceListDisplayable(offence: offence)
            builder += SubtitleFormItem()
                .title(displayable.title)
                .subtitle(displayable.subtitle)
                .width(.column(1))
                .image(AssetManager.shared.image(forKey: AssetManager.ImageKey.alert))
                .imageTintColor(UIColor.black)
                .editActions([CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { (cell, indexPath) in
                    self.viewModel.removeOffence(at: indexPath.row)
                    self.offenceListDidUpdate()
                })])
        }
    }
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    @objc func presentOffenceSearchVC() {
        //Temporary test data
        var tempOffences : [Offence] = []
        tempOffences.append(Offence(title: "Disobeying traffic lights, signs or police or authorised person directing traffic", demeritValue: 3, fineValue: 250))
        tempOffences.append(Offence(title: "Failing to give way, or stop, or remain stopped", demeritValue: 3, fineValue: 300))
        tempOffences.append(Offence(title: "Improper overtaking or passing", demeritValue: 2, fineValue: 80))
        tempOffences.append(Offence(title: "Using a mobile phone illegally while driving", demeritValue: 4, fineValue: 420))
        tempOffences.append(Offence(title: "Turn or stop without signalling", demeritValue: 2, fineValue: 80))
        let viewModel = OffenceSearchViewModel(items: tempOffences)

        let offenceSearchController = SearchDisplayableViewController<TrafficInfringementOffencesViewController, OffenceSearchViewModel>(viewModel: viewModel)
        offenceSearchController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        offenceSearchController.delegate = self
        let navController = PopoverNavigationController(rootViewController: offenceSearchController)
        //TODO: Fix .pageSheet so that it can be used, currently produces a weird grey background
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true, completion: nil)
    }

    @objc private func cancelTapped() {
        dismissAnimated()
    }

    public func viewModelDidTapAdd(_ viewModel: TrafficInfringementOffencesViewModel) {
        presentOffenceSearchVC()
    }

    private func offenceListDidUpdate() {
        self.reloadForm()
        self.setLoadingManagerState()
    }

    private func setLoadingManagerState() {
        if viewModel.hasOffences() {
            loadingManager.state = .loaded
            totalsView.isHidden = false
            updateTotals()
        } else {
            loadingManager.state = .noContent
            totalsView.isHidden = true
        }
    }

    private func updateTotals() {
        totalsView.demeritsValueLabel.text = viewModel.totalDemeritsString
        totalsView.fineValueLabel.text = viewModel.totalFineString
    }
}

extension TrafficInfringementOffencesViewController: SearchDisplayableDelegate {

    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: Offence) {
        viewModel.addOffence(offence: object)
        cancelTapped()
        loadingManager.state = .loaded
        offenceListDidUpdate()
    }
}
