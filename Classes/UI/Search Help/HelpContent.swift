//
//  HelpContent.swift
//  MPOLKit
//
//  Created by Megan Efron on 11/9/17.
//
//

import UIKit
import Unbox


// The type options for a section's detail (see example below: sections -> type)
fileprivate let TextType = "text"
fileprivate let TagsType = "tags"


/*
 SAMPLE JSON FOR HELP CONTENT
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


/// Item describes content for 'HelpViewController'
open class HelpContent: Unboxable {
    
    
    // MARK: - Properties
    
    /// The title of the screen
    open var title: String
    
    /// The 'HelpSection' items for the help screen
    open var sections: [HelpSection]
    
    
    // MARK: - Lifecycle
    
    public required init(filename: String, bundle: Bundle) {
        let url = bundle.url(forResource: filename, withExtension: "json")!
        let content: HelpContent = try! unbox(data: Data(contentsOf: url))
        self.title = content.title
        self.sections = content.sections
    }
    
    public required init(title: String, sections: [HelpSection]) {
        self.title = title
        self.sections = sections
    }
    
    public required init(unboxer: Unboxer) throws {
        title = try unboxer.unbox(key: "title")
        sections = try unboxer.unbox(key: "sections")
    }
}


/// Item describes content for section in `HelpViewController`
open class HelpSection: Unboxable {
    
    
    // MARK: - Properties
    
    /// The title of the section
    open let title: String
    
    /// The detail of the section (standard subtitle or array of strings displayed like tags)
    open let detail: HelpDetail
    
    
    // MARK: - Lifecycle
    
    public required init(title: String, detail: HelpDetail) {
        self.title = title
        self.detail = detail
    }
    
    public required init(unboxer: Unboxer) throws {
        
        // Unbox title
        title = try unboxer.unbox(key: "title")
        
        // Custom unboxing for different detail types
        let type: String = try unboxer.unbox(key: "type")

        switch type {
        case TextType:
            let text: String = try unboxer.unbox(key: "detail")
            detail = .text(text)
        case TagsType:
            let tags: [String] = try unboxer.unbox(key: "detail")
            detail = .tags(tags)
        default:
            fatalError()
        }
    }
}


/// The `HelpSection` detail type that contains relevant content
///
/// - text: A standard string subtitle
/// - tags: An array of tag strings
public enum HelpDetail {
    case text(String)
    case tags([String])
}
