//
//  UICollectionView+DefaultReuse.swift
//  VCom
//
//  Created by Rod Brown on 5/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    public final func register<T: UICollectionViewCell>(_ cellClass: T.Type) where T: DefaultReusable {
        register(cellClass, forCellWithReuseIdentifier: cellClass.defaultReuseIdentifier)
    }
    
    public final func register<T: UICollectionReusableView>(_ viewClass: T.Type, forSupplementaryViewOfKind kind: String) where T: DefaultReusable {
        register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: viewClass.defaultReuseIdentifier)
    }
    
    public final func dequeueReusableCell<T: UICollectionViewCell>(of cellClass: T.Type, for indexPath: IndexPath) -> T where T: DefaultReusable {
        return dequeueReusableCell(withReuseIdentifier: cellClass.defaultReuseIdentifier, for: indexPath) as! T
    }
    
    public final func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind elementKind: String, class viewClass: T.Type, for indexPath: IndexPath) -> T where T: DefaultReusable {
        return dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: viewClass.defaultReuseIdentifier, for: indexPath) as! T
    }
}
