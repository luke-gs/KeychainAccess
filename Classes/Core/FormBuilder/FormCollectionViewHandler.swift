//
//  FormCollectionViewHandler.swift
//  Alamofire
//
//  Created by KGWH78 on 11/12/17.
//

import Foundation
import UIKit

open class FormCollectionViewHandler: NSObject, UICollectionViewDataSource, CollectionViewDelegateFormLayout {

    open private(set) var globalHeader: FormItem?

    open private(set) var sections: [FormSection] = []

    open weak var viewController: UIViewController?

    open var sectionInsets = UIEdgeInsets(top: 0.0, left: 24.0, bottom: 0.0, right: 16.0)

    open var forceLinearLayout: Bool = false

    public init(sections: [FormSection], globalHeader: FormItem?) {
        self.sections = sections
        self.globalHeader = globalHeader

        super.init()

        if userInterfaceStyle == .current {
            NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        }
    }

    open weak var collectionView: UICollectionView?

    open var userInterfaceStyle: UserInterfaceStyle = .current {
        didSet {
            if userInterfaceStyle == oldValue { return }

            if userInterfaceStyle == .current {
                NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
            } else if oldValue == .current {
                NotificationCenter.default.removeObserver(self, name: .interfaceStyleDidChange, object: nil)
            }

            collectionView?.apply(ThemeManager.shared.theme(for: userInterfaceStyle))
        }
    }

    open func registerWithCollectionView(_ collectionView: UICollectionView) {
        self.collectionView = collectionView

        collectionView.delegate = self
        collectionView.dataSource = self

        var supplementaryRegistrations = [(UICollectionReusableView.Type, String, String)]()

        if let globalHeader = globalHeader as? BaseSupplementaryFormItem {
            supplementaryRegistrations.append((globalHeader.viewType, globalHeader.kind, globalHeader.reuseIdentifier))
        }

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
            collectionView.register(item.0, forSupplementaryViewOfKind: item.1, withReuseIdentifier: item.2)
        }

        for item in cellRegistrations {
            collectionView.register(item.0, forCellWithReuseIdentifier: item.1)
        }
    }

    // MARK: - UICollectionViewDelegate

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
        let section = sections[indexPath.section]

        switch kind {
        case UICollectionElementKindSectionHeader:
            if let item = section.formHeader as? BaseSupplementaryFormItem {
                let view = item.view(in: collectionView, for: indexPath)

                if let item = item as? HeaderFormItem, let headerView = view as? CollectionViewFormHeaderView {
                    headerView.tapHandler = { cell, indexPath in
                        switch item.style {
                        case .collapsible:
                            item.isExpanded = !item.isExpanded
                            cell.setExpanded(item.isExpanded, animated: true)
                            collectionView.reloadSections(IndexSet(integer: indexPath.section))
                        case .plain:
                            break
                        }
                    }
                }

                return view
            }
        case UICollectionElementKindSectionFooter:
            if let item = section.formFooter as? BaseSupplementaryFormItem {
                let view = item.view(in: collectionView, for: indexPath)
                return view
            }
        case collectionElementKindGlobalHeader:
            if let item = globalHeader as? BaseSupplementaryFormItem {
                return item.view(in: collectionView, for: indexPath)
            }
        default:
            break
        }

        return UICollectionReusableView()
    }

    open func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        if let item = globalHeader as? BaseSupplementaryFormItem {
            return item.intrinsicHeight(in: collectionView, layout: layout, for: collectionView.traitCollection)
        }
        return 0.0
    }

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        if let item = sections[section].formHeader as? BaseSupplementaryFormItem {
            return item.intrinsicHeight(in: collectionView, layout: layout, for: collectionView.traitCollection)
        }
        return 0.0
    }

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForFooterInSection section: Int) -> CGFloat {
        if let item = sections[section].formFooter as? BaseSupplementaryFormItem {
            return item.intrinsicHeight(in: collectionView, layout: layout, for: collectionView.traitCollection)
        }
        return 0.0
    }

    // MARK: - UICollectionViewDelegate methods

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let item = sections[indexPath] as? BaseFormItem else { return }

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
        guard let item = sections[indexPath] as? BaseFormItem else { return }

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

            action.dismissHandler = { [unowned action] in
                collectionView.deselectItem(at: indexPath, animated: true)
                action.dismissHandler = nil
            }

            if viewController.modalPresentationStyle == .none {
                self.viewController?.navigationController?.pushViewController(viewController, animated: true)
            } else {
                self.viewController?.present(viewController, animated: true, completion: nil)
            }
        }

        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewFormCell {
            item.onSelection?(cell)
        }
    }

    // MARK: - UICollectionViewDataSource

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        if forceLinearLayout {
            return collectionView.bounds.width
        }

        let item = sections[indexPath] as! BaseFormItem
        return item.minimumContentWidth(in: collectionView, layout: layout, sectionEdgeInsets: sectionEdgeInsets, for: collectionView.traitCollection)
    }

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let item = sections[indexPath] as! BaseFormItem
        return item.minimumContentHeight(in: collectionView, layout: layout, givenContentWidth: itemWidth, for: collectionView.traitCollection)
    }

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForValidationAccessoryAt indexPath: IndexPath, givenContentWidth contentWidth: CGFloat) -> CGFloat {
        let item = sections[indexPath] as! BaseFormItem
        return item.heightForValidationAccessory(givenContentWidth: contentWidth, for: collectionView.traitCollection)
    }

    @objc private func interfaceStyleDidChange() {
        if userInterfaceStyle != .current { return }
        collectionView?.apply(ThemeManager.shared.theme(for: userInterfaceStyle))
    }

}


extension UICollectionView {

    open func apply(_ theme: Theme) {
        guard let delegate = delegate else { return }

        for cell in visibleCells {
            if let indexPath = indexPath(for: cell) {
                delegate.collectionView?(self, willDisplay: cell, forItemAt: indexPath)
            }
        }

        if let globalHeader = visibleSupplementaryViews(ofKind: collectionElementKindGlobalHeader).first {
            delegate.collectionView?(self, willDisplaySupplementaryView: globalHeader, forElementKind: collectionElementKindGlobalHeader, at: IndexPath(item: 0, section: 0))
        }
        if let globalFooter = visibleSupplementaryViews(ofKind: collectionElementKindGlobalFooter).first {
            delegate.collectionView?(self, willDisplaySupplementaryView: globalFooter, forElementKind: collectionElementKindGlobalFooter, at: IndexPath(item: 0, section: 0))
        }

        let sectionHeaderIndexPaths = indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader)
        for indexPath in sectionHeaderIndexPaths {
            if let headerView = supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) {
                delegate.collectionView?(self, willDisplaySupplementaryView: headerView, forElementKind: UICollectionElementKindSectionHeader, at: indexPath)
            }
        }

        let sectionFooterIndexPaths = indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionFooter)
        for indexPath in sectionFooterIndexPaths {
            if let footerView = supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: indexPath) {
                delegate.collectionView?(self, willDisplaySupplementaryView: footerView, forElementKind: UICollectionElementKindSectionFooter, at: indexPath)
            }
        }
    }

}
