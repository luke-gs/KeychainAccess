//
//  ActionListViewController.swift
//  MPOL
//
//  Created by Rod Brown on 29/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


public protocol ActionListViewModelable: class {

    weak var actionListViewController: UIViewController? { get set }

    func formItems(forEntitiesInCache cache: EntityBucket, in traitCollection: UITraitCollection) -> [FormItem]

}

public class ActionListViewController: FormBuilderViewController {

    public let viewModel: ActionListViewModelable

    public init(viewModel: ActionListViewModelable) {
        self.viewModel = viewModel

        super.init()

        viewModel.actionListViewController = self

        title = NSLocalizedString("Action List", comment: "Title")

        tabBarItem.image = AssetManager.shared.image(forKey: .tabBarActionList)

        loadingManager.noContentView.titleLabel.text = "No Pinned Entities"
        loadingManager.noContentView.subtitleLabel.text = "Any pinned entities will show up here."

        NotificationCenter.default.addObserver(self, selector: #selector(handleRecentlyActionedUpdate(_:)), name: EntityBucket.didUpdateNotificationName, object: UserSession.current.recentlyActioned)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Layout

    public override func construct(builder: FormBuilder) {
        let recentlyActioned = UserSession.current.recentlyActioned
        builder += viewModel.formItems(forEntitiesInCache: recentlyActioned, in: traitCollection)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        formLayout.distribution = .none
        updateLoadingManageState()
    }

    // MARK: - TraitCollection

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let isCompact = traitCollection.horizontalSizeClass == .compact
        if isCompact != (previousTraitCollection?.horizontalSizeClass == .compact) {
            reloadForm()
        }
    }

    // MARK: - Private

    private func updateLoadingManageState() {
        let recentlyActioned = UserSession.current.recentlyActioned
        let numberOfEntities = recentlyActioned.entities.count
        tabBarItem.badgeValue = numberOfEntities > 0 ? "\(numberOfEntities)" : nil
        loadingManager.state = numberOfEntities > 0 ? .loaded : .noContent
    }

    @objc private func handleRecentlyActionedUpdate(_ notification: Notification) {
        reloadForm()
        updateLoadingManageState()
    }

}
