//
//  FormCollectionViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


private let tempID = "temp"

open class FormCollectionViewController: UIViewController, PopoverViewController {
    
    open let formLayout: CollectionViewFormMPOLLayout
    
    open fileprivate(set) var collectionView: UICollectionView?
    
    open var wantsTransparentBackground: Bool = false {
        didSet {
            if isViewLoaded {
                collectionView?.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
            }
        }
    }
    
    @NSCopying open var tintColor:            UIColor?
    @NSCopying open var backgroundColor:      UIColor?
    @NSCopying open var selectionColor:       UIColor?
    
    @NSCopying open var sectionTitleColor:    UIColor?
    
    @NSCopying open var primaryTextColor:     UIColor?
    @NSCopying open var secondaryTextColor:   UIColor?
    @NSCopying open var placeholderTextColor: UIColor?
    
    fileprivate var collectionViewInsetManager: ScrollViewInsetManager?
    
    
    public init() {
        formLayout = CollectionViewFormMPOLLayout()
        formLayout.itemLayoutMargins = UIEdgeInsets(top: 16.0, left: 24.0, bottom: 16.0, right: 16.0)
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false // we manage this ourselves.
        
        NotificationCenter.default.addObserver(self, selector: #selector(applyCurrentTheme), name: .ThemeDidChange, object: nil)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
}


/// View lifecycle
extension FormCollectionViewController {
    
    open dynamic override func loadView() {
        let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: formLayout)
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
        collectionView.alwaysBounceVertical = true
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: collectionElementKindGlobalHeader,    withReuseIdentifier: tempID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: collectionElementKindGlobalFooter,    withReuseIdentifier: tempID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: tempID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: tempID)
        
        self.collectionViewInsetManager = ScrollViewInsetManager(scrollView: collectionView)
        self.collectionView = collectionView
        self.view = collectionView
    }
    
    open dynamic override func viewDidLoad() {
        super.viewDidLoad()
        applyCurrentTheme()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentInsets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        collectionViewInsetManager?.standardContentInset    = contentInsets
        collectionViewInsetManager?.standardIndicatorInset  = contentInsets
    }
    
    open dynamic override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if wantsTransparentBackground == false,
            let collectionView = self.collectionView,
            let superview = collectionView.superview {
            let backgroundColor = superview.backgroundColor
            superview.backgroundColor = collectionView.backgroundColor
            
            coordinator.animate(alongsideTransition: nil, completion: { (context: UIViewControllerTransitionCoordinatorContext) in
                superview.backgroundColor = backgroundColor
            })
        }
    }
    
    public dynamic func applyCurrentTheme() {
        let colors = Theme.current.colors
        
        formLayout.itemSeparatorColor = colors[.Separator]
        backgroundColor      = colors[.Background]
        selectionColor       = colors[.CellSelection]
        primaryTextColor     = colors[.PrimaryText]
        secondaryTextColor   = colors[.SecondaryText]
        placeholderTextColor = colors[.PlaceholderText]
        
        setNeedsStatusBarAppearanceUpdate()
        
        if isViewLoaded,
            let collectionView = self.collectionView {
            collectionView.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
            for cell in collectionView.visibleCells {
                self.collectionView(collectionView, willDisplay: cell, forItemAt: collectionView.indexPath(for: cell)!)
            }
            
            if let globalHeader = collectionView.visibleSupplementaryViews(ofKind: collectionElementKindGlobalHeader).first {
                self.collectionView(collectionView, willDisplaySupplementaryView: globalHeader, forElementKind: collectionElementKindGlobalHeader, at: IndexPath(index: 0))
            }
            if let globalFooter = collectionView.visibleSupplementaryViews(ofKind: collectionElementKindGlobalFooter).first {
                self.collectionView(collectionView, willDisplaySupplementaryView: globalFooter, forElementKind: collectionElementKindGlobalFooter, at: IndexPath(index: 0))
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
    }
}

extension FormCollectionViewController: UICollectionViewDataSource {
    
    open dynamic func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    open dynamic func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Subclasses must override this method, and must not call super.")
    }
    
    open dynamic func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let defaultView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: tempID, for: indexPath)
        defaultView.isUserInteractionEnabled = false
        return defaultView
    }
    
}


/// Collection view delegate
extension FormCollectionViewController: UICollectionViewDelegate {
    
    open dynamic func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.selectedBackgroundView?.backgroundColor = selectionColor ?? #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        switch cell {
        case let formCell as EntityCollectionViewCell:
            formCell.titleLabel.textColor    = primaryTextColor
            formCell.subtitleLabel.textColor = secondaryTextColor
            formCell.detailLabel.textColor   = secondaryTextColor
        case let detailCell as CollectionViewFormDetailCell:
            if detailCell.emphasis == .title {
                detailCell.textLabel.textColor       = primaryTextColor
                detailCell.detailTextLabel.textColor = secondaryTextColor
            } else {
                detailCell.textLabel.textColor       = secondaryTextColor
                detailCell.detailTextLabel.textColor = primaryTextColor
            }
            
            guard let title = detailCell.textLabel.text as NSString? else { return }
            
            let rangeOfStar = title.range(of: "*")
            if rangeOfStar.location == NSNotFound { return }
            
            let titleString = NSMutableAttributedString(string: title as String)
            titleString.setAttributes([NSForegroundColorAttributeName: UIColor.red], range: rangeOfStar)
            detailCell.textLabel.attributedText = titleString
        case let textFieldCell as CollectionViewFormTextFieldCell:
            textFieldCell.titleLabel.textColor = secondaryTextColor
            textFieldCell.textField.textColor  = primaryTextColor
            textFieldCell.textField.placeholderTextColor = placeholderTextColor
            
            guard let title = textFieldCell.titleLabel.text as NSString? else { return }
            
            let rangeOfStar = title.range(of: "*")
            if rangeOfStar.location == NSNotFound { return }
            
            let titleString = NSMutableAttributedString(string: title as String)
            titleString.setAttributes([NSForegroundColorAttributeName: UIColor.red], range: rangeOfStar)
            textFieldCell.titleLabel.attributedText = titleString
        case let textViewCell as CollectionViewFormTextViewCell:
            textViewCell.titleLabel.textColor       = secondaryTextColor
            textViewCell.textView.textColor         = primaryTextColor
            textViewCell.textView.placeholderLabel.textColor = placeholderTextColor
            
            guard let title = textViewCell.titleLabel.text as NSString? else { return }
            
            let rangeOfStar = title.range(of: "*")
            if rangeOfStar.location == NSNotFound { return }
            
            let titleString = NSMutableAttributedString(string: title as String)
            titleString.setAttributes([NSForegroundColorAttributeName: UIColor.red], range: rangeOfStar)
            textViewCell.titleLabel.attributedText = titleString
        default:
            break
        }
    }
    
    open dynamic func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
    }
    
}


/// Collection view delegate MPOL layout
extension FormCollectionViewController: CollectionViewDelegateMPOLLayout {
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return 0.0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForFooterInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return 0.0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int, givenSectionWidth width: CGFloat) -> UIEdgeInsets {
        return .zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        return sectionWidth
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        return 39.0
    }
    
}


/// Status bar support
extension FormCollectionViewController {
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return Theme.current.statusBarStyle
    }
    
    open override var prefersStatusBarHidden : Bool {
        return false
    }
}
