//
//  SearchCollectionViewCell.swift
//  Pods
//
//  Created by Valery Shorinov on 29/3/17.
//
//

import UIKit
import MPOLKit


public class SearchCollectionViewCell: CollectionViewFormCell, UITextFieldDelegate {
    
    public var searchSources : [SearchType] = [] {
        didSet {
                sourceSegmentationController.removeAllSegments()
            
                let sources = searchSources.map{$0.title}
            
                let selectedIndex = sourceSegmentationController.selectedSegmentIndex
                var index = 0
                for title in sources {
                    sourceSegmentationController.insertSegment(withTitle: title, at: index, animated: false)
                    sourceSegmentationController.setWidth(120.0, forSegmentAt: index)
                    index += 1
            }
            
            if selectedIndex > sourceSegmentationController.numberOfSegments || selectedIndex < 0 {
                sourceSegmentationController.selectedSegmentIndex = 0
            } else {
                sourceSegmentationController.selectedSegmentIndex = selectedIndex
            }
        }
    }
    
    public weak var searchCollectionViewCellDelegate: SearchCollectionViewCellDelegate?
    
    public var searchTextField = UITextField(frame: .zero)
    
    public var sourceSegmentationController = UISegmentedControl(frame: .zero)
    
    public var infoButton = UIButton(type: .infoLight)
    
    public var searchBarUnderline = UIView(frame: .zero)
    private var searchBarUnderlineHeightContraint: NSLayoutConstraint!
    
    private var sourceSegmentationControllerWidthContraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        let vPadding : CGFloat = 20.0
        let hPadding : CGFloat = 15.0
        
        sourceSegmentationController.selectedSegmentIndex = 0
        sourceSegmentationController.apportionsSegmentWidthsByContent = true
        sourceSegmentationController.translatesAutoresizingMaskIntoConstraints = false
        sourceSegmentationController.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightRegular)], for: .normal)
        
        sourceSegmentationController.addTarget(self, action: #selector(segmentControllerIndexChanged(_:)), for: .valueChanged)
        
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.addTarget(self, action: #selector(infoButtonTriggered(_:)), for: .primaryActionTriggered)
        
        searchTextField.textAlignment = .center
        searchTextField.font = UIFont.systemFont(ofSize: 20.0, weight: UIFontWeightHeavy)
        searchTextField.textColor = UIColor.darkGray
        searchTextField.attributedPlaceholder = NSAttributedString.init(string: "Search", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20.0, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor.lightGray])
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.delegate = self
        
        searchBarUnderline.backgroundColor = UIColor.lightGray
        searchBarUnderline.translatesAutoresizingMaskIntoConstraints = false
        searchBarUnderlineHeightContraint = NSLayoutConstraint(item: searchBarUnderline, attribute: .height, relatedBy: .equal, toConstant: 1.0)

        let contentView = self.contentView
        contentView.addSubview(sourceSegmentationController)
        contentView.addSubview(infoButton)
        contentView.addSubview(searchTextField)
        contentView.addSubview(searchBarUnderline)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: sourceSegmentationController, attribute: .centerX, relatedBy: .equal, toItem:self.contentView, attribute: .centerX),
            NSLayoutConstraint(item: sourceSegmentationController, attribute: .top, relatedBy: .equal, toItem:self.contentView, attribute: .top, multiplier: 1.0, constant: vPadding),
            
            NSLayoutConstraint(item: infoButton, attribute: .left, relatedBy: .equal, toItem:sourceSegmentationController, attribute: .right, multiplier: 1.0, constant: hPadding),
            NSLayoutConstraint(item: infoButton, attribute: .centerY, relatedBy: .equal, toItem:sourceSegmentationController, attribute: .centerY),
            
            NSLayoutConstraint(item: searchTextField, attribute: .centerX, relatedBy: .equal, toItem:self.contentView, attribute: .centerX),
            NSLayoutConstraint(item: searchTextField, attribute: .width, relatedBy: .greaterThanOrEqual, toConstant: 480.0),
            NSLayoutConstraint(item: searchTextField, attribute: .top, relatedBy: .equal, toItem:sourceSegmentationController, attribute: .bottom, multiplier: 1.0, constant: vPadding),
            
            NSLayoutConstraint(item: searchBarUnderline, attribute: .left, relatedBy: .equal, toItem:searchTextField, attribute: .left),
            NSLayoutConstraint(item: searchBarUnderline, attribute: .right, relatedBy: .equal, toItem:searchTextField, attribute: .right),
            NSLayoutConstraint(item: searchBarUnderline, attribute: .top, relatedBy: .equal, toItem:searchTextField, attribute: .bottom, multiplier: 1.0, constant: 5.0),
            searchBarUnderlineHeightContraint
        ])
    }
    
    static public func cellHeight() -> CGFloat { return 70.0 }
    
    @objc func infoButtonTriggered(_ : UIButton) {
        print("Info button triggered")
    }
    
    @objc func segmentControllerIndexChanged(_ : UISegmentedControl) {
        
        searchCollectionViewCellDelegate?.searchCollectionViewCell(self, didSelectSegmentAt: sourceSegmentationController.selectedSegmentIndex)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text!
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if updatedText.isEmpty {
            searchBarUnderline.backgroundColor = UIColor.lightGray
            searchBarUnderlineHeightContraint.constant = 1.0
        } else {
            searchBarUnderline.backgroundColor = searchTextField.tintColor
            searchBarUnderlineHeightContraint.constant = 2.0
        }
        
        searchCollectionViewCellDelegate?.searchCollectionViewCell(self, didChangeText: updatedText)
        
        return true
    }
    
    public func hideKeyboard() {
        if searchTextField.isFirstResponder {
            searchTextField.resignFirstResponder()
        }
    }
}

public protocol SearchCollectionViewCellDelegate: class {
    
    func searchCollectionViewCell(_ cell: SearchCollectionViewCell, didChangeText text: String?)
    
    func searchCollectionViewCell(_ cell: SearchCollectionViewCell, didSelectSegmentAt index: Int)
}
