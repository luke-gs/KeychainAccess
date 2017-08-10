//
//  SearchOptionsViewController.swift
//  MPOL
//
//  Created by Valery Shorinov on 31/3/17.
//
//

import UIKit


class SearchOptionsViewController: FormCollectionViewController, UITextFieldDelegate, SearchDataSourceUpdating, TabStripViewDelegate {

    private var dataSources: [SearchDataSource]?
    private var currentSearchable: Searchable?
    private var filterOptions: [Int: String] = [Int: String]()

    private var selectedDataSourceIndex: Int = 0 {
        didSet {
            guard let dataSources = dataSources else { return }
            selectedDataSource = dataSources[selectedDataSourceIndex]
        }
    }
    
    weak var delegate: SearchOptionsViewControllerDelegate?
    
    private(set) lazy var searchBarButtonItem: UIBarButtonItem = { [unowned self] in
        return  UIBarButtonItem(title: NSLocalizedString("Search", comment: ""), style: .done, target: self, action: #selector(searchButtonItemDidSelect(_:)))
    }()
    
    private(set) lazy var cancelBarButtonItem: UIBarButtonItem = { [unowned self] in
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonItemDidSelect(_:)))
    }()
    
    private(set) var areFiltersHidden: Bool = true {
        didSet {
            if areFiltersHidden == oldValue { return }
            
            reloadCollectionViewRetainingEditing()
        }
    }
    
    private var navigationBarExtension: NavigationBarExtension?
    
    private var tabStripView: TabStripView?
    
    
    // MARK: - Private methods
    
    private var selectedDataSource: SearchDataSource {
        didSet {
            reloadCollectionViewRetainingEditing()
        }
    }
    
    private var isEditingTextField: Bool = false
    
    
    // MARK: - Initializers
    
    init(dataSources: [SearchDataSource]? = nil) {
        guard let firstDataSource = dataSources?.first else {
            fatalError("SearchOptionsViewController requires at least one available search type")
        }
        
        self.dataSources        = dataSources
        self.selectedDataSource = firstDataSource

        super.init()

        if let datasources = self.dataSources {
            for i in 0..<datasources.count {
                self.dataSources?[i].updatingDelegate = self
            }
        }
        
        calculatesContentHeight = true
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    
    // MARK: - Updating search requests
//    
//    func resetSearchRequests() {
//        dataSources.forEach { $0.reset() }
//    }
//
//    func setCurrentSearchRequest(_ request: SearchRequest) {
//        let dataSourceText = request.searchText
//        let correctDataSourceIndex = dataSources.index(where: { $0.supports(request) })
//        
//        selectedDataSourceIndex = correctDataSourceIndex ?? 0
//        
//        dataSources.enumerated().forEach { (offset, dataSource) in
//            if offset == correctDataSourceIndex {
//                dataSource.request = request
//            } else {
//                dataSource.reset(withSearchText: dataSourceText)
//            }
//        }
//    }

    func setCurrent(searchable: Searchable?) {
        self.currentSearchable = searchable
        dataSources?.enumerated().forEach { (index, dataSource) in
            if dataSource.localizedDisplayName == searchable?.type {
                selectedDataSource = dataSource
                tabStripView?.selectedItemIndex = index
                return
            }
        }
    }
    
    // MARK - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let view = self.view, let collectionView = self.collectionView else { return }
        
        collectionView.register(SearchFieldCollectionViewCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.alwaysBounceVertical = false
        
        let navBarExtension = NavigationBarExtension(frame: .zero)
        navBarExtension.translatesAutoresizingMaskIntoConstraints = false
        
        let tabStripView = TabStripView(frame: .zero)

        if let dataSources = dataSources {
            tabStripView.items = dataSources.map { $0.localizedDisplayName }
        }

        tabStripView.selectedItemIndex = selectedDataSourceIndex
        tabStripView.delegate = self
        navBarExtension.contentView = tabStripView
        
        view.addSubview(navBarExtension)
        navigationBarExtension = navBarExtension
        self.tabStripView      = tabStripView

        let extensionVerticalConstraint: NSLayoutConstraint
        // TODO: Uncomment in iOS 11
        //        if #available(iOS 11, *) {
        //            extensionVerticalConstraint = navBarExtension.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        //        } else {
        extensionVerticalConstraint = navBarExtension.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
        //        }
        
        NSLayoutConstraint.activate([
            navBarExtension.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarExtension.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            extensionVerticalConstraint
        ])

        
        var contentSize = collectionView.contentSize
        contentSize.height += navigationBarExtension?.frame.height ?? 0.0
        preferredContentSize = contentSize
    }
    
    override func viewWillLayoutSubviews() {
        // TODO: Uncomment in iOS 11
        //        if #available(iOS 11, *) {
        //            additionalSafeAreaInsets.top = navigationBarExtension?.frame.height ?? 0.0
        //        } else {
        legacy_additionalSafeAreaInsets.top = navigationBarExtension?.frame.height ?? 0.0
        //        }
        
        super.viewWillLayoutSubviews()
    }
    
//    open override func viewDidLayoutSubviews() {
//        updatePreferredContentSize()
//        
//        let insets = UIEdgeInsets(top: topLayoutGuide.length + (navigationBarExtension?.frame.height ?? 0.0), left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
//        loadingManager.contentInsets = insets
//        collectionViewInsetManager?.standardContentInset = insets
//        collectionViewInsetManager?.standardIndicatorInset = insets
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isEditingTextField {
            beginEditingSearchField()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        endEditingSearchField(changingState: false)
        super.viewWillDisappear(animated)
    }
    
    private func reloadCollectionViewRetainingEditing() {
        guard let collectionView = self.collectionView else { return }
        
        let selectedIndexPaths = collectionView.indexPathsForSelectedItems ?? []
        
        let wasSearchFieldActive = self.searchFieldCell?.textField.isFirstResponder ?? false
        
        collectionView.reloadData()
        
        selectedIndexPaths.forEach {
            collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
        }
        
        if wasSearchFieldActive {
            beginEditingSearchField()
        }
    }
    
    
    // MARK: - Editing
    
    func beginEditingSearchField(selectingAllText: Bool = false) {
        collectionView?.selectItem(at: indexPathForSearchFieldCell, animated: false, scrollPosition: [])
        
        if let textField = searchFieldCell?.textField {
            removeErrorMessage()
            textField.becomeFirstResponder()
            if selectingAllText {
                textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
            }
        }
        
        isEditingTextField = true
    }

    
    func endEditingSearchField() {        
        endEditingSearchField(changingState: true)
    }
    
    private func endEditingSearchField(changingState: Bool) {
        removeErrorMessage()
        collectionView?.deselectItem(at: indexPathForSearchFieldCell, animated: false)
        searchFieldCell?.textField.resignFirstResponder()
        if changingState {
            isEditingTextField = false
        }
    }
    
    private var searchFieldCell: SearchFieldCollectionViewCell? {
        collectionView?.layoutIfNeeded()
        return collectionView?.cellForItem(at: indexPathForSearchFieldCell) as? SearchFieldCollectionViewCell
    }
    
    private var indexPathForSearchFieldCell: IndexPath {
        return IndexPath(item: 0, section: 0)
    }
    
    // MARK: - Handling search parsing error
    
    var searchErrorMessage: String? {
        didSet {
            if oldValue != searchErrorMessage {
                if let errorMessage = searchErrorMessage {
                    displayErrorMessage(errorMessage)
                } else {
                    removeErrorMessage()
                }
            }
        }
    }
    
    private func displayErrorMessage(_ message: String) {
        if let cell = searchFieldCell {
            cell.setRequiresValidation(true, validationText: message, animated: true)
        }
    }
    
    private func removeErrorMessage() {
        if let cell = searchFieldCell {
            cell.setRequiresValidation(false, validationText: nil, animated: true)
        }
    }
    
    // MARK: - Action methods
    
    @objc private func searchButtonItemDidSelect(_ item: UIBarButtonItem) {
        performSearch()
    }
    
    @objc private func cancelButtonItemDidSelect(_ item: UIBarButtonItem) {
        delegate?.searchOptionsControllerDidCancel(self)
    }

    private func performSearch() {
        searchErrorMessage = nil
        
        var searchable = Searchable()
        searchable.searchText = searchFieldCell?.textField.text
        searchable.type = selectedDataSource.localizedDisplayName
        searchable.options = filterOptions

        delegate?.searchOptionsController(self, didFinishWith: searchable)
    }
    
    // MARK: - UICollectionViewDataSource methods

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let numberOfSections = (selectedDataSource.options.numberOfOptions > 0) ? 2 : 1
        return numberOfSections
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // This we should force unwrap because if we get the wrong section count here,
        // it's a fatal error anyway and we've seriously ruined our logic.
        switch Section(rawValue: section)! {
        case .searchField:
            return 1
        case .filters:
            return selectedDataSource.options.numberOfOptions
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            header.showsExpandArrow = false
            header.text             = "FILTER SEARCH"
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .searchField:
            let cell = collectionView.dequeueReusableCell(of: SearchFieldCollectionViewCell.self, for: indexPath)
            let textField = cell.textField
            textField.text = currentSearchable?.searchText

            textField.delegate = self
            if textField.allTargets.contains(self) == false {
                textField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
            }
            textField.attributedPlaceholder = selectedDataSource.searchPlaceholder
            
            if let errorMessage = searchErrorMessage {
                cell.setRequiresValidation(true, validationText: errorMessage, animated: true)
            } else {
                cell.setRequiresValidation(false, validationText: nil, animated: true)
            }
            
            return cell
        case .filters:
            let filterCell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
            filterCell.isEditable = true
            filterCell.valueLabel.numberOfLines = 1
            filterCell.selectionStyle = .underline
            filterCell.highlightStyle = .fade
            
            let filterIndex = indexPath.item
            let dataSource = self.selectedDataSource

            filterCell.titleLabel.text = dataSource.options.title(at: filterIndex)
            filterCell.valueLabel.text = dataSource.options.value(at: filterIndex)
            filterCell.placeholderLabel.text = dataSource.options.defaultValue(at: filterIndex)

            self.filterOptions[filterIndex] = dataSource.options.value(at: filterIndex)

            return filterCell
        }
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch Section(rawValue: indexPath.section)! {
        case .searchField:
            beginEditingSearchField()
        case .filters:
            
            // If there's no update view controller, we don't want to do anything.
            // Quickly deselect the index path, and return out.
            guard let updateViewController = selectedDataSource.updateController(forFilterAt: indexPath.item) else {
                collectionView.deselectItem(at: indexPath, animated: false)
                
                if isEditingTextField {
                    // Workaround:
                    // Calling this without dispatch async gets deselected *after* this call.
                    // Async it to get after this turn of the run loop.
                    DispatchQueue.main.async {
                        self.beginEditingSearchField()
                    }
                }
                return
            }
            
            // stop editing the field, if it is currently editing.
            if isEditingTextField {
                endEditingSearchField()
            }
            
            updateViewController.modalPresentationStyle = .popover
            if let popoverPresentationController = updateViewController.popoverPresentationController,
                let cell = collectionView.cellForItem(at: indexPath) {
                popoverPresentationController.sourceView = cell
                popoverPresentationController.sourceRect = cell.bounds
            }
            
            if let popoverNavigationController = updateViewController as? PopoverNavigationController {
                let dataSourceSpecifiedDismissHandler = popoverNavigationController.dismissHandler
                popoverNavigationController.dismissHandler = { [weak self] (animated: Bool) in
                    dataSourceSpecifiedDismissHandler?(animated)
                    self?.collectionView?.deselectItem(at: indexPath, animated: animated)
                }
            }
            
            present(updateViewController, animated: true)
        }
    }
    
    
    // MARK: - UITextFieldDelegate methods
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSearch()
        return false
    }
    
    @objc private func textFieldTextDidChange(_ textField: UITextField) {
        let text = textField.text

        currentSearchable?.searchText = text
        guard let collectionView = self.collectionView else { return }

        let has2Sections   = collectionView.numberOfSections == 2
        let wants2Sections = (selectedDataSource.options.numberOfOptions > 0) && (text?.isEmpty ?? true == false)

        if has2Sections != wants2Sections {
            reloadCollectionViewRetainingEditing()
        }
    }
    
    // MARK: - CollectionViewDelegateFormLayout methods
    
    func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        return 12.0
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForGlobalFooterInLayout layout: CollectionViewFormLayout) -> CGFloat {
        return 32.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return Section(rawValue: section) == .searchField ? 0.0 : CollectionViewFormHeaderView.minimumHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        
        if Section(rawValue: indexPath.section) == .searchField  {
            return collectionView.bounds.width
        }
        
        let extraLargeText: Bool
        switch traitCollection.preferredContentSizeCategory {
        case UIContentSizeCategory.extraSmall, UIContentSizeCategory.small, UIContentSizeCategory.medium, UIContentSizeCategory.large:
            extraLargeText = false
        default:
            extraLargeText = true
        }
        
        let minimumWidth: CGFloat = extraLargeText ? 250.0 : 140.0
        let maxColumnCount = 4
        
        return layout.columnContentWidth(forMinimumItemContentWidth: minimumWidth, maximumColumnCount: maxColumnCount, sectionEdgeInsets: sectionEdgeInsets).floored(toScale: UIScreen.main.scale)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        
        switch Section(rawValue: indexPath.section)! {
        case .searchField:
            return SearchFieldCollectionViewCell.cellContentHeight
        case .filters:
            
            let filterIndex = indexPath.item
            let title    = selectedDataSource.options.title(at: filterIndex)
            let subtitle = selectedDataSource.options.value(at: filterIndex) ?? selectedDataSource.options.defaultValue(at: filterIndex)
            return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
        }
        
    }

    // MARK: - SearchDataSourceUpdating

    func searchDataSourceRequestDidChange(_ dataSource: SearchDataSource) {
        reloadCollectionViewRetainingEditing()
    }

    func searchDataSource(_ dataSource: SearchDataSource, didUpdateFilterAt index: Int) {
        // Can't currently update item in case of bugs. Perhaps when apple gets around to fixing this?? :S
        reloadCollectionViewRetainingEditing()
    }
    
    // MARK: - TabStripViewDelegate
    
    func tabStripView(_ tabStripView: TabStripView, didSelectItemAt index: Int) {
        selectedDataSourceIndex = index
    }
    
    // MARK: - Private
    
    private enum Section: Int {
        case searchField, filters
    }
    
}

protocol SearchOptionsViewControllerDelegate: class {

    func searchOptionsController(_ controller: SearchOptionsViewController, didFinishWith searchable: Searchable)

    func searchOptionsControllerDidCancel(_ controller: SearchOptionsViewController)

}

