//
//  Officer.swift
//  ClientKit
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class Officer: MPOLKitEntity, Identifiable {

    enum CodingKeys: String, CodingKey {
        case givenName
        case surname
        case middleNames
    }

    open var givenName: String?
    open var surname: String?
    open var middleNames: String?

    // TODO: Proper Involvements
    open var involvements: [String] = []
}

public protocol Identifiable {
    var givenName: String? { get }
    var middleNames: String? { get }
    var surname: String? { get }
}

extension Identifiable {

    // Moving this to extension for now as `Initials` doesn't really belong in the model.
    public var initials: String? {
        var initials = ""
        if let givenName = givenName?.ifNotEmpty() {
            initials += givenName[...givenName.startIndex]
        }
        if let surname = surname?.ifNotEmpty() {
            initials += surname[...surname.startIndex]
        }

        return initials.ifNotEmpty()
    }

    public func initialImage() -> UIImage {
        if let initials = initials?.ifNotEmpty() {
            return UIImage.thumbnail(withInitials: initials)
        }
        return UIImage()
    }
}
