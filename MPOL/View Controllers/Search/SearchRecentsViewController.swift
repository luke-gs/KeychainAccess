//
//  SearchRecentsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 4/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import Unbox

private let maxRecentViewedCount = 6

class SearchRecentsViewController: FormCollectionViewController {
    
    weak var delegate: SearchRecentsViewControllerDelegate?
    
    var recentSearches: [SearchRequest] = [] {
        didSet {
            if traitCollection.horizontalSizeClass != .compact || showsRecentSearchesWhenCompact {
                collectionView?.reloadData()
            }
        }
    }
    
    // All this is work in progress.👇
    
    @objc dynamic var isShowingNavBarExtension: Bool = false {
        didSet {
            compactNavBarExtension?.alpha = isShowingNavBarExtension ? 1.0 : 0.0
        }
    }
    
    private var compactNavBarExtension: NavigationBarExtension?
    private var compactSegmentedControl: UISegmentedControl?
    
    private var showsRecentSearchesWhenCompact: Bool = false {
        didSet {
            if showsRecentSearchesWhenCompact != oldValue && traitCollection.horizontalSizeClass == .compact {
                collectionView?.reloadData()
            }
        }
    }
    
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        formLayout.wantsOptimizedResizeAnimation = false
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let view = self.view, let collectionView = self.collectionView else { return }
        
        let segmentedControl = UISegmentedControl(items: [NSLocalizedString("Recently Viewed", comment: ""), NSLocalizedString("Recent Searches", comment: "")])
        segmentedControl.selectedSegmentIndex = showsRecentSearchesWhenCompact ? 1 : 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueDidChange(_:)), for: .valueChanged)
        
        let navBarExtension = NavigationBarExtension(frame: .zero)
        navBarExtension.translatesAutoresizingMaskIntoConstraints = false
        navBarExtension.contentView = segmentedControl
        navBarExtension.alpha = isShowingNavBarExtension ? 1.0 : 0.0
        view.addSubview(navBarExtension)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: segmentedControl, attribute: .width, relatedBy: .equal, toItem: navBarExtension, attribute: .width, constant: -32.0),
            NSLayoutConstraint(item: segmentedControl, attribute: .top, relatedBy: .equal, toItem: navBarExtension, attribute: .top),
            NSLayoutConstraint(item: segmentedControl, attribute: .bottom, relatedBy: .equal, toItem: navBarExtension, attribute: .bottom, constant: -17.0),
            NSLayoutConstraint(item: navBarExtension, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading),
            NSLayoutConstraint(item: navBarExtension, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing),
            NSLayoutConstraint(item: navBarExtension, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom),
        ])
        
        compactSegmentedControl = segmentedControl
        compactNavBarExtension = navBarExtension
        
        collectionView.register(EntityCollectionViewCell.self)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(RecentEntitiesBackgroundView.self,          forSupplementaryViewOfKind: collectionElementKindSectionBackground)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let horizontallyCompact = traitCollection.horizontalSizeClass == .compact
        if horizontallyCompact != ((previousTraitCollection?.horizontalSizeClass ?? .unspecified) == .compact) {
            collectionView?.reloadData()
            isShowingNavBarExtension = horizontallyCompact
        }
    }
    
    open override func viewDidLayoutSubviews() {
        guard let scrollView = self.collectionView, let insetManager = self.collectionViewInsetManager else { return }
        
        var contentOffset = scrollView.contentOffset
        
        var insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        if traitCollection.horizontalSizeClass == .compact {
            insets.top += (compactNavBarExtension?.frame.height ?? 0.0)
        }
        
        let oldContentInset = insetManager.standardContentInset
        insetManager.standardContentInset   = insets
        insetManager.standardIndicatorInset = insets
        
        // If the scroll view currently doesn't have any user interaction, adjust its content
        // to keep the content onscreen.
        if scrollView.isTracking || scrollView.isDecelerating { return }
        
        contentOffset.y -= (insets.top - oldContentInset.top)
        if contentOffset.y < insets.top * -1.0 {
            contentOffset.y = insets.top * -1.0
        }
        
        scrollView.contentOffset = contentOffset
    }
    
    
    // MARK: - UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return traitCollection.horizontalSizeClass == .compact ? 1 : 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let isRecentlySearched: Bool
        if traitCollection.horizontalSizeClass == .compact {
            isRecentlySearched = self.showsRecentSearchesWhenCompact
        } else {
            isRecentlySearched = section != 0
        }
        return isRecentlySearched ? recentSearches.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let isRecentlySearched: Bool
            if traitCollection.horizontalSizeClass == .compact {
                isRecentlySearched = self.showsRecentSearchesWhenCompact
            } else {
                isRecentlySearched = indexPath.section != 0
            }
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            if isRecentlySearched {
                header.text = NSLocalizedString("RECENTLY SEARCHED", comment: "")
            } else {
                header.text = NSLocalizedString("RECENTLY VIEWED", comment: "")
            }
            return header
        case collectionElementKindSectionBackground:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: RecentEntitiesBackgroundView.self, for: indexPath)
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let isRecentlySearched: Bool
        if traitCollection.horizontalSizeClass == .compact {
            isRecentlySearched = self.showsRecentSearchesWhenCompact
        } else {
            isRecentlySearched = indexPath.section != 0
        }
        
        if isRecentlySearched {
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            let request = recentSearches[indexPath.item]
            cell.titleLabel.text    = request.searchText?.ifNotEmpty() ?? NSLocalizedString("(No Search Term)", comment: "")
            cell.subtitleLabel.text = request.localizedDescription
            cell.accessoryView      = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
            cell.highlightStyle     = .fade
            cell.imageView.image    = summaryIcon(for: request)
            cell.preferredLabelSeparation = 2.0
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
            let person = Person()
            person.initials = "JC"
            cell.style              = .detail
            cell.titleLabel.text    = "Citizen, John R."
            cell.subtitleLabel.text = "08/05/1987 (29 Male)"
            cell.detailLabel.text   = "Southbank VIC 3006"
            cell.thumbnailView.configure(for: person, size: .medium)
            cell.thumbnailView.borderColor = (3 as Alert.Level).color
            cell.alertColor         = (3 as Alert.Level).color
            cell.badgeCount         = 9
            cell.highlightStyle     = .fade
            cell.sourceLabel.text   = "DS1"
            return cell
        }
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        
        let theme = Theme.current
        if indexPath.section == 0 && traitCollection.horizontalSizeClass != .compact && theme.isDark == false,
            let header = view as? CollectionViewFormExpandingHeaderView {
            header.separatorColor = theme.colors[.AlternateSeparator]
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if traitCollection.horizontalSizeClass != .compact, let entityCell = cell as? EntityCollectionViewCell {
            let theme = Theme.current
            if theme.isDark {
                entityCell.subtitleLabel.textColor = primaryTextColor
            } else {
                let primaryColor = theme.colors[.AlternatePrimaryText]
                entityCell.titleLabel.textColor    = primaryColor
                entityCell.subtitleLabel.textColor = primaryColor
                entityCell.detailLabel.textColor   = theme.colors[.AlternateSecondaryText]
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0 where traitCollection.horizontalSizeClass != .compact:
            // TEMP
            let bundle = Bundle(for: Person.self)
            let url = bundle.url(forResource: "Person_25625aa4-3394-48e2-8dbc-2387498e16b0", withExtension: "json", subdirectory: "Mock JSONs")!
            let data = try! Data(contentsOf: url)
            let person: Person = try! unbox(data: data)
            
            delegate?.searchRecentsController(self, didSelectRecentEntity: person)
            break
        default:
            delegate?.searchRecentsController(self, didSelectRecentSearch: recentSearches[indexPath.item])
        }
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout methods
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int, givenSectionWidth width: CGFloat) -> UIEdgeInsets {
        var inset = super.collectionView(collectionView, layout: layout, insetForSection: section, givenSectionWidth: width)
        
        if section == 0 && traitCollection.horizontalSizeClass != .compact {
            inset.top    = 10.0
            inset.bottom = 10.0
        }
        
        return inset
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        switch indexPath.section {
        case 0 where traitCollection.horizontalSizeClass != .compact:
            return layout.columnContentWidth(forMinimumItemContentWidth: EntityCollectionViewCell.minimumContentWidth(forStyle: .detail), sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets)
        default:
            return sectionWidth
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        
        if traitCollection.horizontalSizeClass == .compact && showsRecentSearchesWhenCompact || indexPath.section == 1 {
            let recentSearch = recentSearches[indexPath.item]
            
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: recentSearch.localizedTitle, subtitle: recentSearch.localizedDescription, inWidth: itemWidth, compatibleWith: traitCollection, image: summaryIcon(for: recentSearch))
        } else {
            return EntityCollectionViewCell.minimumContentHeight(forStyle: .detail, compatibleWith: traitCollection)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, wantsBackgroundInSection section: Int) -> Bool {
        return section == 0 && traitCollection.horizontalSizeClass != .compact
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumHeightForBackgroundInSection section: Int, givenSectionWidth sectionWidth: CGFloat) -> CGFloat {
        return section == 0 && traitCollection.horizontalSizeClass != .compact ? 310.0 : 0.0
    }
    
    
    // MARK: - Private methods
    
    private func summaryIcon(for searchRequest: SearchRequest) -> UIImage? {
        switch searchRequest {
        case _ as PersonSearchRequest:
            return .personOutline
        case _ as VehicleSearchRequest:
            return .carOutline
        case _ as OrganizationSearchRequest:
            return .buildingOutline
        default:
            return nil
        }
    }
    
    @objc private func segmentedControlValueDidChange(_ control: UISegmentedControl) {
        if control == compactSegmentedControl {
            showsRecentSearchesWhenCompact = control.selectedSegmentIndex != 0
        }
    }
    
}


protocol SearchRecentsViewControllerDelegate: class {
    
    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentSearch recentSearch: SearchRequest)
    
    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentEntity recentEntity: Entity)
    
}


private class RecentEntitiesBackgroundView: UICollectionReusableView, DefaultReusable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "RecentContactsBanner"))
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
    }
    
}

