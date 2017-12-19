//
//  FormBuilderViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 14/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

fileprivate var contentHeightContext = 1
fileprivate let tempID = "temp"

open class FormBuilderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CollectionViewDelegateFormLayout, PopoverViewController {

    // MARK: - Public properties

    open let formLayout: CollectionViewFormLayout

    open private(set) var collectionView: UICollectionView?

    open var collectionViewInsetManager: ScrollViewInsetManager?

    open private(set) lazy var loadingManager: LoadingStateManager = LoadingStateManager()

    // MARK: - Form Builder

    public let builder = FormBuilder()

    private var sections: [FormSection] = []

    private var isUnderContruction: Bool = true

    // MARK: - Height Calculations

    /// A boolean value indicating whether the collection view should automatically calculate
    /// its `preferreContentSize`'s height property from the collection view's content height.
    ///
    /// The default is `false`.
    open var calculatesContentHeight = false {
        didSet {
            if calculatesContentHeight == oldValue { return }

            if calculatesContentHeight {
                collectionView?.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), options: [.new, .old], context: &contentHeightContext)
                updateCalculatedContentHeight()
            } else {
                collectionView?.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &contentHeightContext)
            }
        }
    }

    open var minimumCalculatedContentHeight: CGFloat = 100.0 {
        didSet {
            if isViewLoaded && minimumCalculatedContentHeight >~ preferredContentSize.height {
                updateCalculatedContentHeight()
            }
        }
    }

    /// The maximum allowed calculated content height. The default is `.infinity`,
    /// meaning there is no restriction on the content height.
    open var maximumCalculatedContentHeight: CGFloat = .infinity {
        didSet {
            if isViewLoaded && maximumCalculatedContentHeight < preferredContentSize.height {
                updateCalculatedContentHeight()
            }
        }
    }


    // MARK: - Appearance properties

    /// The user interface style for the collection view.
    ///
    /// When set to `.current`, the theme autoupdates when the interface
    /// style changes.
    open var userInterfaceStyle: UserInterfaceStyle = .current {
        didSet {
            if userInterfaceStyle == oldValue { return }

            if userInterfaceStyle == .current {
                NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
            } else if oldValue == .current {
                NotificationCenter.default.removeObserver(self, name: .interfaceStyleDidChange, object: nil)
            }

            apply(ThemeManager.shared.theme(for: userInterfaceStyle))
        }
    }

    open var wantsTransparentBackground: Bool = false {
        didSet {
            if isViewLoaded {
                view.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
            }
        }
    }

    // MARK: - Subclass override points

    /// Allows subclasses to return a custom subclass of UICollectionView
    /// to use as the collection view.
    ///
    /// - Returns: The `UICollectionView` class to use for the main collection view.
    ///            The default returns `UICollectionView` itself.
    open func collectionViewClass() -> UICollectionView.Type {
        return UICollectionView.self
    }

    // MARK: - Legacy support
    /// Additional content insets beyond the standard top and bottom layout guides.

    ///
    /// In iOS 11, you should use `additionalSafeAreaInsets` instead.
    @available(iOS, deprecated: 11.0, message: "Use `additionalSafeAreaInsets` instead.")
    open var legacy_additionalSafeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            if legacy_additionalSafeAreaInsets == oldValue || isViewLoaded == false { return }

            view.setNeedsLayout()

            if calculatesContentHeight {
                updateCalculatedContentHeight()
            }
        }
    }


    // MARK: - Initializers

    public init() {
        formLayout = CollectionViewFormLayout()

        super.init(nibName: nil, bundle: nil)

        automaticallyAdjustsScrollViewInsets = false // we manage this ourselves.

        if userInterfaceStyle == .current {
            NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        }

    }

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }

    deinit {
        if calculatesContentHeight == false { return }

        collectionView?.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &contentHeightContext)
    }

    // MARK: - Form Builder

    open func construct(builder: FormBuilder) {
        MPLRequiresConcreteImplementation()
    }

    open func reloadForm() {
        isUnderContruction = true

        let items = builder.formItems
        items.forEach({
            if let item = $0 as? BaseFormItem {
                item.cell = nil
                item.collectionView = nil
            }
        })
        builder.removeAll()

        construct(builder: builder)
        title = builder.title ?? title

        let sections = builder.generateSections()

        var supplementaryRegistrations = [(UICollectionReusableView.Type, String, String)]()

        let cellRegistrations = sections.flatMap { section -> [(CollectionViewFormCell.Type, String)] in

            if let header = section.formHeader as? BaseSupplementaryFormItem {
                supplementaryRegistrations.append((header.viewType, header.kind, header.reuseIdentifier))
            }

            if let footer = section.formFooter as? BaseSupplementaryFormItem {
                supplementaryRegistrations.append((footer.viewType, footer.kind, footer.reuseIdentifier))
            }

            return section.formItems.map { (item) -> (CollectionViewFormCell.Type, String) in
                let item = item as! BaseFormItem
                item.collectionView = collectionView
                return (item.cellType, item.reuseIdentifier)
            }
        }

        for item in supplementaryRegistrations {
            collectionView?.register(item.0, forSupplementaryViewOfKind: item.1, withReuseIdentifier: item.2)
        }

        for item in cellRegistrations {
            collectionView?.register(item.0, forCellWithReuseIdentifier: item.1)
        }

        collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: collectionElementKindGlobalHeader,
                                 withReuseIdentifier: tempID)
        
        self.sections = sections

        collectionView?.reloadData()

        isUnderContruction = false
    }

    open func scrollTo(_ formItem: FormItem) {
        for (sectionIndex, section) in sections.enumerated() {
            if let itemIndex = section.formItems.index(where: { $0 === formItem }) {
                collectionView?.scrollToItem(at: IndexPath(item: itemIndex, section: sectionIndex), at: .centeredVertically, animated: true)
                return
            }
        }
    }

    // MARK: - View lifecycle

    open override func loadView() {
        let backgroundBounds = UIScreen.main.bounds

        let collectionView = collectionViewClass().init(frame: backgroundBounds, collectionViewLayout: formLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = nil

        if calculatesContentHeight {
            collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), options: [.old, .new], context: &contentHeightContext)
        }

        let backgroundView = UIView(frame: backgroundBounds)
        backgroundView.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
        backgroundView.addSubview(collectionView)

        self.collectionViewInsetManager = ScrollViewInsetManager(scrollView: collectionView)
        self.collectionView = collectionView
        self.view = backgroundView

        loadingManager.baseView = backgroundView
        loadingManager.contentView = collectionView
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        reloadForm()
        apply(ThemeManager.shared.theme(for: userInterfaceStyle))
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11, *) {
            return
        }

        var insets = legacy_additionalSafeAreaInsets
        insets.top += topLayoutGuide.length
        insets.bottom += max(bottomLayoutGuide.length, statusTabBarInset)

        loadingManager.contentInsets = insets
        collectionViewInsetManager?.standardContentInset   = insets
        collectionViewInsetManager?.standardIndicatorInset = insets
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            preferredContentSizeCategoryDidChange()
        }
    }

    open func preferredContentSizeCategoryDidChange() {
        if isViewLoaded { formLayout.invalidateLayout() }
    }


    // MARK: - Themes

    private var backgroundColor: UIColor?

    open func apply(_ theme: Theme) {
        backgroundColor = theme.color(forKey: .background)
        let secondaryTextColor = theme.color(forKey: .secondaryText)

        loadingManager.noContentColor = secondaryTextColor ?? .gray

        setNeedsStatusBarAppearanceUpdate()

        guard let view = self.viewIfLoaded, let collectionView = self.collectionView else { return }

        view.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor

        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell) {
                self.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
            }
        }

        if let globalHeader = collectionView.visibleSupplementaryViews(ofKind: collectionElementKindGlobalHeader).first {
            self.collectionView(collectionView, willDisplaySupplementaryView: globalHeader, forElementKind: collectionElementKindGlobalHeader, at: IndexPath(item: 0, section: 0))
        }
        if let globalFooter = collectionView.visibleSupplementaryViews(ofKind: collectionElementKindGlobalFooter).first {
            self.collectionView(collectionView, willDisplaySupplementaryView: globalFooter, forElementKind: collectionElementKindGlobalFooter, at: IndexPath(item: 0, section: 0))
        }

        let sectionHeaderIndexPaths = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader)
        for indexPath in sectionHeaderIndexPaths {
            if let headerView = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) {
                self.collectionView(collectionView, willDisplaySupplementaryView: headerView, forElementKind: UICollectionElementKindSectionHeader, at: indexPath)
            }
        }

        let sectionFooterIndexPaths = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionFooter)
        for indexPath in sectionFooterIndexPaths {
            if let footerView = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: indexPath) {
                self.collectionView(collectionView, willDisplaySupplementaryView: footerView, forElementKind: UICollectionElementKindSectionFooter, at: indexPath)
            }
        }
    }

    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return ThemeManager.shared.theme(for: .current).statusBarStyle
    }


    // MARK: - UICollectionViewDataSource methods

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let header = sections[section].formHeader as? HeaderFormItem {
            if header.style == .collapsible, !header.isExpanded {
                return 0
            }
        }
        return sections[section].formItems.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath] as! BaseFormItem
        return item.cell(forItemAt: indexPath, inCollectionView: collectionView)
    }

    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = sections[ifExists: indexPath.section]

        switch kind {
        case UICollectionElementKindSectionHeader:
            if let section = section, let item = section.formHeader as? BaseSupplementaryFormItem {
                let view = item.view(in: collectionView, for: indexPath)

                if let item = item as? HeaderFormItem, let headerView = view as? CollectionViewFormHeaderView {
                    headerView.tapHandler = { [weak self] cell, indexPath in
                        switch item.style {
                        case .collapsible:
                            item.isExpanded = !item.isExpanded
                            cell.setExpanded(item.isExpanded, animated: true)
                            self?.collectionView?.reloadSections(IndexSet(integer: indexPath.section))
                        case .plain:
                            break
                        }
                    }
                }

                return view
            }
        case UICollectionElementKindSectionFooter:
            if let section = section, let item = section.formFooter as? BaseSupplementaryFormItem {
                let view = item.view(in: collectionView, for: indexPath)
                return view
            }
        default:
            break
        }

        let defaultView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: tempID, for: indexPath)
        defaultView.isUserInteractionEnabled = false
        return defaultView
    }

    public func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        if let item = sections[section].formHeader as? BaseSupplementaryFormItem {
            return item.intrinsicHeight(in: collectionView, layout: layout, for: traitCollection)
        }
        return 0.0
    }

    public func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForFooterInSection section: Int) -> CGFloat {
        if let item = sections[section].formFooter as? BaseSupplementaryFormItem {
            return item.intrinsicHeight(in: collectionView, layout: layout, for: traitCollection)
        }
        return 0.0
    }

    // MARK: - UICollectionViewDelegate methods

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = sections[indexPath] as! BaseFormItem

        if let cell = cell as? CollectionViewFormCell {
            let theme = ThemeManager.shared.theme(for: userInterfaceStyle)
            item.cell = cell
            item.decorate(cell, withTheme: theme)

            if let accessoryView = cell.accessoryView {
                item.accessory?.apply(theme: theme, toView: accessoryView)
            }
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isUnderContruction == false else { return }

        let item = sections[indexPath] as! BaseFormItem
        item.cell = nil
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {

        let section = sections[indexPath.section]

        switch elementKind {
        case UICollectionElementKindSectionHeader:
            if let item = section.formHeader as? BaseSupplementaryFormItem {
                item.apply(theme: ThemeManager.shared.theme(for: userInterfaceStyle), toView: view)
            }
        case UICollectionElementKindSectionFooter:
            if let item = section.formFooter as? BaseSupplementaryFormItem {
                item.apply(theme: ThemeManager.shared.theme(for: userInterfaceStyle), toView: view)
            }
        default:
            break
        }
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sections[indexPath] as! BaseFormItem

        if let item = item as? SelectionActionable, let action = item.selectionAction {
            let viewController = action.viewController()

            if viewController.modalPresentationStyle == .popover {
                if let cell = collectionView.cellForItem(at: indexPath), let presentationController = viewController.popoverPresentationController {
                    presentationController.sourceView = cell
                    presentationController.sourceRect = cell.bounds
                }
            }

            action.dismissHandler = { [weak self, unowned action] in
                self?.collectionView?.deselectItem(at: indexPath, animated: true)
                action.dismissHandler = nil
            }

            if viewController.modalPresentationStyle == .none {
                navigationController?.pushViewController(viewController, animated: true)
            } else {
                present(viewController, animated: true, completion: nil)
            }
        }

        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewFormCell {
            item.onSelection?(cell)
        }
    }

    // MARK: - CollectionViewDelegateMPOLLayout methods

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 24.0, bottom: 0.0, right: 16.0)
    }

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        if builder.forceLinearLayout {
            return collectionView.bounds.width
        }

        let item = sections[indexPath] as! BaseFormItem
        return item.minimumContentWidth(in: collectionView, layout: layout, sectionEdgeInsets: sectionEdgeInsets, for: traitCollection)
    }

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let item = sections[indexPath] as! BaseFormItem
        return item.minimumContentHeight(in: collectionView, layout: layout, givenContentWidth: itemWidth, for: traitCollection)
    }

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForValidationAccessoryAt indexPath: IndexPath, givenContentWidth contentWidth: CGFloat) -> CGFloat {
        let item = sections[indexPath] as! BaseFormItem
        return item.heightForValidationAccessory(givenContentWidth: contentWidth, for: traitCollection)
    }

    // MARK: - Overrides

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &contentHeightContext {
            if calculatesContentHeight == false { return }

            let old = change?[.oldKey] as? NSObject
            let new = change?[.newKey] as? NSObject

            if old != new {
                updateCalculatedContentHeight()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }


    // MARK: - Content height methods


    /// Updates the calculated content height of the collection view.
    ///
    /// Subclasses should not need to override this method, but
    /// should call this method when their calculated content size changes.
    open func updateCalculatedContentHeight() {
        if calculatesContentHeight == false || isViewLoaded == false { return }

        let calculatedContentHeight = self.calculatedContentHeight()

        if preferredContentSize.height !=~ calculatedContentHeight {
            preferredContentSize.height = calculatedContentHeight
        }
    }


    /// Calculates the current preferred content size for the collection view.
    ///
    /// The default uses the current height of the collection view and additional content
    /// insets, clamped to the min and max values set on the class, and updates when the
    /// collection view's content height changes or the additional content insets change.
    open func calculatedContentHeight() -> CGFloat {
        var contentHeight = collectionView?.contentSize.height ?? 0.0

        if #available(iOS 11, *) {
            contentHeight += additionalSafeAreaInsets.top + additionalSafeAreaInsets.bottom
        } else {
            contentHeight += legacy_additionalSafeAreaInsets.top + legacy_additionalSafeAreaInsets.bottom
        }

        let minHeight = minimumCalculatedContentHeight
        let maxHeight = maximumCalculatedContentHeight

        return max(min(contentHeight, maxHeight), minHeight)
    }


    // MARK: - Private methods

    @objc private func interfaceStyleDidChange() {
        if userInterfaceStyle != .current { return }

        apply(ThemeManager.shared.theme(for: userInterfaceStyle))
    }

}

@available(iOS, introduced: 11.0)
extension FormBuilderViewController {

    open override var additionalSafeAreaInsets: UIEdgeInsets {
        didSet {
            if additionalSafeAreaInsets != oldValue && calculatesContentHeight {
                updateCalculatedContentHeight()
            }
        }
    }

}
