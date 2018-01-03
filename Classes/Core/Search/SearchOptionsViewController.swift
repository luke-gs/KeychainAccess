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
    
    private let searchContainer = UIView(frame: .zero)
    
    private let searchSeparator = UIView(frame: .zero)
    
    private let searchField = SearchFieldCollectionViewCell()
    
    private let buttonField = SearchFieldAdvanceCell()
    
    // MARK: - Private methods
    
    private var selectedDataSource: SearchDataSource {
        didSet {
            oldValue.updatingDelegate = nil

            if !shouldSelectAllText {
                switch (oldValue.searchStyle, selectedDataSource.searchStyle) {
                case (.search, .search):
                    let textField = searchField.textField
                    
                    // Generate a generic search
                    let search = Searchable(text: textField.text, options: nil, type: nil)
                    selectedDataSource.prefill(withSearchable: search)
                case (.search, .button) where searchField.isSelected:
                    searchField.isSelected = false
                case (.button, .search):
                    searchField.isSelected = true
                default: break
                }
            }

            navigationItem.rightBarButtonItem = selectedDataSource.navigationButton

            reloadCollectionViewRetainingEditing()

            if animateOnContentChanged {
                collectionView?.layoutIfNeeded()
            }

            reloadSearchStyle(shouldLayout: animateOnContentChanged)

            selectedDataSource.updatingDelegate = self
        }
    }
    
    private var animateOnContentChanged: Bool = false
    
    override func updateCalculatedContentHeight() {
        if calculatesContentHeight == false || isViewLoaded == false { return }

        if animateOnContentChanged {
            UIView.animate(withDuration: 0.3) {
                super.updateCalculatedContentHeight()
            }
        } else {
            super.updateCalculatedContentHeight()
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
    private var navBarExtensionTopConstraint: NSLayoutConstraint!

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
        
        if isViewLoaded {
            reloadSearchStyle()
            reloadCollectionViewRetainingEditing()
        }
    }

    func setCurrent(searchable: Searchable?) {
        guard let searchable = searchable else { return }
        
        if let index = dataSources?.index(where: { $0.prefill(withSearchable: searchable) }) {
            shouldSelectAllText = true
            tabStripView?.selectedItemIndex = index
            selectedDataSourceIndex = index
        }
    }
    
    // MARK - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = self.view, let collectionView = self.collectionView else { return }
        
        let pixel = 1.0 / traitCollection.currentDisplayScale
        searchSeparator.frame = CGRect(x: 0.0, y: -pixel, width: searchContainer.bounds.width, height: pixel)
        searchSeparator.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        searchSeparator.isHidden = true
        
        searchContainer.addSubview(searchSeparator)
        searchContainer.clipsToBounds = true
        
        searchField.layoutMargins = .zero
        buttonField.layoutMargins = .zero
        
        buttonField.actionButton.setTitleColor(tintColor, for: .normal)
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        buttonField.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchContainer)

        formLayout.wantsInsetHeaders = false
        
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

        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .always
            // We don't want the safe area to apply to search container, even though it uses layout margins
            searchContainer.insetsLayoutMarginsFromSafeArea = false

            // Manually apply a top offset for the nav bar extension, as safe area includes space for the bar itself
            navBarExtensionTopConstraint = navBarExtension.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        } else {
            // Simple, use layout guide which doesn't include legacy_additionalSafeAreaInsets
            navBarExtensionTopConstraint = navBarExtension.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
        }

        searchContainer.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        NSLayoutConstraint.activate([
            navBarExtension.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarExtension.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBarExtensionTopConstraint,

            searchContainer.topAnchor.constraint(equalTo: navBarExtension.bottomAnchor),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            searchField.heightAnchor.constraint(equalToConstant: SearchFieldCollectionViewCell.cellContentHeight),
            buttonField.heightAnchor.constraint(equalToConstant: SearchFieldAdvanceCell.cellContentHeight),

            NSLayoutConstraint(item: searchField, attribute: .width, relatedBy: .equal, toConstant: SearchFieldCollectionViewCell.preferredWidth, priority: UILayoutPriority.defaultHigh)
        ])

        reloadSearchStyle()
        
        var contentSize = collectionView.contentSize
        contentSize.height += (navigationBarExtension?.frame.height ?? 0.0) + searchContainer.frame.height
        preferredContentSize = contentSize
    }
    
    override func viewWillLayoutSubviews() {
        if #available(iOS 11, *) {
            // Move the collection view down below the nav bar extension and search container, using additionalSafeAreaInsets
            additionalSafeAreaInsets.top = (navigationBarExtension?.frame.height ?? 0.0) + searchContainer.frame.height

            // Move the nav bar extension to below the standard safeAreaInsets (ie not including our own)
            navBarExtensionTopConstraint.constant = view.safeAreaInsets.top - additionalSafeAreaInsets.top
        } else {
            legacy_additionalSafeAreaInsets.top = (navigationBarExtension?.frame.height ?? 0.0) + searchContainer.frame.height
        }
        super.viewWillLayoutSubviews()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let pixel = 1.0 / traitCollection.currentDisplayScale
        searchSeparator.frame = CGRect(x: 0.0, y: searchContainer.bounds.height - pixel, width: searchContainer.bounds.width, height:  pixel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch selectedDataSource.searchStyle {
        case .search:
            shouldSelectAllText = true
            searchField.isSelected = true
        default: break
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateOnContentChanged = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if searchField.isSelected {
           searchField.isSelected = false
        } else if let selectedItemIndexPath = collectionView?.indexPathsForSelectedItems?.first {
            collectionView?.deselectItem(at: selectedItemIndexPath, animated: false)
        }
    }
    
    private func reloadCollectionViewRetainingEditing() {
        guard let collectionView = self.collectionView else { return }
        
        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            if let cell = collectionView.cellForItem(at: selectedIndexPath) as? CollectionViewFormTextFieldCell {
                let selectedTextRange = cell.textField.selectedTextRange
                editingTextFieldIndexPath = (selectedIndexPath, selectedTextRange)
                return
            }
        }
        
        collectionView.reloadData()
    }
    
    private func reloadSearchStyle(shouldLayout force: Bool = false) {
        let style = selectedDataSource.searchStyle
        
        var force = force
        
        switch style {
        case .search(let configure, _, _):
            if force == false && buttonField.superview != nil {
                force = true
            }
            
            let textField = searchField.textField
            
            textField.keyboardType = .asciiCapable
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .no
            textField.returnKeyType = .search
            textField.attributedPlaceholder = nil
            
            searchField.additionalButtons = configure?(textField)
            
            if textField.allTargets.contains(self) == false {
                textField.addTarget(self, action: #selector(onTextDidChange(_:)), for: .editingChanged)
            }
            
            textField.delegate = self
            
            reloadSearchErrorMessage()
            
            prepareSearchField()
        case .button(let configure):
            if force == false && searchField.superview != nil {
                force = true
            }
            
            searchContainer.layoutMargins = style.preferredLayoutMargins
            
            let actionButton = buttonField.actionButton
            actionButton.allTargets.forEach { actionButton.removeTarget($0, action: nil, for: .allEvents) }
            
            configure?(actionButton)
            
            prepareButtonField()
        }
        
        if force {
            // Must resign and become first responder for any changes to the textfield to appear if it is currently the first responder.
            let textField = searchField.textField
            if textField.isFirstResponder && textField.resignFirstResponder() {
                textField.becomeFirstResponder()
            }
            
            searchContainer.setNeedsLayout()
            searchContainer.layoutIfNeeded()
        }
    }

    private func reloadSearchErrorMessage(animated: Bool = false) {
        switch selectedDataSource.searchStyle {
        case .search(_, _, let message):
            searchField.setRequiresValidation(message != nil, validationText: message, animated: animated)
            
            var errorHeight: CGFloat?
            
            var preferred = selectedDataSource.searchStyle.preferredLayoutMargins
            let current = searchContainer.layoutMargins
            
            if let message = message {
                let to = max(preferred.bottom, SearchFieldCollectionViewCell.heightForValidationAccessory(withText: message, contentWidth: searchField.contentView.bounds.width, compatibleWith: traitCollection) + 2.0)
                
                if current.bottom != to {
                    errorHeight = to
                }
            } else if current.bottom != preferred.bottom {
                errorHeight = preferred.bottom
            }
            
            if let height = errorHeight {
                preferred.bottom = height
                searchContainer.layoutMargins = preferred
                
                searchContainer.setNeedsLayout()
                searchContainer.layoutIfNeeded()
            }
        default: break
        }
    }
    
    // MARK: - Theme
    
    override func apply(_ theme: Theme) {
        super.apply(theme)
        
        searchContainer.backgroundColor = backgroundColor
        searchSeparator.backgroundColor = separatorColor
    }

    // MARK: - Action methods
    
    @objc private func cancelButtonItemDidSelect(_ item: UIBarButtonItem) {
        delegate?.searchOptionsControllerDidCancel(self)
    }

    // MARK: - UICollectionViewDataSource methods

    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ((selectedDataSource.options?.numberOfOptions ?? 0) > 0) ? 1 : 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch Section(rawValue: section)! {
        case .filters:
            return selectedDataSource.options?.numberOfOptions ?? 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            header.showsExpandArrow = false
            header.text = selectedDataSource.options!.headerText
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dataSource = self.selectedDataSource
        
        switch Section(rawValue: indexPath.section)! {
        case .filters:
            let filterIndex = indexPath.item
            
            let options = dataSource.options

            let isRequired = options!.isRequired(at: filterIndex)
            let title = options!.title(at: filterIndex)
            let value = options!.value(at: filterIndex)
            let placeholder = options!.defaultValue(at: filterIndex)
            let message = options!.errorMessage(at: filterIndex)
            
            switch options!.type(at: filterIndex) {
            case .picker:
                let filterCell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
                filterCell.isEditable = true
                filterCell.valueLabel.numberOfLines = 1
                filterCell.selectionStyle = UnderlineStyle.selection()
                filterCell.highlightStyle = FadeStyle.highlight()
                filterCell.accessoryView = FormAccessoryView(style: .dropDown)
                
                filterCell.titleLabel.text = title
                filterCell.valueLabel.text = value
                filterCell.placeholderLabel.text = placeholder
                filterCell.setRequiresValidation(message != nil || isRequired, validationText: message, animated: false)
                
                return filterCell
            case .text(let configure):
                let filterCell = collectionView.dequeueReusableCell(of: CollectionViewFormTextFieldCell.self, for: indexPath)
                filterCell.selectionStyle = UnderlineStyle.selection()
                filterCell.highlightStyle = FadeStyle.highlight()
                
                let textField = filterCell.textField
                configure?(textField)
                
                textField.text = value
                textField.placeholder = placeholder
                
                if textField.allTargets.contains(self) == false {
                    textField.addTarget(self, action: #selector(onTextDidChange(_:)), for: .editingChanged)
                }
                
                textField.delegate = self
                
                filterCell.titleLabel.text = title
                filterCell.setRequiresValidation(message != nil || isRequired, validationText: message, animated: false)
                
                return filterCell
            case .action(let image, let buttonTitle, let buttonHandler):
                let filterCell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
                
                filterCell.style = .value
                filterCell.selectionStyle = .none
                filterCell.highlightStyle = FadeStyle.highlight()
                filterCell.accessoryView  = FormAccessoryView(style: .disclosure)
                filterCell.imageView.image = image
                filterCell.titleLabel.text = title
                filterCell.subtitleLabel.text = value ?? placeholder
                filterCell.setRequiresValidation(message != nil || isRequired, validationText: message, animated: false)
             
                if let title = buttonTitle, let handler = buttonHandler {
                    filterCell.editActions = [CollectionViewFormEditAction(title: title, color: tintColor, handler: { (_, _) in
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
            if let textField = (cell as? CollectionViewFormTextFieldCell)?.textField, !textField.isFirstResponder {
                
                textField.becomeFirstResponder()
                textField.selectedTextRange = editingTextFieldIndexPath?.textRange
            }
            
            editingTextFieldIndexPath = nil
        }
    }
    
    // MARK: - CollectionViewDelegateFormLayout methods
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForValidationAccessoryAt indexPath: IndexPath, givenContentWidth contentWidth: CGFloat) -> CGFloat {

        switch Section(rawValue: indexPath.section)! {
        case .filters:
            let message = selectedDataSource.options!.errorMessage(at: indexPath.item)
            if let errorMessage = message {
                return CollectionViewFormCell.heightForValidationAccessory(withText: errorMessage, contentWidth: contentWidth, compatibleWith: traitCollection)
            }
        }

        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForFooterInSection section: Int) -> CGFloat {
        return layout.itemLayoutMargins.bottom
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return 21.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {

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
        
        navigationItem.rightBarButtonItem = selectedDataSource.navigationButton
        
        switch component {
        case .all:
            reloadSearchStyle()
            reloadCollectionViewRetainingEditing()
        case .searchStyle:
            reloadSearchStyle()
        case .searchStyleErrorMessage:
            reloadSearchErrorMessage(animated: true)
        case .filterErrorMessage(let index):
            let indexPath = IndexPath(item: index, section: Section.filters.rawValue)

            if let cell = self.collectionView?.cellForItem(at: indexPath) as? CollectionViewFormCell {
                let message = selectedDataSource.options?.errorMessage(at: index)
                let isRequired = selectedDataSource.options?.isRequired(at: index)
                cell.setRequiresValidation(message != nil || isRequired == true, validationText: message, animated: true)
            }
        case .filterErrorMessages(let indexes):
            let indexPaths = indexes.map { IndexPath(item: $0, section: Section.filters.rawValue) }

            for indexPath in indexPaths {
                if let cell = self.collectionView?.cellForItem(at: indexPath) as? CollectionViewFormCell {
                    let message = selectedDataSource.options?.errorMessage(at: indexPath.row)
                    let isRequired = selectedDataSource.options?.isRequired(at: indexPath.row)
                    cell.setRequiresValidation(message != nil || isRequired == true, validationText: message, animated: true)
                }
            }
        case .filter(_):
            reloadCollectionViewRetainingEditing()
        }
    }
    
    func searchDataSource(_ dataSource: SearchDataSource, didFinishWith search: Searchable?, andResultViewModel viewModel: SearchResultModelable?) {
        // Pass it on to someone that cares
        delegate?.searchOptionsController(self, didFinishWith: search, andResultViewModel: viewModel)
    }
    
    // MARK: - TabStripViewDelegate
    
    func tabStripView(_ tabStripView: TabStripView, didSelectItemAt index: Int) {
        selectedDataSourceIndex = index
        collectionView?.endEditing(true)
    }
    
    // MARK: - Private
    
    private enum Section: Int {
        case filters
    }
    
    private func notifyTextChanged(textField: UITextField, didEndEditing: Bool) {

        // Check the main search field
        if searchField.textField == textField {
            switch selectedDataSource.searchStyle {
            case .search(_, let textHandler, _):
                textHandler?(textField.text, didEndEditing)
            default: break
            }
        }


        // Checks collection view for active text field
        guard let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first else {
            return
        }

        switch Section(rawValue: selectedIndexPath.section)! {
        case .filters:
            let item = selectedIndexPath.item
            selectedDataSource.textChanged(forFilterAt: item, text: textField.text, didEndEditing: didEndEditing)
        }
    }
    
    @objc private func onTextDidChange(_ textField: UITextField) {
        notifyTextChanged(textField: textField, didEndEditing: false)
    }
    
    private func prepareSearchField() {
        if searchField.superview == nil {
            searchContainer.addSubview(searchField)
            buttonField.removeFromSuperview()
            
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: searchField, attribute: .top, relatedBy: .equal, toItem: searchContainer, attribute: .topMargin, constant: 0.0),
                NSLayoutConstraint(item: searchField, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: searchContainer, attribute: .leadingMargin, constant: 0.0),
                NSLayoutConstraint(item: searchField, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: searchContainer, attribute: .trailingMargin, constant: 0.0),
                NSLayoutConstraint(item: searchField, attribute: .bottom, relatedBy: .equal, toItem: searchContainer, attribute: .bottomMargin, constant: 0.0),
                NSLayoutConstraint(item: searchField, attribute: .centerX, relatedBy: .equal, toItem: searchContainer, attribute: .centerX, constant: 0.0)
            ])
        }
    }
    
    private func prepareButtonField() {
        if searchField.isSelected {
            searchField.isSelected = false
        }
        
        if buttonField.superview == nil {
            searchField.removeFromSuperview()
            searchContainer.addSubview(buttonField)
            
            NSLayoutConstraint.activate([
                buttonField.topAnchor.constraint(equalTo: searchContainer.layoutMarginsGuide.topAnchor),
                buttonField.leadingAnchor.constraint(equalTo: searchContainer.layoutMarginsGuide.leadingAnchor),
                buttonField.trailingAnchor.constraint(equalTo: searchContainer.layoutMarginsGuide.trailingAnchor),
                buttonField.bottomAnchor.constraint(equalTo: searchContainer.layoutMarginsGuide.bottomAnchor)
            ])
        }
    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if shouldSelectAllText {
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
            shouldSelectAllText = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        notifyTextChanged(textField: textField, didEndEditing: true)
        textField.resignFirstResponder()
        return false
    }
    
    
    // MARK: - ScrollViewDelegate
    
    private enum SeparatorAnimation {
        case none
        case showing
        case hiding
    }
    
    private var separatorAnimation: SeparatorAnimation = .none
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let separatorHidden = (scrollView.contentOffset.y + scrollView.contentInset.top) <= 0.0
     
        if searchSeparator.isHidden != separatorHidden {
            if separatorHidden && separatorAnimation != .hiding {
                separatorAnimation = .hiding
                
                searchSeparator.alpha = 1.0
                UIView.animate(withDuration: 0.3, animations: {
                    self.searchSeparator.alpha = 0.0
                }, completion: { _ in
                    self.searchSeparator.isHidden = separatorHidden
                    self.separatorAnimation = .none
                })
            } else if !separatorHidden && separatorAnimation != .showing {
                separatorAnimation = .showing
                
                searchSeparator.isHidden = false
                searchSeparator.alpha = 0.0
                UIView.animate(withDuration: 0.3, animations: {
                    self.searchSeparator.alpha = 1.0
                }, completion: { _ in
                    self.separatorAnimation = .none
                })
            }
        }
    }
    
}

protocol SearchOptionsViewControllerDelegate: class {

    func searchOptionsController(_ controller: SearchOptionsViewController, didFinishWith searchable: Searchable?, andResultViewModel viewModel: SearchResultModelable?)

    func searchOptionsControllerDidCancel(_ controller: SearchOptionsViewController)

}

private extension SearchFieldStyle {
    
    var preferredLayoutMargins: UIEdgeInsets {
        switch self {
        case .search: return UIEdgeInsets(top: 8.0, left: 24.0, bottom: 32.0, right: 16.0)
        case .button: return UIEdgeInsets(top: 20.0, left: 24.0, bottom: 20.0, right: 16.0)
        }
    }
    
}
