//
//  EventSummaryViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import PublicSafetyKit
public class EventSummaryViewController: FormBuilderViewController {

    weak var delegate: EventSummaryViewControllerDelegate?
    var viewModel: EventSummaryViewModel

    public init(viewModel: EventSummaryViewModel, submitButtonIsEnabled: Bool) {
        self.viewModel = viewModel
        super.init()
        title = "Event Summary"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit Event", style: .plain, target: self, action: #selector(submitSelected))
        self.navigationItem.rightBarButtonItem?.isEnabled = submitButtonIsEnabled
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeSelected))
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    public override func construct(builder: FormBuilder) {

        // Add spacing to the bottom of the the collection view
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)

        let event = viewModel.event

        event?.reports.forEach({ (report) in
            if let report = report as? Summarisable {
                report.formItems.forEach({ (item) in
                    builder += item
                })
            }
        })
    }

    @objc func submitSelected(sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.submitEvent(controller: self)
        }
    }

    @objc func closeSelected(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

protocol EventSummaryViewControllerDelegate: class {
    func submitEvent(controller: EventSummaryViewController)
}
