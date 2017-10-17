//
//  NotBookedOnViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class NotBookedOnViewController: CADFormCollectionViewController<NotBookedOnItem> {

    public var titleLabel: UILabel!
    public var stayOffDutyButton: UIButton!
    public var allCallsignsButton: UIButton!
    
    public var notBookedOnViewModel: NotBookedOnViewModel? {
        return viewModel as? NotBookedOnViewModel
    }
    
    public init(viewModel: NotBookedOnViewModel) {
        super.init(viewModel: viewModel)
//        calculatesContentHeight = true
        if #available(iOS 11, *) {
            additionalSafeAreaInsets.top = 100
            additionalSafeAreaInsets.bottom = 55
        } else {
            legacy_additionalSafeAreaInsets.top = 100
            legacy_additionalSafeAreaInsets.bottom = 55
        }
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.text = notBookedOnViewModel?.headerText()
        titleLabel.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        stayOffDutyButton = UIButton()
        stayOffDutyButton.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        stayOffDutyButton.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        stayOffDutyButton.setTitle(notBookedOnViewModel?.stayOffDutyButtonText(), for: .normal)
        stayOffDutyButton.addTarget(self, action: #selector(didSelectStayOffDutyButton), for: .touchUpInside)
        stayOffDutyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stayOffDutyButton)
        
        allCallsignsButton = UIButton()
        allCallsignsButton.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        allCallsignsButton.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        allCallsignsButton.setTitle(notBookedOnViewModel?.allCallsignsButtonText(), for: .normal)
        allCallsignsButton.addTarget(self, action: #selector(didSelectAllCallsignsButton), for: .touchUpInside)
        allCallsignsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(allCallsignsButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            stayOffDutyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            stayOffDutyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stayOffDutyButton.heightAnchor.constraint(equalToConstant: 15),
            
            allCallsignsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            allCallsignsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            allCallsignsButton.heightAnchor.constraint(equalToConstant: 15),
        ])
    }
    
    @objc public func didSelectStayOffDutyButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc public func didSelectAllCallsignsButton() {
        // TODO:
    }
    
    // MARK: - Override
    
    override open func cellType() -> CollectionViewFormCell.Type {
        return CollectionViewFormSubtitleCell.self
    }
    
    override open func decorate(cell: CollectionViewFormCell, with viewModel: NotBookedOnItem) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .indented
        cell.accessoryView = FormAccessoryView(style: .disclosure)
        
        if let cell = cell as? CollectionViewFormSubtitleCell {
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.imageView.image = viewModel.image
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // TODO: present details?
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let _ = viewModel.item(at: indexPath) {
            return EntityListCollectionViewCell.minimumContentHeight(compatibleWith: traitCollection)
        }
        return 0
    }

}
