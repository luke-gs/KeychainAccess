//
//  EventsListViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 30/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class EventsListViewController: FormBuilderViewController {

    let viewModel: EventListViewModelType

    required public init(viewModel: EventListViewModelType) {
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

        loadingManager.state = (viewModel.eventsList?.isEmpty ?? true) ? .noContent : .loaded
    }

    open override func construct(builder: FormBuilder) {
        builder.title = "Events"
        
        let currentEvents = viewModel.eventsList ?? []
        
        let currentCount = currentEvents.count
        
        // only add the sections if there is content
        guard currentCount > 0 else {
            return
        }
        
        builder += HeaderFormItem(text: "\(currentCount) CURRENT EVENT\(currentCount == 1 ? "S" : "")")
        
        for _ in currentEvents {
            builder += TextFieldFormItem(title: "Dummy text representing a current event")
        }
    }

    @objc private func createNewEvent() {
        guard let event = viewModel.eventsManager.create(eventType: .blank) else { return }
        let viewController = EventSplitViewController(viewModel: viewModel.detailsViewModel(for: event))

        show(viewController, sender: self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        loadingManager.state = (viewModel.eventsList?.isEmpty ?? true) ? .noContent : .loaded
        
        reloadForm()
    }
}

