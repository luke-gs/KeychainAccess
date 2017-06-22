//
//  PersonParser.swift
//  MPOLKit
//
//  Created by Gridstone on 20/6/17.
//

import UIKit

public class PersonParser: QueryParserType {
    
    required public init() { }
    
    public var delimiter: String = ","
    
    public var definitions: [QueryTokenDefinition] {
        
        return [
            QueryTokenDefinition(key: "surname",
                                 required: true,
                                 typeCheck: { (token) in
                                    return true
                                 },
                                 validate: { (token, index, map) in
                                    return index == 0 && token.characters.count > 2 && token.characters.count < 50
                                 }),
            QueryTokenDefinition(key: "givenName",
                                 required: false,
                                 typeCheck: { (token) in
                                    return true
                                 },
                                 validate: { (token, index, map) in
                                    return token.characters.count > 2 && token.characters.count < 50
                                 }),
            QueryTokenDefinition(key: "middleNames",
                                 required: false,
                                 typeCheck: { (token) in
                                    return true
                                 },
                                 validate: { (token, index, map) in
                                    let isGender: Bool = (token == "M" || token == "F" || token == "U") && map["gender"] == nil
                                    return !isGender && token.characters.count < 50
                                 }),
            QueryTokenDefinition(key: "gender",
                                 required: false,
                                 typeCheck: { (token) in
                                    return token == "M" || token == "F" || token == "U"
                                 }),
            QueryTokenDefinition(key: "dateOfBirth",
                                 required: false,
                                 typeCheck: { (token) in
                                    // Date should be in "01/01/1970" or "--/01/1970" or "--/--/1970"
                                    return true
                                 },
                                 validate: { (token, index, map) in
                                    return true
                                 }),
            QueryTokenDefinition(key: "ageGap",
                                 required: false,
                                 typeCheck: { (token) in
                                    // return type that token matches numbers-numbers regex
                                    return true
                                 },
                                 validate: { (token, index, map) in
                                    return true
                                 })
        ]
    }
}
