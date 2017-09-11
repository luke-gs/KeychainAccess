//
//  SearchHelpTagCollectionView.swift
//  Pods
//
//  Created by Megan Efron on 9/9/17.
//
//

import UIKit

public class SearchHelpTagCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    // MARK: - Properties
    
    private let tags: [String]
    private let layout: LeftAlignedCollectionViewFlowLayout
    
    private let widthInset: CGFloat = 10.0
    private let heightInset: CGFloat = 5.0
    
    
    // MARK: - Lifecycle

    public init(tags: [String]) {
        self.tags = tags
        self.layout = LeftAlignedCollectionViewFlowLayout()
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        layout.minimumInteritemSpacing = 5.0
        layout.minimumLineSpacing = 5.0
        
        dataSource = self
        delegate = self
        backgroundColor = .clear
        register(SearchHelpTagCollectionViewCell.self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: SearchHelpTagCollectionViewCell.self, for: indexPath)
        cell.label.text = tags[indexPath.row]
        
        let theme = ThemeManager.shared.theme(for: .current)
        let color = theme.color(forKey: .tint)!
        
        cell.contentView.backgroundColor = color.withAlphaComponent(0.1)
        cell.contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        cell.label.textColor = color.withAlphaComponent(1.0)
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let string = tags[indexPath.row]
        let font = SearchHelpTagCollectionViewCell.font
        
        let height = font.lineHeight + (heightInset * 2)
        let size = (string as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: height),
                                                     options: .usesLineFragmentOrigin,
                                                     attributes: [NSFontAttributeName: font],
                                                     context: nil)
        let width = size.width + (widthInset * 2)
        return CGSize(width: width, height: height)
    }
    
    
    // MARK: - Autolayout
    
    public override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    public override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    public override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }

}
