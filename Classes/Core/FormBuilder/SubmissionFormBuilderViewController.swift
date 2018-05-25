//
//  SubmissionFormBuilderViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// A `FormBuilderViewController` subclass that provides generally useful OOTB behaviour for forms presented
/// modally that submit data. This includes form validation, loading states and nav buttons
open class SubmissionFormBuilderViewController: FormBuilderViewController {

    /// Optional title and subtitle display in navigation bar
    open var navTitles: (title: String, subtitle: String)?

    open override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton(_:)))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton(_:)))

        // Set initial background color (this may change in wantsTransparentBackground)
        let theme = ThemeManager.shared.theme(for: userInterfaceStyle)
        view.backgroundColor = theme.color(forKey: .background)!

        // Set default error text and retry handling
        self.loadingManager.errorView.titleLabel.text = NSLocalizedString("Failed to Submit", comment: "")
        self.loadingManager.errorView.actionButton.setTitle(NSLocalizedString("Try Again", comment: ""), for: .normal)
        self.loadingManager.errorView.actionButton.addTarget(self, action: #selector(self.didTapDoneButton), for: .touchUpInside)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateForLayoutOrTraitChange()
    }

    /// We need to override viewDidLayoutSubviews as well as willTransition for any layout based updates
    /// due to the behaviour of PopoverNavigationController
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateForLayoutOrTraitChange()
    }

    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.updateForLayoutOrTraitChange()
        }, completion: nil)
    }

    open func updateForLayoutOrTraitChange() {
        // Update title view if used
        if let navTitles = navTitles {
            setTitleView(title: navTitles.title, subtitle: navTitles.subtitle)
        }
    }

    @objc open func didTapCancelButton(_ button: UIBarButtonItem) {
        // If showing error, allow cancel to go back to editing form
        if loadingManager.state == .error {
            setLoadingState(.loaded)
        } else {
            performClose(submitted: false)
        }
    }

    @objc open func didTapDoneButton(_ button: UIBarButtonItem) {
        var result = performValidation()

        #if DEBUG
        // Disable form validation for developers in a hurry :)
        if true {
            result = .valid
        }
        #endif

        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            AlertQueue.shared.addErrorAlert(message: message)
        case .valid:
            setLoadingState(.loading)
            firstly {
                return performSubmit()
            }.done { [weak self] in
                guard let `self` = self else { return }
                self.setLoadingState(.loaded)
                self.performClose(submitted: true)
            }.catch { [weak self] error in
                guard let `self` = self else { return }
                self.loadingManager.errorView.subtitleLabel.text = error.localizedDescription
                self.setLoadingState(.error)
            }
        }
    }

    /// Update form based on loading state
    open func setLoadingState(_ state: LoadingStateManager.State) {
        loadingManager.state = state

        // Enable cancel if not submitting
        navigationItem.leftBarButtonItem?.isEnabled = state == .loaded || state == .error

        // Enable submit if not submitting and not error
        navigationItem.rightBarButtonItem?.isEnabled = state == .loaded
    }

    open func performValidation() -> FormBuilder.FormValidationResult {
        return builder.validate()
    }

    /// Perform actual submit logic, override in subclass
    open func performSubmit() -> Promise<Void> {
        MPLRequiresConcreteImplementation()
    }

    open func performClose(submitted: Bool) {
        // By default just dismiss the dialog
        dismissAnimated()
    }

}
