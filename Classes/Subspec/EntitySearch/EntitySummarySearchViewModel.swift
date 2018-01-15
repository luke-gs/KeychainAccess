//
//  EntitySummarySearchViewModel.swift
//  MPOLKit
//
//  Created by James Aramroongrot on 19/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class EntitySummarySearchViewModel: SearchViewModel {
    
    public let recentViewModel: SearchRecentsViewModel
    
    public let dataSources: [SearchDataSource]
    
    public init(title: String, dataSources: [SearchDataSource], userSession: UserSession = .current, summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default) {
        self.dataSources = dataSources
        self.recentViewModel = EntitySummaryRecentsViewModel(title: title, userSession: userSession, summaryDisplayFormatter: summaryDisplayFormatter)
    }
    
}
