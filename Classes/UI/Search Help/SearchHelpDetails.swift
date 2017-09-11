//
//  SearchHelpDetails.swift
//  MPOLKit
//
//  Created by Megan Efron on 11/9/17.
//
//

import UIKit
import Unbox

/*
 SAMPLE JSON FOR SEARCH HELP DETAILS
 --------------------------------------------------------
 {
	"title": "Searching for People",
	"sections": [
         {
             "title": "The default search order",
             "type": "tags",
             "detail": [
                 "Last Name",
                 ",",
                 "Given Name",
                 "Middle Name/s",
                 "DOB/Age Range"
             ]
         },
         {
             "title": "General conditions",
             "type": "text",
             "detail": "Search is NOT case sensetive\nLast name is required\nYou can use partial names or initials for given and middle names"
         },
         {
             "title": "Optional",
             "type": "text",
             "detail": "Given Name, Middle Name 1, Middle Name 2, DOB/Age Range"
         }
	]
 }
 */


/// Item describes content for 'SearchHelpViewController'
open class SearchHelpDetails: Unboxable {
    
    
    // MARK: - Properties
    
    /// The title of the screen
    open var title: String
    
    /// The 'SearchHelpSection' items for the help screen
    open var sections: [SearchHelpSection]
    
    
    // MARK: - Lifecycle
    
    public required init(filename: String, bundle: Bundle) {
        let url = bundle.url(forResource: filename, withExtension: "json")!
        let definition: SearchHelpDetails = try! unbox(data: Data(contentsOf: url))
        self.title = definition.title
        self.sections = definition.sections
    }
    
    public required init(title: String, sections: [SearchHelpSection]) {
        self.title = title
        self.sections = sections
    }
    
    public required init(unboxer: Unboxer) throws {
        title = try unboxer.unbox(key: "title")
        sections = try unboxer.unbox(key: "sections")
    }
}


/// Item describes content for section in `SearchHelpViewController`
open class SearchHelpSection: Unboxable {
    
    
    // MARK: - Properties
    
    /// The title of the section
    open let title: String
    
    /// The detail of the section (standard subtitle or array of strings displayed like tags)
    open let detail: SearchHelpDetail
    
    
    // MARK: - Lifecycle
    
    public required init(title: String, detail: SearchHelpDetail) {
        self.title = title
        self.detail = detail
    }
    
    public required init(unboxer: Unboxer) throws {
        
        // Unbox title
        title = try unboxer.unbox(key: "title")
        
        // Custom unboxing for different detail types
        let type: String = try unboxer.unbox(key: "type")
        if type == "text" {
            let text: String = try unboxer.unbox(key: "detail")
            detail = .text(text)
        } else {
            let tags: [String] = try unboxer.unbox(key: "detail")
            detail = .tags(tags)
        }
    }
}


/// The `SearchHelpSection` detail type that contains relevant content
///
/// - text: A standard string subtitle
/// - tags: A subtitle that looks like an array of tag views
public enum SearchHelpDetail {
    case text(String)
    case tags([String])
}
