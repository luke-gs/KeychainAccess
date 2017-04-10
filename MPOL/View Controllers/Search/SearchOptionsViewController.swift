//
//  SearchOptionsViewController.swift
//  Pods
//
//  Created by Valery Shorinov on 31/3/17.
//
//

import UIKit
import MPOLKit

fileprivate var kvoContext = 1

class SearchOptionsViewController: FormCollectionViewController, SearchCollectionViewCellDelegate {
    
    var searchSources : [SearchSource] = []
    //private weak var searchCollectionViewCell : SearchCollectionViewCell?
    
    public init(items : [SearchSource]? = nil) {
        
        searchSources = items ?? [SearchSource(title: "Person",      sourceType: .text, sourceEndpoint: "PersonEndpoint"),
                                  SearchSource(title: "Vehicle",     sourceType: .text, sourceEndpoint: "VehicleEndpoint"),
                                  SearchSource(title: "Organistion", sourceType: .text, sourceEndpoint: "OrganisationEndpoint"),
                                  SearchSource(title: "Location",    sourceType: .map,  sourceEndpoint: "LocationEndpoint")]
        super.init()
    }
    
    deinit {
        collectionView?.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(SearchCollectionViewCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.alwaysBounceVertical = false
        
        collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        collectionView?.endEditing(true)
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: - Editing
    
    func beginEditingSearchField() {
        if let searchCell = collectionView?.cellForItem(at: IndexPath(item: 0, section: 0)) as? SearchCollectionViewCell {
            searchCell.searchTextField.becomeFirstResponder()
        }
    }
    
    
    // MARK: - KVO
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if object is UICollectionView {
                if let contentSize = self.collectionView?.contentSize {
                    self.preferredContentSize = contentSize
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    
    // MARK: - CollectionView Methods
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader && indexPath.section == 1 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            header.showsExpandArrow = false
            header.tapHandler       = nil
            header.text = "FILTER SEARCH"
            return header
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 && indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(of: SearchCollectionViewCell.self, for: indexPath)
            
            cell.searchSources = self.searchSources
            cell.searchCollectionViewCellDelegate = self
            
            return cell
        } else if indexPath.section == 1 {
            
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    // MARK: - CollectionView Delegates
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
//        if let segmentationCell = cell as? SearchCollectionViewCell {
//            
//        }
    }
    
    // MARK: - CollectionViewDelegate MPOLLayout Methods
    
    public func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        return 0.0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        
        return section == 0 ? 0.0 : CollectionViewFormExpandingHeaderView.minimumHeight
        
        //        return super.collectionView(collectionView, layout: layout, heightForHeaderInSection: section, givenSectionWidth: width)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        if indexPath.section == 0 && indexPath.item == 0 {
            return SearchCollectionViewCell.cellHeight()
        }
        
        return super.collectionView(collectionView, layout: layout, minimumContentHeightForItemAt: indexPath, givenItemContentWidth: itemWidth)
    }
    
    
    // MARK: - SearchCollectionViewCell Delegates
    
    public func searchCollectionViewCell(_ cell: SearchCollectionViewCell, didChangeText text: String?) {

    }
    
    public func searchCollectionViewCell(_ cell: SearchCollectionViewCell, didSelectSegmentAt index: Int) {
        // TODO: Change filters
    }
}

public enum SearchSourceType {
    case text
    case map
}

public struct SearchSource {
    
    public var title:  String
    public var sourceType:  SearchSourceType?
    public var sourceEndpoint : String
    //TODO Filters
    
    public init(title: String, sourceType: SearchSourceType?, sourceEndpoint: String) {
        self.title  = title
        self.sourceType  = sourceType
        self.sourceEndpoint = sourceEndpoint
    }
}
