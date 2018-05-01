//
//  EventsListViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 30/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class EventsListViewController: FormBuilderViewController {

    let viewModel: DemoListViewModel

    required public init(viewModel: DemoListViewModel) {
        self.viewModel = viewModel

        super.init()
        title = "Events"
        tabBarItem.image = AssetManager.shared.image(forKey: .tabBarEvents)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        loadingManager.noContentView.titleLabel.text = "No events"
        loadingManager.noContentView.subtitleLabel.text = "There are currently no active or queued events"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconFolder)
        loadingManager.noContentView.actionButton.setTitle("Create new event", for: .normal)
        loadingManager.noContentView.actionButton.addTarget(self, action: #selector(createNewEvent), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New event", style: .plain, target: self, action: #selector(createNewEvent))
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateEmptyState()
        reloadForm()
    }

    open override func construct(builder: FormBuilder) {
        builder.title = "Events"
        builder.forceLinearLayout = true
        
        guard let eventsList = viewModel.eventsList else { return }
        
        builder += HeaderFormItem(text: "\(eventsList.count) CURRENT EVENT\(eventsList.count == 1 ? "" : "S")")
        
        builder += eventsList.map { displayable in
            let title = displayable.title ?? "Blank"
            let subtitle = displayable.subtitle ?? "No description available"
            let image = (displayable.icon ?? AssetManager.shared.image(forKey: .event)!).surroundWithCircle(diameter: 48, color: .orangeRed)
            let editActions = [CollectionViewFormEditAction(title: "Delete", color: .orangeRed, handler: { cell, indexPath in
                self.viewModel.eventsManager.remove(for: eventsList[indexPath.row].eventId)
                self.updateEmptyState()
                self.reloadForm()
            })]
            return SubtitleFormItem(title: title, subtitle: subtitle, image: image)
                .editActions(editActions)
                .accessory(ItemAccessory.disclosure)
                .onSelection ({ cell in
                    guard let event = self.viewModel.event(for: displayable) else { return }
                    self.show(event)
                })
        }
    }

    @objc private func createNewEvent() {
        self.show()
    }

    private func show(_ event: Event? = nil, with incidentType: IncidentType? = nil) {
        guard let event = event ?? viewModel.eventsManager.create(eventType: .blank) else { return }
        let viewController = EventSplitViewController<Void>(viewModel: viewModel.detailsViewModel(for: event))
        self.show(viewController, sender: self)
    }

    private func updateEmptyState() {
        self.loadingManager.state = (self.viewModel.eventsList?.isEmpty ?? true) ? .noContent : .loaded
    }
}

