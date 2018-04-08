//
//  Identifiable.swift
//  ClientKit
//
//  Created by QHMW64 on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol Identifiable {
    var givenName: String? { get }
    var middleNames: String? { get }
    var familyName: String? { get }
}

extension Identifiable {

    // Moving this to extension for now as `Initials` doesn't really belong in the model.
    public var initials: String? {
        var initials = ""
        if let givenName = givenName?.ifNotEmpty() {
            initials += givenName[...givenName.startIndex]
        }
        if let surname = familyName?.ifNotEmpty() {
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
