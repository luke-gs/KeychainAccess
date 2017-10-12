//
//  SearchRecentsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 4/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import Unbox

private let maxRecentViewedCount = 6

class SearchRecentsViewController: FormCollectionViewController {

    weak var delegate: SearchRecentsViewControllerDelegate?

    var recentlyViewed: [MPOLKitEntity] {
        get {
            return self.viewModel.recentlyViewed
        }
        set {
            self.viewModel.recentlyViewed = newValue

            updateLoadingManagerState()

            if traitCollection.horizontalSizeClass == .compact {
                if showsRecentSearchesWhenCompact == false {
                    collectionView?.reloadSections(IndexSet(integer: 0))
                }
            } else {
                collectionView?.reloadSections(IndexSet(integer: 0))
            }
        }
    }

    var recentlySearched: [Searchable] {
        get {
            return self.viewModel.recentlySearched
        }

        set {
            self.viewModel.recentlySearched = newValue

            updateLoadingManagerState()

            if traitCollection.horizontalSizeClass != .compact || showsRecentSearchesWhenCompact {
            collectionView?.reloadSections(IndexSet(integer: 0))
            }
        }
    }

    @objc dynamic var isShowingNavBarExtension: Bool = false {
        didSet {
            compactNavBarExtension?.alpha = isShowingNavBarExtension ? 1.0 : 0.0

            // Force layout of nav bar extension first if showing, then layout view to account for it
            if isShowingNavBarExtension {
                compactNavBarExtension?.setNeedsLayout()
                compactNavBarExtension?.layoutIfNeeded()
            }
            view.setNeedsLayout()
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

    private var viewModel: SearchRecentsViewModel

    // MARK: - Initializer

    init(viewModel: SearchRecentsViewModel) {
        self.viewModel = viewModel
        super.init()
        self.title = viewModel.title
        formLayout.pinsGlobalHeaderWhenBouncing = true
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the no content view.

        let noContentView = loadingManager.noContentView
        noContentView.imageView.image = AssetManager.shared.image(forKey: .refresh)
        noContentView.imageView.tintColor = #colorLiteral(red: 0.6044161711, green: 0.6313971979, blue: 0.6581829122, alpha: 0.6420554578)

        noContentView.titleLabel.text = NSLocalizedString("You don't have any recently viewed entities or recent searches right now.", comment: "")

        let actionButton = noContentView.actionButton
        actionButton.titleLabel?.font = .systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)
        actionButton.setTitle(NSLocalizedString("New Search", comment: ""), for: .normal)
        actionButton.addTarget(self, action: #selector(newSearchButtonDidSelect(_:)), for: .primaryActionTriggered)

        updateLoadingManagerState()

        guard let view = self.view, let collectionView = self.collectionView else { return }

        collectionView.register(EntityCollectionViewCell.self)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(RecentEntitiesHeaderView.self, forSupplementaryViewOfKind: collectionElementKindGlobalHeader)

        // Setup compact views.

        let segmentedControl = UISegmentedControl(items: [NSLocalizedString("Recently Searched", comment: ""), NSLocalizedString("Recently Viewed", comment: "")])
        segmentedControl.selectedSegmentIndex = showsRecentSearchesWhenCompact ? 0 : 1
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueDidChange(_:)), for: .valueChanged)

        let navBarExtension = NavigationBarExtension(frame: .zero)
        navBarExtension.translatesAutoresizingMaskIntoConstraints = false
        navBarExtension.contentView = segmentedControl
        navBarExtension.alpha = isShowingNavBarExtension ? 1.0 : 0.0
        view.addSubview(navBarExtension)

        compactSegmentedControl = segmentedControl
        compactNavBarExtension = navBarExtension

        NSLayoutConstraint.activate([
            segmentedControl.widthAnchor.constraint(equalTo: navBarExtension.widthAnchor, constant: -32.0),
            segmentedControl.topAnchor.constraint(equalTo: navBarExtension.topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: navBarExtension.bottomAnchor, constant: -17.0),

            navBarExtension.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarExtension.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Due to use of additional safe area insets, we cannot position the top of the
            // nav extension within the safe area in iOS 11, it needs to go above
            constraintAboveSafeAreaOrBelowTopLayout(navBarExtension)
        ])
    }


    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let horizontallyCompact = traitCollection.horizontalSizeClass == .compact
        if horizontallyCompact != ((previousTraitCollection?.horizontalSizeClass ?? .unspecified) == .compact) {
            collectionView?.reloadData()
            isShowingNavBarExtension = horizontallyCompact
        }
    }

    override func viewWillLayoutSubviews() {
        let navBarExtension = isShowingNavBarExtension ? compactNavBarExtension?.frame.height ?? 0.0 : 0.0

        if #available(iOS 11, *) {
            additionalSafeAreaInsets.top = navBarExtension
        } else {
            legacy_additionalSafeAreaInsets.top = navBarExtension
        }
        super.viewWillLayoutSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateLoadingManagerState()
        collectionView?.reloadData()
    }

    // MARK: - UICollectionViewDataSource methods

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isRecentlySearched(for: collectionView) ? recentlySearched.count : min(recentlyViewed.count, 6)
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            if isRecentlySearched(for: collectionView) {
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

        if isRecentlySearched(for: collectionView) {
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            let request = recentlySearched[indexPath.item]

            cell.titleLabel.text    = request.text?.ifNotEmpty() ?? NSLocalizedString("(No Search Term)", comment: "")
            cell.subtitleLabel.text = request.type
            cell.accessoryView      = cell.accessoryView as? FormAccessoryView ?? FormAccessoryView(style: .disclosure)
            cell.highlightStyle     = .fade
            cell.imageView.image    = summaryIcon(for: request)
            cell.labelSeparation = 2.0

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
            viewModel.decorate(cell, at: indexPath)

            return cell
        }
    }


    // MARK: - UICollectionViewDelegate methods

    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)


        if traitCollection.horizontalSizeClass != .compact && userInterfaceStyle.isDark == false && collectionView != self.collectionView,
            let header = view as? CollectionViewFormHeaderView {
            header.separatorColor = ThemeManager.shared.theme(for: .dark).color(forKey: .separator)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)

        if traitCollection.horizontalSizeClass != .compact, let entityCell = cell as? EntityCollectionViewCell {
            if userInterfaceStyle.isDark {
                entityCell.subtitleLabel.textColor = primaryTextColor
            } else {
                let darkTheme = ThemeManager.shared.theme(for: .dark)

                let primaryColor = darkTheme.color(forKey: .primaryText)
                entityCell.titleLabel.textColor    = primaryColor
                entityCell.subtitleLabel.textColor = primaryColor
                entityCell.detailLabel.textColor   = darkTheme.color(forKey: .secondaryText)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if isRecentlySearched(for: collectionView) {
            delegate?.searchRecentsController(self, didSelectRecentSearch: recentlySearched[indexPath.item])
        } else {
            delegate?.searchRecentsController(self, didSelectRecentEntity: recentlyViewed[indexPath.item])
        }
    }


    // MARK: - CollectionViewDelegateFormLayout methods

    func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        if collectionView != self.collectionView { return 0.0 }
        if recentlyViewed.count == 0 { return 0.0 }
        
        let traitCollection = self.traitCollection
        if traitCollection.horizontalSizeClass == .compact { return 0.0 }

        let visibleRegion = collectionView.bounds.insetBy(collectionView.contentInset)
        let itemsStackedVertically = visibleRegion.width >= visibleRegion.height ? 2 : 3

        let itemInsets = layout.itemLayoutMargins
        let itemHeight = EntityCollectionViewCell.minimumContentHeight(forStyle: .detail, compatibleWith: traitCollection) + itemInsets.top + itemInsets.bottom
        
        let height = itemHeight * CGFloat(itemsStackedVertically) + CollectionViewFormHeaderView.minimumHeight + 20.0 // 20 is the insets you see below.
        
        return height
    }

    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        if traitCollection.horizontalSizeClass == .compact { return 0.0 }
        return CollectionViewFormHeaderView.minimumHeight
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
            return layout.columnContentWidth(forMinimumItemContentWidth: EntityCollectionViewCell.minimumContentWidth(forStyle: .detail), maximumColumnCount: 3, sectionEdgeInsets: sectionEdgeInsets)
        }
        return collectionView.bounds.width
    }

    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if isRecentlySearched(for: collectionView) {
            let recentSearch = recentlySearched[indexPath.item]

            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: recentSearch.type, subtitle: recentSearch.type, inWidth: itemWidth, compatibleWith: traitCollection, imageSize: summaryIcon(for: recentSearch)?.size ?? .zero)
        } else {
            return EntityCollectionViewCell.minimumContentHeight(forStyle: .detail, compatibleWith: traitCollection)
        }
    }


    // MARK: - Private methods

    private func summaryIcon(for searchRequest: Searchable) -> UIImage? {
        return viewModel.summaryIcon(for: searchRequest)
    }

    @objc private func segmentedControlValueDidChange(_ control: UISegmentedControl) {
        if control == compactSegmentedControl {
            showsRecentSearchesWhenCompact = control.selectedSegmentIndex == 0
        }
    }

    @objc private func newSearchButtonDidSelect(_ button: UIButton) {
        delegate?.searchRecentsControllerDidSelectNewSearch(self)
    }

    private func updateLoadingManagerState() {
        loadingManager.state = recentlyViewed.isEmpty == false || recentlySearched.isEmpty == false ? .loaded : .noContent
    }

    private func isRecentlySearched(for collectionView: UICollectionView) -> Bool {
        if traitCollection.horizontalSizeClass == .compact {
            return showsRecentSearchesWhenCompact
        } else {
            return collectionView == self.collectionView
        }
    }

}

protocol SearchRecentsViewControllerDelegate: class {
    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentSearch recentSearch: Searchable)
    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentEntity recentEntity: MPOLKitEntity)
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
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
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

    @objc open func preferredContentSizeCategoryDidChange() {
        formLayout.invalidateLayout()
    }

}
