//
//  SearchNumberRangePickerViewController.swift
//  MPOL
//
//  Created by Valery Shorinov on 11/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
fileprivate var kvoContext = 1

class SearchNumberRangePickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var numberRangePickerDelegate: NumberRangePickerDelegate?
    
    public var minValue: Int
    public var maxValue: Int
    
    public var linkedSegmentAndIndex: IndexPath? = nil

    private var _currentMinValue: Int
    private var _currentMaxValue: Int
    
    public var currentMinValue: Int {
        get { return _currentMinValue }
        set { setCurrentMinValue(newValue, animated: false) }
    }
    
    public func setCurrentMinValue(_ minValue: Int, animated: Bool) {
        _currentMinValue = minValue
        if let picker = pickerView {
            picker.selectRow(minValue-self.minValue, inComponent: 0, animated: animated)
        }
    }
    
    public var currentMaxValue: Int {
        get { return _currentMaxValue }
        set { setCurrentMaxValue(newValue, animated: false) }
    }
    
    public func setCurrentMaxValue(_ maxValue: Int, animated: Bool) {
        _currentMaxValue = maxValue
        if let picker = pickerView {
            picker.selectRow(maxValue-self.minValue, inComponent: 1, animated: animated)
        }
    }
    
    public var pickerView: UIPickerView? = nil
    
    public init() {
        self.minValue = 0
        self.maxValue = 0
        
        _currentMinValue = 0
        _currentMaxValue = 0
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(min: Int, max: Int) {
        self.maxValue = max
        self.minValue = min
        
        _currentMinValue = min
        _currentMaxValue = min
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(min: Int, max: Int, currentMin: Int, currentMax: Int) {
        self.maxValue = max
        self.minValue = min
        
        _currentMinValue = currentMin
        _currentMaxValue = currentMax
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 400.0, height: 160.0)
        
        self.setupPicker()
    }
    
    // MARK: Picker setup
    func setupPicker() {
        if pickerView == nil {
            let picker = UIPickerView(frame: .zero)
            picker.delegate = self
            picker.dataSource = self
            picker.translatesAutoresizingMaskIntoConstraints = false
            pickerView = picker
            picker.selectRow(currentMinValue-minValue, inComponent: 0, animated: false)
            picker.selectRow(currentMaxValue-minValue, inComponent: 1, animated: false)

            
            self.view.addSubview(picker)
            
            let minTitle = UILabel(frame: .zero)
            minTitle.text = "Min"
            minTitle.textAlignment = .center
            minTitle.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(minTitle)
            
            let maxTitle = UILabel(frame: .zero)
            maxTitle.text = "Max"
            maxTitle.textAlignment = .center
            maxTitle.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(maxTitle)
            
            let dashLabel = UILabel(frame: .zero)
            dashLabel.text = "-"
            dashLabel.textAlignment = .center
            dashLabel.translatesAutoresizingMaskIntoConstraints = false
            dashLabel.center = picker.center
            
            self.view.addSubview(dashLabel)
            
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: minTitle, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .centerX),
                NSLayoutConstraint(item: minTitle, attribute: .width, relatedBy: .equal, toConstant: 60.0),
                NSLayoutConstraint(item: minTitle, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, constant: 5.0),
                
                NSLayoutConstraint(item: maxTitle, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .centerX),
                NSLayoutConstraint(item: maxTitle, attribute: .width, relatedBy: .equal, toConstant: 60.0),
                NSLayoutConstraint(item: maxTitle, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, constant: 5.0),
                
                NSLayoutConstraint(item: picker, attribute: .top, relatedBy: .equal, toItem: minTitle, attribute: .bottom),
                NSLayoutConstraint(item: picker, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom),
                NSLayoutConstraint(item: picker, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left),
                NSLayoutConstraint(item: picker, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right),
                
                NSLayoutConstraint(item: dashLabel, attribute: .centerX, relatedBy: .equal, toItem: picker, attribute: .centerX),
                NSLayoutConstraint(item: dashLabel, attribute: .centerY, relatedBy: .equal, toItem: picker, attribute: .centerY),
                ])
        }
    }
    
    // MARK: Picker datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let difference = (maxValue - minValue) + 1
        
        return difference > 0 ? difference : 0
    }
    
    // MARK: Picker delegate
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 60.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = "\(row+minValue)"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24.0)
        
        if component == 1 {
            let currentValue = row+minValue
            
            if currentValue < currentMinValue {
                label.textColor = .lightGray
                label.alpha = 0.5
            } else {
                label.textColor = .darkText
                label.alpha = 1.0
            }
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let newValue = row+minValue
        var max = _currentMaxValue
        var min = _currentMinValue
        
        if component == 0 {
            min = newValue
        } else {
            max = newValue
        }
        
        if max < min {
            max = min
        }
        
        setCurrentMinValue(min, animated: true)
        setCurrentMaxValue(max, animated: true)
        
        if component == 0 {
            pickerView.reloadComponent(1)
        }
        
        if let delegate = numberRangePickerDelegate {
            delegate.numberRangePickerValueChanged(self, newMinValue: _currentMinValue, newMaxValue: _currentMaxValue)
        }
    }
}

// MARK - Delegate to return value

protocol NumberRangePickerDelegate: class {
    
    func numberRangePickerValueChanged(_ numberPicker: SearchNumberRangePickerViewController, newMinValue: Int, newMaxValue: Int)
}
