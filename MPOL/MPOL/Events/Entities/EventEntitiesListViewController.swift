//
//  EventEntitiesListViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class EventEntitiesListViewController : FormBuilderViewController {
    
    let viewModel: EventEntitiesListViewModel
    
    public init(viewModel: EventEntitiesListViewModel) {
        self.viewModel = viewModel
        
        super.init()
        
        self.title = "Entities"
        
        sidebarItem.regularTitle = self.title
        sidebarItem.compactTitle = self.title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.list)!
        sidebarItem.color = viewModel.tabColour()
        
        
        //temporary
        loadingManager.state = .noContent
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func construct(builder: FormBuilder) {
        //need to implement, currently will default to "noContent"
        builder.title = self.title
        builder.forceLinearLayout = true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        //text and image for "noContent" state
        loadingManager.noContentView.titleLabel.text = "No Entities Added"
        loadingManager.noContentView.subtitleLabel.text = "Entities added to an incident will appear here"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.dialogAlert)
        
    }
    
}
