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

public class SearchRecentsViewController: FormBuilderViewController, SearchRecentsViewModelDelegate {

    weak var delegate: SearchRecentsViewControllerDelegate?

    public var recentlyViewed: EntityBucket {
        return viewModel.recentlyViewed
//        get {
//            return self.viewModel.recentlyViewed
//        }
//        set {
//            self.viewModel.recentlyViewed = newValue
//
//            updateLoadingManagerState()
//
//            if traitCollection.horizontalSizeClass == .compact {
//                if showsRecentSearchesWhenCompact == false {
//                    reloadForm()
//                }
//            } else {
//                reloadForm()
//            }
//        }
    }

    public var recentlySearched: [Searchable] {
        get {
            return self.viewModel.recentlySearched
        }

        set {
            self.viewModel.recentlySearched = newValue

            updateLoadingManagerState()

            if traitCollection.horizontalSizeClass != .compact || showsRecentSearchesWhenCompact {
                reloadForm()
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
                reloadForm()
            }
        }
    }

    private var viewModel: SearchRecentsViewModel

    private let recentlyViewedBuilder = FormBuilder()

    // MARK: - Initializer

    public init(viewModel: SearchRecentsViewModel) {
        self.viewModel = viewModel
        super.init()

        viewModel.delegate = self

        self.title = viewModel.title
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }


    // MARK: - View lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        formLayout.pinsGlobalHeaderWhenBouncing = true

        // Setup the no content view.

        let noContentView = loadingManager.noContentView
        noContentView.imageView.image = AssetManager.shared.image(forKey: .refresh)
        noContentView.imageView.tintColor = #colorLiteral(red: 0.6044161711, green: 0.6313971979, blue: 0.6581829122, alpha: 0.6420554578)

        noContentView.titleLabel.text = NSLocalizedString("You don't have any recently viewed entities or recent searches right now.", comment: "")

        let actionButton = noContentView.actionButton
        actionButton.setTitle(NSLocalizedString("New Search", comment: ""), for: .normal)
        actionButton.addTarget(self, action: #selector(newSearchButtonDidSelect(_:)), for: .primaryActionTriggered)

        updateLoadingManagerState()

        guard let view = self.view, let collectionView = self.collectionView else { return }

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


    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let horizontallyCompact = traitCollection.horizontalSizeClass == .compact
        if horizontallyCompact != ((previousTraitCollection?.horizontalSizeClass ?? .unspecified) == .compact) {
            reloadForm()
            isShowingNavBarExtension = horizontallyCompact
        }
    }

    public override func viewWillLayoutSubviews() {
        let navBarExtension = isShowingNavBarExtension ? compactNavBarExtension?.frame.height ?? 0.0 : 0.0

        if #available(iOS 11, *) {
            additionalSafeAreaInsets.top = navBarExtension
        } else {
            legacy_additionalSafeAreaInsets.top = navBarExtension
        }
        super.viewWillLayoutSubviews()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateLoadingManagerState()
        reloadForm()
    }

    public override func construct(builder: FormBuilder) {
        if traitCollection.horizontalSizeClass == .compact {
            if showsRecentSearchesWhenCompact {
                builder += viewModel.recentlySearchedItems()
            } else {
                builder += viewModel.recentlyViewedItems()
            }
        } else {
            recentlyViewedBuilder.removeAll()
            recentlyViewedBuilder += viewModel.recentlyViewedItems()

            let form = recentlyViewedBuilder.generateSections()

            let handler = FormCollectionViewHandler(sections: form.sections, globalHeader: form.globalHeader)
            handler.forceLinearLayout = builder.forceLinearLayout

            var insets = handler.sectionInsets
            insets.top = 10
            insets.bottom = 10
            handler.sectionInsets = insets

            builder += RecentEntitiesFormItem()
                .recentViewModel(viewModel)
                .handler(handler)

            let recentlySearched = viewModel.recentlySearchedItems()
            builder += recentlySearched
        }
    }


    // MARK: - UICollectionViewDelegate methods

//    public override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
//
//
//        if traitCollection.horizontalSizeClass != .compact && userInterfaceStyle.isDark == false && collectionView != self.collectionView,
//            let header = view as? CollectionViewFormHeaderView {
//            header.separatorColor = ThemeManager.shared.theme(for: .dark).color(forKey: .separator)
//        }
//    }

//    public override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int) -> UIEdgeInsets {
//        var inset = super.collectionView(collectionView, layout: layout, insetForSection: section)
//
//        if collectionView != self.collectionView {
//            inset.top    = 10.0
//            inset.bottom = 10.0
//        }
//
//        return inset
//    }

    // MARK: - SearchRecentsViewModelDelegate

    public func searchRecentsViewModel(_ searchRecentsViewModel: SearchRecentsViewModel, didSelectSearchable searchable: Searchable) {
        delegate?.searchRecentsController(self, didSelectSearchable: searchable)
    }

    public func searchRecentsViewModel(_ searchRecentsViewModel: SearchRecentsViewModel, didSelectPresentable presentable: Presentable) {
        delegate?.searchRecentsController(self, didSelectPresentable: presentable)
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
        loadingManager.state = recentlyViewed.entities.isEmpty == false || recentlySearched.isEmpty == false ? .loaded : .noContent
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
    func searchRecentsController(_ searchRecentsController: SearchRecentsViewController, didSelectSearchable searchable: Searchable)
    func searchRecentsController(_ searchRecentsController: SearchRecentsViewController, didSelectPresentable: Presentable)
    func searchRecentsControllerDidSelectNewSearch(_ searchRecentsController: SearchRecentsViewController)
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

private class RecentEntitiesFormItem: BaseSupplementaryFormItem {

    public var recentViewModel: SearchRecentsViewModel?

    public var handler: FormCollectionViewHandler?

    public init() {
        super.init(viewType: RecentEntitiesHeaderView.self, kind: collectionElementKindGlobalHeader, reuseIdentifier: RecentEntitiesHeaderView.defaultReuseIdentifier)
    }

    override func configure(_ view: UICollectionReusableView) {
        let view = view as! RecentEntitiesHeaderView
        let collectionView = view.collectionView

        handler?.registerWithCollectionView(collectionView)

        collectionView.dataSource = handler
        collectionView.delegate = handler
        collectionView.reloadData()
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, for traitCollection: UITraitCollection) -> CGFloat {
        guard let recentlyViewed = recentViewModel?.recentlyViewed, recentlyViewed.entities.count > 0 else { return 0.0 }

        if traitCollection.horizontalSizeClass == .compact { return 0.0 }

        let visibleRegion = collectionView.bounds.insetBy(collectionView.contentInset)
        let itemsStackedVertically = visibleRegion.width >= visibleRegion.height ? 2 : 3

        print(itemsStackedVertically)

        let itemInsets = layout.itemLayoutMargins
        let itemHeight = EntityCollectionViewCell.minimumContentHeight(forStyle: .detail, compatibleWith: traitCollection) + itemInsets.top + itemInsets.bottom

        let height = itemHeight * CGFloat(itemsStackedVertically) + CollectionViewFormHeaderView.minimumHeight + 20.0 // 20 is the insets you see below.

        return height
    }

    @discardableResult
    public func recentViewModel(_ recentViewModel: SearchRecentsViewModel?) -> Self {
        self.recentViewModel = recentViewModel
        return self
    }

    @discardableResult
    public func handler(_ handler: FormCollectionViewHandler?) -> Self {
        self.handler = handler
        return self
    }

}
