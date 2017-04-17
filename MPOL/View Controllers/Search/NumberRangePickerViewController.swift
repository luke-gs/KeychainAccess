//
//  SearchNumberRangePickerViewController.swift
//  MPOL
//
//  Created by Valery Shorinov on 11/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate var kvoContext = 1

fileprivate var cellID = "cellID"

class NumberRangePickerViewController: FormTableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Public properties
    
    weak var delegate: NumberRangePickerDelegate?
    
    let minValue: Int
    let maxValue: Int
    
    var currentMinValue: Int {
        get { return _currentMinValue }
        set { setCurrentMinValue(newValue, animated: false) }
    }
    
    func setCurrentMinValue(_ minValue: Int, animated: Bool) {
        _currentMinValue = minValue
        if let picker = pickerView {
            picker.selectRow(minValue - self.minValue, inComponent: 0, animated: animated)
            
            _currentMaxValue = picker.selectedRow(inComponent: 1) + self.minValue
            if _currentMaxValue < minValue {
                setCurrentMaxValue(minValue, animated: animated)
            }
        } else if _currentMaxValue < minValue {
            _currentMaxValue = minValue
        }
    }
    
    var currentMaxValue: Int {
        get { return _currentMaxValue }
        set { setCurrentMaxValue(newValue, animated: false) }
    }
    
    func setCurrentMaxValue(_ maxValue: Int, animated: Bool) {
        if let picker = pickerView {
            _currentMinValue = picker.selectedRow(inComponent: 0)
            _currentMaxValue = max(maxValue, _currentMinValue)
            
            picker.selectRow(_currentMaxValue - minValue, inComponent: 1, animated: animated)
        } else {
            _currentMaxValue = max(maxValue, _currentMinValue)
        }
    }
    
    var noRangeTitle: String? {
        didSet {
            guard let tableView = self.tableView else { return }
            
            let hadSection = (oldValue?.isEmpty ?? true)     == false
            let hasSection = (noRangeTitle?.isEmpty ?? true) == false
            
            switch (hadSection, hasSection) {
            case (false, false):
                return
            case (false, true):
                tableView.deleteSections(IndexSet(integer: 1), with: .fade)
            case (true, false):
                tableView.insertSections(IndexSet(integer: 1), with: .fade)
            case (true, true):
                if oldValue != noRangeTitle {
                    tableView.reloadSections(IndexSet(integer: 1), with: .none)
                }
            }
            
        }
    }
    
    
    // MARK: - Private properties
    
    private var _currentMinValue: Int {
        didSet {
            if _currentMinValue != oldValue {
                pickerView?.reloadComponent(1)
            }
        }
    }
    
    private var _currentMaxValue: Int
    
    private var pickerView: UIPickerView? = nil
    
    private var minLabel: UILabel?
    
    private var maxLabel: UILabel?
    
    private var dashLabel: UILabel?
    
    
    // MARK: - Initializers
    
    public init(min: Int, max: Int, currentMin: Int, currentMax: Int) {
        precondition(min <= max, "min value must be less than or equal to the maximum value.")
        precondition(currentMin >= min, "currentMin must be greater than or equal to the minimum value.")
        precondition(currentMax >= max, "currentMax must be less than or equal to the maximum value.")
        precondition(currentMin <= currentMax, "currentMin must be less than or equal to the currentMax value.")
        
        self.maxValue = max
        self.minValue = min
        
        _currentMinValue = currentMin
        _currentMaxValue = currentMax
        
        super.init(style: .grouped)
    }
    
    public convenience init(min: Int, max: Int) {
        self.init(min: min, max: max, currentMin: min, currentMax: max)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        let picker = UIPickerView(frame: .zero)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.delegate   = self
        picker.dataSource = self
        picker.selectRow(currentMinValue - minValue, inComponent: 0, animated: false)
        picker.selectRow(currentMaxValue - minValue, inComponent: 1, animated: false)
        
        let minLabel = UILabel(frame: .zero)
        minLabel.translatesAutoresizingMaskIntoConstraints = false
        minLabel.text = NSLocalizedString("Min", comment: "Minimum value in picker view.")
        minLabel.textAlignment = .center
        picker.addSubview(minLabel)
        
        let maxLabel = UILabel(frame: .zero)
        maxLabel.translatesAutoresizingMaskIntoConstraints = false
        maxLabel.text = NSLocalizedString("Max", comment: "Maximum value in picker view")
        maxLabel.textAlignment = .center
        picker.addSubview(maxLabel)
        
        let dashLabel = UILabel(frame: .zero)
        dashLabel.translatesAutoresizingMaskIntoConstraints = false
        dashLabel.text = NSLocalizedString("-", comment: "Separator between values in picker view")
        dashLabel.textAlignment = .center
        dashLabel.center = picker.center
        picker.addSubview(dashLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: minLabel, attribute: .trailing, relatedBy: .equal, toItem: picker, attribute: .centerX, constant: 3.0),
            NSLayoutConstraint(item: minLabel, attribute: .width,    relatedBy: .equal, toConstant: 60.0),
            NSLayoutConstraint(item: minLabel, attribute: .top,      relatedBy: .equal, toItem: picker, attribute: .top, constant: 5.0),
            
            NSLayoutConstraint(item: maxLabel, attribute: .leading,  relatedBy: .equal, toItem: picker, attribute: .centerX, constant: 5.0),
            NSLayoutConstraint(item: maxLabel, attribute: .width,    relatedBy: .equal, toConstant: 60.0),
            NSLayoutConstraint(item: maxLabel, attribute: .top,      relatedBy: .equal, toItem: picker, attribute: .top, constant: 5.0),
            
            NSLayoutConstraint(item: dashLabel, attribute: .centerX, relatedBy: .equal, toItem: picker, attribute: .centerX, constant: 5.0),
            NSLayoutConstraint(item: dashLabel, attribute: .centerY, relatedBy: .equal, toItem: picker, attribute: .centerY),
            
            NSLayoutConstraint(item: picker, attribute: .height, relatedBy: .equal, toConstant: picker.intrinsicContentSize.height, priority: UILayoutPriorityRequired - 1)
        ])
        
        self.pickerView = picker
        self.minLabel   = minLabel
        self.maxLabel   = maxLabel
        self.dashLabel  = dashLabel
        
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView?.estimatedRowHeight = 44.0
        
        super.viewDidLoad()
    }
    
    override func applyCurrentTheme() {
        super.applyCurrentTheme()
        
        let primaryTextColor = self.primaryTextColor ?? .darkText
        
        minLabel?.textColor  = primaryTextColor
        maxLabel?.textColor  = primaryTextColor
        dashLabel?.textColor = primaryTextColor
        
        pickerView?.reloadAllComponents()
    }
    
    // MARK: - UITableViewDataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return noRangeTitle?.isEmpty ?? true ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let contentView = cell.contentView
        
        if indexPath.section == 0 {
            cell.textLabel?.text = nil
            cell.selectionStyle = .none
            
            if let pickerView = self.pickerView, pickerView.superview != contentView {
                contentView.addSubview(pickerView)
                
                NSLayoutConstraint.activate([
                    NSLayoutConstraint(item: pickerView, attribute: .leading,  relatedBy: .equal, toItem: contentView, attribute: .leading),
                    NSLayoutConstraint(item: pickerView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing),
                    NSLayoutConstraint(item: pickerView, attribute: .top,      relatedBy: .equal, toItem: contentView, attribute: .top),
                    NSLayoutConstraint(item: pickerView, attribute: .bottom,   relatedBy: .equal, toItem: contentView, attribute: .bottom),
                    ])
            }
        } else {
            if pickerView?.superview == contentView {
                pickerView?.removeFromSuperview()
            }
            cell.textLabel?.text = noRangeTitle
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .default
        }
        return cell
    }
    
    
    // MARK: - UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        if indexPath.section == 1 {
            cell.textLabel?.textColor = tintColor
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            delegate?.numberRangePickerDidSelectNoRange(self)
        }
    }
    
    
    // MARK: - UIPickerViewDataSource methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Calculate the number of rows between the values, plus one to represent the other value.
        // eg in a picker with 0 and 1 as the valid values, this becomes 1 - 0 + 1 = 2 possible options.
        return maxValue - minValue + 1
    }
    
    
    // MARK: - UIPickerViewDelegate methods
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 60.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let rowNumber = row + minValue
        
        let color: UIColor
        if component == 1 && rowNumber < currentMinValue {
            color = placeholderTextColor ?? .lightGray
        } else {
            color = primaryTextColor ?? .darkText
        }
        
        return NSAttributedString(string: String(describing: rowNumber), attributes: [NSForegroundColorAttributeName: color])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let rowValue = row + minValue
        if component == 0 {
            setCurrentMinValue(rowValue, animated: true)
        } else {
            setCurrentMaxValue(rowValue, animated: true)
        }
        
        delegate?.numberRangePicker(self, didUpdateMinValue: currentMinValue, maxValue: currentMaxValue)
    }
}



// MARK - NumberRangePickerDelegate

protocol NumberRangePickerDelegate: class {
    
    func numberRangePicker(_ numberPicker: NumberRangePickerViewController, didUpdateMinValue minValue: Int, maxValue: Int)
    
    func numberRangePickerDidSelectNoRange(_ picker: NumberRangePickerViewController)
}
