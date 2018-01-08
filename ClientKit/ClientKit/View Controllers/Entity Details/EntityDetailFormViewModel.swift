//
//  EntityDetailFormViewModel.swift
//  ClientKit
//
//  Created by Megan Efron on 8/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

/// A delegate for updating the view (PopoverPresenter so we can present new views from view model)
public protocol EntityDetailFormViewModelDelegate: PopoverPresenter {
    
    /// Update the sidebar count
    func updateSidebarItemCount(_ count: UInt?)
    
    /// Update content loading state
    func updateLoadingState(_ state: LoadingStateManager.State)
    
    /// Refresh content
    func reloadData()
    
    /// Update sidebar alert color
    func updateSidebarAlertColor(_ color: UIColor?)
    
    /// Update no content details, the title and subtitle
    func updateNoContentDetails(title: String?, subtitle: String?)
    
    /// Update bar buttons
    func updateBarButtonItems()
}

/// A blank implementation to avoid optional def in the protocol
extension EntityDetailFormViewModelDelegate {
    public func updateSidebarItemCount(_ count: UInt?) { }
    public func updateLoadingState(_ state: LoadingStateManager.State) { }
    public func reloadData() { }
    public func updateSidebarAlertColor(_ color: UIColor?) { }
    public func updateNoContentDetails(title: String? = nil, subtitle: String? = nil) { }
    public func updateBarButtonItems() { }
}

/// Abstract view model to support `EntityDetailFormViewController`
open class EntityDetailFormViewModel {

    /// The delegate.
    open weak var delegate: EntityDetailFormViewModelDelegate?
    
    /// The entity delegate.
    public weak var entityDetailsDelegate: EntityDetailsDelegate?
    
    /// The entity to display.
    open var entity: Entity? {
        didSet {
            delegate?.updateLoadingState(entity == nil ? .noContent : .loaded)
            delegate?.updateSidebarItemCount(sidebarCount)
            delegate?.updateNoContentDetails()
            delegate?.reloadData()
        }
    }
    
    /// The view controllers title.
    open var title: String? {
        return nil
    }
    
    /// The left bar button items for the view controller.
    open var leftBarButtonItems: [UIBarButtonItem]? {
        return nil
    }
    
    /// The right bar button items for the view controller.
    open var rightBarButtonItems: [UIBarButtonItem]? {
        return nil
    }
    
    /// Specifies how to construct form in VC.
    open func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        MPLRequiresConcreteImplementation()
    }
    
    /// The sidebar title in regular size class.
    open var regularTitle: String? {
        return title
    }
    
    /// The sidebar title in compact size class.
    open var compactTitle: String? {
        return title
    }
    
    /// Loading manager's no content title.
    open var noContentTitle: String? {
        return nil
    }
    
    /// Loading manager's no content subtitle.
    open var noContentSubtitle: String? {
        return nil
    }
    
    /// Loading manager's no content subtitle.
    open var sidebarImage: UIImage? {
        return nil
    }
    
    /// The count on the sidebar.
    open var sidebarCount: UInt? {
        return nil
    }
    
    /// Gets called when the view controller's trait collection changes.
    open func traitCollectionDidChange(_ traitCollection: UITraitCollection, previousTraitCollection: UITraitCollection?) {
        // Override to provide implementation
    }
    
    open func displaysCompact(in controller: FormBuilderViewController) -> Bool {
        let formLayout = controller.formLayout
        let collectionView = controller.collectionView
        let itemInsets = formLayout.itemLayoutMargins
        let horizontalInsets = UIEdgeInsets(top: 0,
                                            left: collectionView?.layoutMargins.left ?? 0,
                                            bottom: 0,
                                            right: collectionView?.layoutMargins.right ?? 0)
        let calculatedWidth = formLayout.collectionViewContentSize.width - itemInsets.left - itemInsets.right - horizontalInsets.left - horizontalInsets.right
        
        return EntityDetailCollectionViewCell.displaysAsCompact(withContentWidth: calculatedWidth)
    }

}
