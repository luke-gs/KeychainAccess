//
//  MPOLKitEntity.swift
//  MPOLKit
//
//  Created by Herli Halim on 31/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

open class MPOLKitEntity: NSObject, Serialisable, MPOLKitEntityProtocol {
    
    open class var serverTypeRepresentation: String {
        MPLRequiresConcreteImplementation()
    }

    open let id: String

    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id
    }
    
    public init(id: String = UUID().uuidString) {
        self.id = id
    }

    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String? else {
            return nil
        }
        self.id = id
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: CodingKey.id.rawValue)
    }

    open static var supportsSecureCoding: Bool {
        return true
    }

    open func isEssentiallyTheSameAs(otherEntity: MPOLKitEntityProtocol) -> Bool {
        return type(of: self) == type(of: otherEntity) && id == otherEntity.id
    }
}

public protocol MPOLKitEntityProtocol: Unboxable {
    var id: String { get }
    static var serverTypeRepresentation: String { get }
    func isEssentiallyTheSameAs(otherEntity: MPOLKitEntityProtocol) -> Bool
}

private enum CodingKey: String {
    case id
}

func ==(lhs: MPOLKitEntity, rhs: MPOLKitEntity) -> Bool {
    return lhs.id == rhs.id
}
