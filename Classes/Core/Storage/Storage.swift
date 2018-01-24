//
//  Storage.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

class blahblah: Codable {

}

internal struct StorageItem<T: Codable>: Codable {
    /// A unique key to identify this item
    let key: String

    /// The object to be stored
    let object: T

    /// A flag to categorise this item, usually to mark its retention policy
    let flag: String?

    // MARK: - Coding

    enum CodingKeys: String, CodingKey {
        case key
        case object
        case flag
    }

    init(from decoder: Decoder) throws {
        var anobject: T = ""
        var anflag: String? = ""
        var ankey: String = ""
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
//            self.object = try values.decode(Codable, forKey: CodingKeys.object)
            ankey = try values.decode(String.self, forKey: CodingKeys.key)
            anobject = try values.decode(T.self, forKey: CodingKeys.object)
        } catch {
//            self.object = ""
        }

        self.flag = anflag
        self.object = anobject
        self.key = ankey
    }

    func encode(to encoder: Encoder) throws {
        try object.encode(to: encoder)
    }
}

internal class StorageWE {
    let path: URL

    init (path: String) {
        self.path = URL(fileURLWithPath: path)
    }

    func store<T: Codable>(item: StorageItem<T>) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(item)
    }


}
