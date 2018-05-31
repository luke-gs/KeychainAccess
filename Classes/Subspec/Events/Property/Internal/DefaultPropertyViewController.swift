//
//  DefaultPropertyViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

internal protocol AddPropertyDelegate {
    func didTapOnPropertyType()
    func didTapOnPropertySubtype()
}

internal class DefaultPropertyViewController: IntrinsicHeightFormBuilderViewController, EvaluationObserverable {
    var plugins: [FormBuilderPlugin] {
        didSet {
            reloadForm()
        }
    }

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
