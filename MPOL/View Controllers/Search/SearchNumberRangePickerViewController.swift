//
//  SearchNumberRangePickerViewController.swift
//  MPOL
//
//  Created by Valery Shorinov on 11/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class SearchNumberRangePickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    public var minValue: Int
    public var maxValue: Int
    
    public let picker: UIPickerView? = nil
    
    public init() {
        self.minValue = 0
        self.maxValue = 0
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(min: Int, max: Int) {
        self.maxValue = max
        self.minValue = min
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 320.0, height: 200.0)
                
        self.setupPicker()
    }
    
    // MARK: Picker setup
    func setupPicker() {
        if picker == nil {
            let picker = UIPickerView(frame: view.bounds)
            picker.delegate = self
            picker.dataSource = self
            picker.autoresizingMask = [.flexibleWidth, .flexibleWidth]
            
            
            self.view.addSubview(picker)
        }
    }
    
    // MARK: Picker datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let difference = maxValue - minValue
        
        return difference > 0 ? difference : 0
    }
    
    // MARK: Picker delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row+minValue)"
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 60.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
}
