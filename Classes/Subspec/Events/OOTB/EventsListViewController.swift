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
    
    let currentEventIcon: UIImage

    required public init(viewModel: EventListViewModelType) {
        self.viewModel = viewModel
        let size = CGSize(width: 48, height: 48)
        let circle = UIImage.circle(diameter: size.width, color: .orangeRed)
        let icon = AssetManager.shared.image(forKey: .event)!
        
        // compose icon and coloured circle
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        circle.draw(at: CGPoint(x: 0, y: 0))
        icon.draw(at: CGPoint(x: (size.width - icon.size.width) / 2, y: (size.height - icon.size.height) / 2))
        currentEventIcon = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
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
        builder.forceLinearLayout = true
        
        guard let eventsList = viewModel.eventsList else {
            return
        }
        
        builder += HeaderFormItem(text: "\(eventsList.count) CURRENT EVENT\(eventsList.count == 1 ? "" : "S")")
        
        builder += eventsList.map { displayable in
            let title = displayable.title ?? "Blank"
            let subtitle = displayable.subtitle ?? "No description available"
            let image = displayable.icon?.image ?? currentEventIcon
            return SubtitleFormItem(title: title, subtitle: subtitle, image: image)
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

