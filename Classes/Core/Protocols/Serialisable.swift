//
//  Serialisable.swift
//
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox
import Wrap

public protocol Serialisable: NSSecureCoding, ModelVersionable, Unboxable { }
