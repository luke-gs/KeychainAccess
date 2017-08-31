//
//  SearchOptionsViewController.swift
//  MPOL
//
//  Created by Valery Shorinov on 31/3/17.
//
//

import UIKit

fileprivate var selectedDataSourceContext = 1

class SearchOptionsViewController: FormCollectionViewController, UITextFieldDelegate, SearchDataSourceUpdating, TabStripViewDelegate {
    
    private enum CellIdentifier: String {
        case advance
    }
    
    private var dataSources: [SearchDataSource]?
    
    private var selectedDataSourceIndex: Int = 0 {
        didSet {
            guard let dataSources = dataSources else { return }
            selectedDataSource = dataSources[selectedDataSourceIndex]
        }
    }
    
    weak var delegate: SearchOptionsViewControllerDelegate?
    
    private var navigationBarExtension: NavigationBarExtension?
    
    private var tabStripView: TabStripView?
    
    
    // MARK: - Private methods
    
    private var selectedDataSource: SearchDataSource {
        didSet {
            oldValue.updatingDelegate = nil
            
            var textRange: UITextRange?
            if let cell = collectionView?.cellForItem(at: indexPathForSearchFieldCell) as? SearchFieldCollectionViewCell {
                let text = cell.textField.text
                textRange = cell.textField.selectedTextRange
                
                // Generate a generic search
                let search = Searchable(text: text, options: nil, type: nil)
                selectedDataSource.prefill(withSearchable: search)
            }
            
            navigationItem.rightBarButtonItem = selectedDataSource.navigationButton
            
            selectedDataSource.updatingDelegate = self
            editingTextFieldIndexPath = (indexPathForSearchFieldCell, textRange)
        }
    }
    
    private var editingTextFieldIndexPath: (indexPath: IndexPath?, textRange: UITextRange?)? {
        didSet {
            if editingTextFieldIndexPath != nil {
                collectionView?.reloadData()
                collectionView?.selectItem(at: editingTextFieldIndexPath?.indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    private var shouldSelectAllText = false
    
    // MARK: - Initializers
    
    init(dataSources: [SearchDataSource]? = nil) {
        guard let firstDataSource = dataSources?.first else {
            fatalError("SearchOptionsViewController requires at least one available search type")
        }
        
        self.dataSources        = dataSources
        self.selectedDataSource = firstDataSource
        
        super.init()
        
        firstDataSource.updatingDelegate = self

        calculatesContentHeight = true
        
        title = NSLocalizedString("New Search", comment: "Search - New Search title")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonItemDidSelect(_:)))
        navigationItem.rightBarButtonItem = firstDataSource.navigationButton
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    
    // MARK: - Updating search requests
    func resetSearch() {
        let blankSearch = Searchable()
        dataSources?.forEach { $0.prefill(withSearchable: blankSearch) }
        reloadCollectionViewRetainingEditing()
    }

    func setCurrent(searchable: Searchable?) {
        guard let searchable = searchable else { return }
        
        if let index = dataSources?.index(where: { $0.prefill(withSearchable: searchable) }) {
            tabStripView?.selectedItemIndex = index
        }
    }
    
    // MARK - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let view = self.view, let collectionView = self.collectionView else { return }
        
        collectionView.register(SearchFieldCollectionViewCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
        collectionView.register(CollectionViewFormTextFieldCell.self)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(SearchFieldAdvanceCell.self, forCellWithReuseIdentifier: CellIdentifier.advance.rawValue)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.alwaysBounceVertical = false
        collectionView.allowsMultipleSelection = false
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        shouldSelectAllText = true
        editingTextFieldIndexPath = (indexPathForSearchFieldCell, nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let selectedItemIndexPath = collectionView?.indexPathsForSelectedItems?.first {
            collectionView?.deselectItem(at: selectedItemIndexPath, animated: false)
        }
    }
    
    private func reloadCollectionViewRetainingEditing() {
        guard let collectionView = self.collectionView else { return }
        
        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            if let oldCell = collectionView.cellForItem(at: selectedIndexPath) {
                var textField: UITextField?
                if let cell = oldCell as? SearchFieldCollectionViewCell {
                    textField = cell.textField
                } else if let cell = oldCell as? CollectionViewFormTextFieldCell {
                    textField = cell.textField
                }
                
                if let textField = textField {
                    let selectedTextRange = textField.selectedTextRange
                    editingTextFieldIndexPath = (selectedIndexPath, selectedTextRange)
                    return
                }
            }
        }
        
        collectionView.reloadData()
    }
    
    
    // MARK: - Editing
    
    private let indexPathForSearchFieldCell = IndexPath(item: 0, section: 0)
    
    // MARK: - Action methods
    
    @objc private func cancelButtonItemDidSelect(_ item: UIBarButtonItem) {
        delegate?.searchOptionsControllerDidCancel(self)
    }

    // MARK: - UICollectionViewDataSource methods

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let numberOfSections = ((selectedDataSource.options?.numberOfOptions ?? 0) > 0) ? 2 : 1
        return numberOfSections
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // This we should force unwrap because if we get the wrong section count here,
        // it's a fatal error anyway and we've seriously ruined our logic.
        switch Section(rawValue: section)! {
        case .searchField:
            return 1
        case .filters:
            return selectedDataSource.options?.numberOfOptions ?? 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            header.showsExpandArrow = false
            header.text             = selectedDataSource.options!.headerText
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dataSource = self.selectedDataSource
        
        switch Section(rawValue: indexPath.section)! {
        case .searchField:
            switch dataSource.searchStyle {
            case .search(let configure, _, let message):
                let cell = collectionView.dequeueReusableCell(of: SearchFieldCollectionViewCell.self, for: indexPath)
                
                // It is important to reset the text field back to default state as this is reused by multiple datasources and some properties may not be configured by the data source.
                let textField = cell.textField
                textField.text = nil
                textField.delegate = nil
                textField.keyboardType = .asciiCapable
                textField.autocapitalizationType = .words
                textField.autocorrectionType = .no
                textField.returnKeyType = .search
                textField.attributedPlaceholder = nil
                
                textField.allTargets.forEach { textField.removeTarget($0, action: nil, for: .allEvents) }
                
                cell.additionalButtons = configure?(textField)
                cell.setRequiresValidation(message != nil, validationText: message, animated: false)
                
                if textField.allTargets.contains(self) == false {
                    textField.addTarget(self, action: #selector(onTextDidChange(_:)), for: .editingChanged)
                }
                
                textField.delegate = self
                
                return cell
            case .button(let configure):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.advance.rawValue, for: indexPath) as! SearchFieldAdvanceCell
                
                // It is important to reset the button back to default state as this is reused by multiple datasources and some properties may not be configured by the data source.
                let actionButton = cell.actionButton
                actionButton.setTitleColor(tintColor, for: .normal)
                actionButton.allTargets.forEach { actionButton.removeTarget($0, action: nil, for: .allEvents) }
                
                configure?(actionButton)
                return cell
            }
            
        case .filters:
            let filterIndex = indexPath.item
            
            let options = dataSource.options
            
            let title = options!.title(at: filterIndex)
            let value = options!.value(at: filterIndex)
            let placeholder = options!.defaultValue(at: filterIndex)
            let message = options!.errorMessage(at: filterIndex)
            
            switch options!.type(at: filterIndex) {
            case .picker:
                let filterCell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
                filterCell.isEditable = true
                filterCell.valueLabel.numberOfLines = 1
                filterCell.selectionStyle = .underline
                filterCell.highlightStyle = .fade
                filterCell.accessoryView = FormAccessoryView(style: .dropDown)
                
                filterCell.titleLabel.text = title
                filterCell.valueLabel.text = value
                filterCell.placeholderLabel.text = placeholder
                filterCell.setRequiresValidation(message != nil, validationText: message, animated: false)
                
                return filterCell
            case .text(let configure):
                let filterCell = collectionView.dequeueReusableCell(of: CollectionViewFormTextFieldCell.self, for: indexPath)
                filterCell.selectionStyle = .underline
                filterCell.highlightStyle = .fade
                
                let textField = filterCell.textField
                configure?(textField)
                
                textField.text = value
                textField.placeholder = placeholder
                
                if textField.allTargets.contains(self) == false {
                    textField.addTarget(self, action: #selector(onTextDidChange(_:)), for: .editingChanged)
                }
                
                textField.delegate = self
                
                filterCell.titleLabel.text = title
                filterCell.setRequiresValidation(message != nil, validationText: message, animated: false)
                
                return filterCell
            case .action(let image, let buttonTitle, let buttonHandler):
                let filterCell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
                filterCell.style = .value
                filterCell.selectionStyle = .none
                filterCell.highlightStyle = .fade
                filterCell.accessoryView  = FormAccessoryView(style: .disclosure)
                
                filterCell.imageView.image = image
                
                filterCell.titleLabel.text = title
                filterCell.subtitleLabel.text = value ?? placeholder
                filterCell.setRequiresValidation(message != nil, validationText: message, animated: false)
             
                if let title = buttonTitle, let handler = buttonHandler {
                    filterCell.editActions = [CollectionViewFormEditAction(title: title, color: .gray, handler: { (_, _) in
                        handler()
                    })]
                } else {
                    filterCell.editActions = []
                }
                return filterCell
            }
        }
    }

    // MARK: - UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .searchField:
            break
        case .filters:
            switch selectedDataSource.selectionAction(forFilterAt: indexPath.item) {
            case .options(let controller):
                // If there's no update view controller, we don't want to do anything.
                // Quickly deselect the index path, and return out.
                guard let updateViewController = controller else {
                    collectionView.deselectItem(at: indexPath, animated: false)
                    return
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
            case .none: break
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if indexPath == editingTextFieldIndexPath?.indexPath {
            var selectedTextField: UITextField?
            if let textField = (cell as? SearchFieldCollectionViewCell)?.textField, !textField.isFirstResponder {
                selectedTextField = textField
            } else if let textField = (cell as? CollectionViewFormTextFieldCell)?.textField, !textField.isFirstResponder {
                selectedTextField = textField
            }
            
            selectedTextField?.becomeFirstResponder()
            
            var textRange: UITextRange?
            
            if shouldSelectAllText {
                if let textField = selectedTextField {
                    textRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                }
                shouldSelectAllText = false
            } else {
                textRange = editingTextFieldIndexPath?.textRange
            }
            
            selectedTextField?.selectedTextRange = textRange
            
            editingTextFieldIndexPath = nil
        }
    }
    
    // MARK: - CollectionViewDelegateFormLayout methods
    
    func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        return 12.0
    }

    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForValidationAccessoryAt indexPath: IndexPath, givenContentWidth contentWidth: CGFloat) -> CGFloat {
        
        if indexPath.section == 0 {
            switch selectedDataSource.searchStyle {
            case .search(_, _, let message):
                if let errorMessage = message {
                    let height = SearchFieldCollectionViewCell.heightForValidationAccessory(withText: errorMessage, contentWidth: contentWidth, compatibleWith: traitCollection)
                    
                    return height + ((selectedDataSource.options?.numberOfOptions ?? 0 > 0) ? 0 : layout.itemLayoutMargins.bottom)
                }
                return layout.itemLayoutMargins.bottom
            case .button:
                break
            }
        } else {
            let message = selectedDataSource.options!.errorMessage(at: indexPath.item)
            if let errorMessage = message {
                return CollectionViewFormCell.heightForValidationAccessory(withText: errorMessage, contentWidth: contentWidth, compatibleWith: traitCollection)
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForFooterInSection section: Int) -> CGFloat {
        return section != 0 ? layout.itemLayoutMargins.bottom : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return Section(rawValue: section) == .searchField ? 0.0 : CollectionViewFormHeaderView.minimumHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        if Section(rawValue: indexPath.section) == .searchField {
            return collectionView.bounds.width
        }
        
        switch selectedDataSource.options!.type(at: indexPath.item) {
        case .action: return collectionView.bounds.width
        default: break
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
            switch selectedDataSource.searchStyle {
            case .search: return SearchFieldCollectionViewCell.cellContentHeight
            case .button: return SearchFieldAdvanceCell.cellContentHeight
            }
        case .filters:
            let options = selectedDataSource.options
            
            let filterIndex = indexPath.item
            let title = options!.title(at: filterIndex)
            let subtitle = options!.value(at: filterIndex) ?? options!.defaultValue(at: filterIndex)

            switch options!.type(at: filterIndex) {
            case .picker:
                return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
            case .text:
                return CollectionViewFormTextFieldCell.minimumContentHeight(withTitle: title, enteredText: subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
            case .action(let image, _, _):
                return max(CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: itemWidth, compatibleWith: traitCollection, imageSize: image?.size ?? .zero, style: .value), 25.0)
            }
        }
        
    }

    // MARK: - SearchDataSourceUpdating
    
    func searchDataSource(_ dataSource: SearchDataSource, didUpdateComponent component: SearchDataSourceComponent) {
        
        switch component {
        case .searchStyleErrorMessage:
            switch selectedDataSource.searchStyle {
            case .search(_, _, let message):
                let cell = self.collectionView?.cellForItem(at: self.indexPathForSearchFieldCell) as? CollectionViewFormCell
                cell?.setRequiresValidation(message != nil, validationText: message, animated: true)
                return
            default: break
            }
        case .filterErrorMessage(let index):
            let indexPath = IndexPath(item: index, section: Section.filters.rawValue)
            if let cell = self.collectionView?.cellForItem(at: indexPath) as? CollectionViewFormCell {
                let message = selectedDataSource.options?.errorMessage(at: index)
                cell.setRequiresValidation(message != nil, validationText: message, animated: true)
            }
            return
        default: break
        }
        
        navigationItem.rightBarButtonItem = selectedDataSource.navigationButton
        reloadCollectionViewRetainingEditing()
    }
    
    func searchDataSource(_ dataSource: SearchDataSource, didFinishWith search: Searchable, andResultViewModel viewModel: SearchResultViewModelable?) {
        // Pass it on to someone that cares
        delegate?.searchOptionsController(self, didFinishWith: search, andResultViewModel: viewModel)
    }
    
    // MARK: - TabStripViewDelegate
    
    func tabStripView(_ tabStripView: TabStripView, didSelectItemAt index: Int) {
        selectedDataSourceIndex = index
    }
    
    // MARK: - Private
    
    private enum Section: Int {
        case searchField, filters
    }
    
    private func notifyTextChanged(textField: UITextField, didEndEditing: Bool) {
        guard let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first else {
            return
        }
        
        switch Section(rawValue: selectedIndexPath.section)! {
        case .searchField:
            switch selectedDataSource.searchStyle {
            case .search(_, let textHandler, _):
                textHandler?(textField.text, didEndEditing)
            default: break
            }
        case .filters:
            let item = selectedIndexPath.item
            selectedDataSource.textChanged(forFilterAt: item, text: textField.text, didEndEditing: didEndEditing)
        }
    }
    
    @objc private func onTextDidChange(_ textField: UITextField) {
        notifyTextChanged(textField: textField, didEndEditing: false)
    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        notifyTextChanged(textField: textField, didEndEditing: true)
        textField.resignFirstResponder()
        return false
    }
    
}

protocol SearchOptionsViewControllerDelegate: class {

    func searchOptionsController(_ controller: SearchOptionsViewController, didFinishWith searchable: Searchable, andResultViewModel viewModel: SearchResultViewModelable?)

    func searchOptionsControllerDidCancel(_ controller: SearchOptionsViewController)

}

