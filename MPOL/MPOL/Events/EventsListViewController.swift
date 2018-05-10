//
//  EventsListViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import PromiseKit
import ClientKit

open class EventsListViewController: FormBuilderViewController, EventsManagerDelegate {

    let viewModel: EventsListViewModel

    required public init(viewModel: EventsListViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.eventsManager.delegate = self
        title = "Events"
        tabBarItem.image = AssetManager.shared.image(forKey: .tabBarEvents)
        tabBarItem.selectedImage = AssetManager.shared.image(forKey: .tabBarEventsSelected)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        loadingManager.noContentView.titleLabel.text = "No Events"
        loadingManager.noContentView.subtitleLabel.text = "You have no Current or Queued Events"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconFolder)
        loadingManager.noContentView.actionButton.setTitle("Create New Event", for: .normal)
        loadingManager.noContentView.actionButton.addTarget(self, action: #selector(createNewEvent), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Event", style: .plain, target: self, action: #selector(createNewEvent))
    }

    open override func viewWillAppear(_ animated: Bool) {
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
            let image = viewModel.image(for: displayable)
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
        let viewController = IncidentSelectViewController()
        viewController.didSelectIncident = { incident in
            self.show(with: incident)
        }

        let navigationController = PopoverNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }

    private func show(_ event: Event? = nil, with incidentType: IncidentType? = nil) {
        guard let event = event ?? viewModel.eventsManager.create(eventType: .blank) else { return }

        viewModel.incidentType = incidentType

        let viewController = EventSplitViewController<EventSubmissionResponse>(viewModel: viewModel.detailsViewModel(for: event))
        viewController.loadingViewBuilder = viewModel.loadingBuilder()
        viewController.delegate = self

        self.show(viewController, sender: self)
    }

    private func updateEmptyState() {
        self.loadingManager.state = (self.viewModel.eventsList?.isEmpty ?? true) ? .noContent : .loaded
    }

    public func eventsManagerDidUpdateEventBucket(_ eventsManager: EventsManager) {
        tabBarItem.badgeValue = viewModel.badgeCountString
    }
}

extension EventsListViewController: EventsSubmissionDelegate {
    public func eventSubmittedFor(eventId: String, response: Any?, error: Error?) {
        viewModel.eventsManager.remove(for: eventId)
        self.reloadForm()
    }
}
