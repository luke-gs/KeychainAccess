//
//  PersonDescriptionsViewController.swift
//  Pods
//
//  Created by Gridstone on 6/6/17.
//
//

import UIKit

class PersonDescriptionsViewController: FormCollectionViewController {
    
    private var yearDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "YYYY"
        return formatter
    }
    
    open var descriptions: [PersonDescription]? {
        didSet {
            descriptions?.remove(at: 0)
            guard let descriptions = descriptions else {
                self.groupedDescriptions = nil
                return
            }
            
            var groupedDescriptions: [String:[PersonDescription]] = [:]
            var years: Set<String> = []
            for description in descriptions {
                let year = yearDateFormatter.string(from: description.reportDate!)
                var yearsDescriptions = groupedDescriptions[year] ?? []
                yearsDescriptions.append(description)
                years.insert(year)
                groupedDescriptions[year] = yearsDescriptions
            }
            
            let orderedYears = Array(years).sorted(by: { Int($0)! > Int($1)! })
            self.orderedYears = orderedYears
            self.groupedDescriptions = groupedDescriptions
        }
    }
    
    private var groupedDescriptions: [String: [PersonDescription]]? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    private var orderedYears: [String]?
    
    private var collapsedSections: Set<Int> = []
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = NSLocalizedString("More Descriptions", bundle: .mpolKit, comment: "")
    }
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormValueFieldCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return orderedYears?.count ?? 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let year = orderedYears?[section] else { return 0 }
        return collapsedSections.contains(section) ? 0 : (groupedDescriptions?[year]?.count ?? 0)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            view.text = orderedYears?[indexPath.section]
            view.showsExpandArrow = true
            
            view.tapHandler = { [weak self] (headerView, indexPath) in
                guard let `self` = self else { return }
                
                if self.collapsedSections.remove(indexPath.section) == nil {
                    // This section wasn't in there and didn't remove
                    self.collapsedSections.insert(indexPath.section)
                }
                self.collectionView?.reloadData()
            }

            view.isExpanded = !collapsedSections.contains(indexPath.section)
            return view
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let year = orderedYears![indexPath.section]
        let description = groupedDescriptions![year]![indexPath.row]
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
        cell.imageView.image = nil
        cell.titleLabel.text = DateFormatter.shortDate.string(from: description.reportDate!).ifNotEmpty() ?? "Unknown Date"
        cell.valueLabel.text = description.formatted()
        return cell
    }
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        return layout.columnContentWidth(forColumnCount: 1, inSectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        let description = descriptions![indexPath.row]
        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: DateFormatter.shortDate.string(from: description.reportDate!).ifNotEmpty() ?? "Unknown Date", value: description.formatted(), inWidth: itemWidth, compatibleWith: traitCollection, image: nil)
    }

}
