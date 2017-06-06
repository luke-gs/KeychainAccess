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
                self.sections = []
                return
            }
            
            var sectionsMap: [Int: [PersonDescription]] = [:]
            for description in descriptions {
                // mapping description to report date's year
                let year = description.reportDate == nil ? 0 : Int(yearDateFormatter.string(from: description.reportDate!))!
                var yearsDescriptions = sectionsMap[year] ?? []
                yearsDescriptions.append(description)
                sectionsMap[year] = yearsDescriptions
            }
            
            // add each years descriptions to sections array in order of year
            var sections: [(String, [PersonDescription])] = []
            for year in sectionsMap.keys.sorted(by: { $0 > $1 }) {
                if year == 0 {
                    sections.append(("Unknown Year", sectionsMap[year]!))
                } else {
                    sections.append((String(year), sectionsMap[year]!))
                }
            }
            self.sections = sections
        }
    }
    
    private var sections: [(year: String, descriptions: [PersonDescription])] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
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
        return sections.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collapsedSections.contains(section) ? 0 : sections[section].descriptions.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            view.text = sections[indexPath.section].year
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
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
        
        let description = sections[indexPath.section].descriptions[indexPath.row]
        if let reportDate = description.reportDate {
            cell.titleLabel.text = DateFormatter.shortDate.string(from: reportDate)
        } else {
            cell.titleLabel.text = nil
        }
        cell.valueLabel.text = description.formatted()
        cell.imageView.image = nil
        
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
        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: description.reportDate == nil ? nil : "Unknown Date", value: description.formatted(), inWidth: itemWidth, compatibleWith: traitCollection, image: nil)
    }

}
