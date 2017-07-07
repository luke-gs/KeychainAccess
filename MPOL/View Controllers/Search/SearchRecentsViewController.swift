//
//  SearchRecentsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 4/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit
import Unbox

private let maxRecentViewedCount = 6

class SearchRecentsViewController: FormCollectionViewController {
    
    weak var delegate: SearchRecentsViewControllerDelegate?
    
    var recentlyViewed: [Entity] = [] {
        didSet {
            hasContent = recentlyViewed.isEmpty == false || recentlySearched.isEmpty == false
            
            if traitCollection.horizontalSizeClass == .compact {
                if showsRecentSearchesWhenCompact == false {
                    collectionView?.reloadSections(IndexSet(integer: 0))
                }
            } else if let headerView = collectionView?.supplementaryView(forElementKind: collectionElementKindGlobalHeader, at: IndexPath(item: 0, section: 0)) as? RecentEntitiesHeaderView {
                headerView.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    var recentlySearched: [SearchRequest] = [] {
        didSet {
            hasContent = recentlyViewed.isEmpty == false || recentlySearched.isEmpty == false
            
            if traitCollection.horizontalSizeClass != .compact || showsRecentSearchesWhenCompact {
                collectionView?.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    // All this is work in progress.👇
    
    @objc dynamic var isShowingNavBarExtension: Bool = false {
        didSet {
            compactNavBarExtension?.alpha = isShowingNavBarExtension ? 1.0 : 0.0
        }
    }
    
    
    private var hasContent: Bool = false {
        didSet {
            if hasContent == oldValue { return }
            
            collectionView?.isHidden = hasContent == false
            noContentScrollView?.isHidden = hasContent
        }
    }
    
    private var compactNavBarExtension: NavigationBarExtension?
    private var compactSegmentedControl: UISegmentedControl?
    
    private var showsRecentSearchesWhenCompact: Bool = true {
        didSet {
            if showsRecentSearchesWhenCompact != oldValue && traitCollection.horizontalSizeClass == .compact {
                collectionView?.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    private var noContentScrollView: UIScrollView?
    
    private var noContentScrollViewInsetManager: ScrollViewInsetManager?
    
    private var noContentLabel: UILabel?
    
    private var noContentRegularWidthConstraint: NSLayoutConstraint?
    
    @available(*, deprecated: 11.0, message: "Use UIView.safeAreaLayoutGuide in iOS 11 and later.")
    private var visibleAreaTopLayoutConstraint: NSLayoutConstraint?
    
    @available(*, deprecated: 11.0, message: "Use UIView.safeAreaLayoutGuide in iOS 11 and later.")
    private var visibleAreaBottomLayoutConstraint: NSLayoutConstraint?
    
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        formLayout.pinsGlobalHeaderWhenBouncing = true
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        let noContentLabel = UILabel(frame: .zero)
        self.noContentLabel = noContentLabel
        
        super.viewDidLoad()
        
        guard let view = self.view, let collectionView = self.collectionView else { return }
        
        let segmentedControl = UISegmentedControl(items: [NSLocalizedString("Recent Searches", comment: ""), NSLocalizedString("Recent Entities", comment: "")])
        segmentedControl.selectedSegmentIndex = showsRecentSearchesWhenCompact ? 0 : 1
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueDidChange(_:)), for: .valueChanged)
        
        let navBarExtension = NavigationBarExtension(frame: .zero)
        navBarExtension.translatesAutoresizingMaskIntoConstraints = false
        navBarExtension.contentView = segmentedControl
        navBarExtension.alpha = isShowingNavBarExtension ? 1.0 : 0.0
        view.addSubview(navBarExtension)
        
        compactSegmentedControl = segmentedControl
        compactNavBarExtension = navBarExtension
        
        collectionView.register(EntityCollectionViewCell.self)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(RecentEntitiesHeaderView.self, forSupplementaryViewOfKind: collectionElementKindGlobalHeader)
        
        // Setup the no content view.
        
        let noContentScrollView = UIScrollView(frame: view.bounds)
        noContentScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        noContentScrollView.alwaysBounceVertical = true
        view.insertSubview(noContentScrollView, belowSubview: collectionView)
        
        noContentScrollViewInsetManager = ScrollViewInsetManager(scrollView: noContentScrollView)
        self.noContentScrollView = noContentScrollView
        
        // TODO: Replace with scrollView.contentLayoutGuide on iOS 11
        let scrollContentView = UIView()
        scrollContentView.isHidden = true
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        noContentScrollView.addSubview(scrollContentView)
        
        let noContentImageView = UIImageView(image: nil) // TODO: Get artwork for no content button
        
        noContentLabel.text = NSLocalizedString("You don't have any recently viewed entities or recent searches right now.", comment: "")
        noContentLabel.font = .preferredFont(forTextStyle: .headline)
        noContentLabel.adjustsFontForContentSizeCategory = true
        noContentLabel.numberOfLines = 0
        noContentLabel.textAlignment = .center
        
        let newSearchButton = UIButton(type: .custom)
        newSearchButton.titleLabel?.font = .systemFont(ofSize: 15.0, weight: UIFontWeightSemibold)
        newSearchButton.setTitle(NSLocalizedString("New Search", comment: ""), for: .normal)
        newSearchButton.setTitleColor(.white, for: .normal)
        newSearchButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)
        newSearchButton.setBackgroundImage(UIImage.resizableRoundedImage(cornerRadius: 4.0, borderWidth: 0.0, borderColor: nil, fillColor: .red).withRenderingMode(.alwaysTemplate), for: .normal)
        newSearchButton.addTarget(self, action: #selector(newSearchButtonDidSelect(_:)), for: .primaryActionTriggered)
        
        let stackView = UIStackView(arrangedSubviews: [noContentImageView, noContentLabel, newSearchButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20.0
        noContentScrollView.addSubview(stackView)
        
        let visibleAreaGuide = UILayoutGuide()
        view.addLayoutGuide(visibleAreaGuide)
        
        visibleAreaTopLayoutConstraint = visibleAreaGuide.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
        visibleAreaBottomLayoutConstraint = visibleAreaGuide.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        noContentRegularWidthConstraint = stackView.widthAnchor.constraint(equalTo: scrollContentView.readableContentGuide.widthAnchor, multiplier: 0.6)
        
        NSLayoutConstraint.activate([
            segmentedControl.widthAnchor.constraint(equalTo: navBarExtension.widthAnchor, constant: -32.0),
            segmentedControl.topAnchor.constraint(equalTo: navBarExtension.topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: navBarExtension.bottomAnchor, constant: -17.0),
            
            navBarExtension.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarExtension.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBarExtension.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            
            visibleAreaTopLayoutConstraint!,
            visibleAreaBottomLayoutConstraint!,
            visibleAreaGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visibleAreaGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollContentView.leadingAnchor.constraint(equalTo: noContentScrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: noContentScrollView.trailingAnchor),
            scrollContentView.topAnchor.constraint(equalTo: noContentScrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: noContentScrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: visibleAreaGuide.widthAnchor),
            scrollContentView.heightAnchor.constraint(greaterThanOrEqualTo: visibleAreaGuide.heightAnchor),
            
            stackView.topAnchor.constraint(greaterThanOrEqualTo: scrollContentView.topAnchor, constant: 30.0),
            stackView.centerYAnchor.constraint(equalTo: scrollContentView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: scrollContentView.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: scrollContentView.readableContentGuide.trailingAnchor),
            stackView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor).withPriority(UILayoutPriorityDefaultHigh),
        ])
        
        if traitCollection.horizontalSizeClass == .regular {
            noContentRegularWidthConstraint?.isActive = true
        }
        
        collectionView.isHidden = hasContent == false
        noContentScrollView.isHidden = hasContent
    }
    
    override func applyCurrentTheme() {
        super.applyCurrentTheme()
        noContentLabel?.textColor = secondaryTextColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let horizontallyCompact = traitCollection.horizontalSizeClass == .compact
        if horizontallyCompact != ((previousTraitCollection?.horizontalSizeClass ?? .unspecified) == .compact) {
            collectionView?.reloadData()
            isShowingNavBarExtension = horizontallyCompact
            noContentRegularWidthConstraint?.isActive = horizontallyCompact == false
        }
    }
    
    open override func viewDidLayoutSubviews() {
        guard let scrollView = self.collectionView, let insetManager = self.collectionViewInsetManager else { return }
        
        var contentOffset = scrollView.contentOffset
        
        var insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        if isShowingNavBarExtension {
            let extensionHeight = compactNavBarExtension?.frame.height ?? 0.0
            insets.top += extensionHeight
            visibleAreaTopLayoutConstraint?.constant = extensionHeight
        } else {
            visibleAreaTopLayoutConstraint?.constant = 0.0
        }
        
        // TODO: handle status tab bar inset when that PR is accepted.
        
        let oldContentInset = insetManager.standardContentInset
        insetManager.standardContentInset   = insets
        insetManager.standardIndicatorInset = insets
        
        noContentScrollViewInsetManager?.standardContentInset   = insets
        noContentScrollViewInsetManager?.standardIndicatorInset = insets
        
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let isRecentSearches: Bool
        if traitCollection.horizontalSizeClass == .compact {
            isRecentSearches = showsRecentSearchesWhenCompact
        } else {
            isRecentSearches = collectionView == self.collectionView
        }
        
        return isRecentSearches ? recentlySearched.count : recentlyViewed.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let isRecentSearches: Bool
            if traitCollection.horizontalSizeClass == .compact {
                isRecentSearches = showsRecentSearchesWhenCompact
            } else {
                isRecentSearches = collectionView == self.collectionView
            }
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            if isRecentSearches {
                header.text = NSLocalizedString("RECENTLY SEARCHED", comment: "")
            } else {
                header.text = NSLocalizedString("RECENTLY VIEWED", comment: "")
            }
            return header
        case collectionElementKindGlobalHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: RecentEntitiesHeaderView.self, for: indexPath)
            headerView.collectionView.dataSource = self
            headerView.collectionView.delegate = self
            headerView.collectionView.reloadData()
            return headerView
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let isRecentlySearched: Bool
        if traitCollection.horizontalSizeClass == .compact {
            isRecentlySearched = showsRecentSearchesWhenCompact
        } else {
            isRecentlySearched = collectionView == self.collectionView
        }
        
        if isRecentlySearched {
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            let request = recentlySearched[indexPath.item]
            cell.titleLabel.text    = request.searchText?.ifNotEmpty() ?? NSLocalizedString("(No Search Term)", comment: "")
            cell.subtitleLabel.text = request.localizedDescription
            cell.accessoryView      = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
            cell.highlightStyle     = .fade
            cell.imageView.image    = summaryIcon(for: request)
            cell.preferredLabelSeparation = 2.0
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
            let person = recentlyViewed[indexPath.item]
            cell.style              = .detail
            cell.highlightStyle     = .fade
            cell.titleLabel.text    = person.summary
            cell.subtitleLabel.text = person.summaryDetail1
            cell.detailLabel.text   = person.summaryDetail2
            cell.thumbnailView.configure(for: person, size: .medium)
            cell.sourceLabel.text   = person.source?.localizedBadgeTitle
            cell.badgeCount         = person.actionCount
            cell.alertColor         = person.alertLevel?.color
            return cell
        }
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        
        let theme = Theme.current
        if traitCollection.horizontalSizeClass != .compact && theme.isDark == false && collectionView != self.collectionView,
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
        
        let isRecentSearches: Bool
        if traitCollection.horizontalSizeClass == .compact {
            isRecentSearches = showsRecentSearchesWhenCompact
        } else {
            isRecentSearches = collectionView == self.collectionView
        }
        
        if isRecentSearches {
            delegate?.searchRecentsController(self, didSelectRecentSearch: recentlySearched[indexPath.item])
        } else {
            delegate?.searchRecentsController(self, didSelectRecentEntity: recentlyViewed[indexPath.item])
        }
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout methods
    
    func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        if collectionView != self.collectionView { return 0.0 }
        
        let traitCollection = self.traitCollection
        if traitCollection.horizontalSizeClass == .compact { return 0.0 }
        
        let visibleRegion = collectionView.bounds.insetBy(collectionView.contentInset)
        let itemsStackedVertically = visibleRegion.width >= visibleRegion.height ? 2 : 3
        
        let itemInsets = layout.itemLayoutMargins
        let itemHeight = EntityCollectionViewCell.minimumContentHeight(forStyle: .detail, compatibleWith: traitCollection) + itemInsets.top + itemInsets.bottom
        
        let height = itemHeight * CGFloat(itemsStackedVertically) + CollectionViewFormExpandingHeaderView.minimumHeight + 20.0 // 20 is the insets you see below.
        
        return height
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        if traitCollection.horizontalSizeClass == .compact { return 0.0 }
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int) -> UIEdgeInsets {
        var inset = super.collectionView(collectionView, layout: layout, insetForSection: section)
        
        if collectionView != self.collectionView {
            inset.top    = 10.0
            inset.bottom = 10.0
        }
        
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        if collectionView != self.collectionView {
            return layout.columnContentWidth(forMinimumItemContentWidth: EntityCollectionViewCell.minimumContentWidth(forStyle: .detail), sectionEdgeInsets: sectionEdgeInsets)
        }
        return collectionView.bounds.width
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        
        let isRecentlySearched: Bool
        if traitCollection.horizontalSizeClass == .compact {
            isRecentlySearched = showsRecentSearchesWhenCompact
        } else {
            isRecentlySearched = collectionView == self.collectionView
        }
        
        if isRecentlySearched {
            let recentSearch = recentlySearched[indexPath.item]
            
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: recentSearch.localizedTitle, subtitle: recentSearch.localizedDescription, inWidth: itemWidth, compatibleWith: traitCollection, image: summaryIcon(for: recentSearch))
        } else {
            return EntityCollectionViewCell.minimumContentHeight(forStyle: .detail, compatibleWith: traitCollection)
        }
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
            showsRecentSearchesWhenCompact = control.selectedSegmentIndex == 0
        }
    }
    
    @objc private func newSearchButtonDidSelect(_ button: UIButton) {
        delegate?.searchRecentsControllerDidSelectNewSearch(self)
    }
}


protocol SearchRecentsViewControllerDelegate: class {
    
    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentSearch recentSearch: SearchRequest)
    
    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentEntity recentEntity: Entity)
    
    func searchRecentsControllerDidSelectNewSearch(_ controller: SearchRecentsViewController)
    
}


private class RecentEntitiesHeaderView: UICollectionReusableView, DefaultReusable {
    
    let formLayout: CollectionViewFormLayout
    let collectionView: UICollectionView
    
    override init(frame: CGRect) {
        formLayout = CollectionViewFormLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: formLayout)
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        formLayout = CollectionViewFormLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: formLayout)
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
        
        collectionView.register(EntityCollectionViewCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.frame = bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(collectionView)
        
        if #available(iOS 10, *) { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferredContentSizeCategoryDidChange), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 10, *) {
            if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
                preferredContentSizeCategoryDidChange()
            }
        }
    }
    
    open func preferredContentSizeCategoryDidChange() {
        formLayout.invalidateLayout()
    }
}

