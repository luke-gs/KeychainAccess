//
//  SettingsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 7/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

private let switchCellID = "SwitchCell"

class SettingsViewController: FormTableViewController {

    // MARK: - Intializer
    
    init() {
        super.init(style: .grouped)
        title = NSLocalizedString("Settings", comment: "SettingsTitle")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: switchCellID)
    }

    
    // MARK: - UITableViewDataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .generalToggles: return GeneralToggles.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .generalToggles:
            let toggleItem = GeneralToggles(rawValue: indexPath.row)!
            
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellID, for: indexPath)
            cell.textLabel?.text = toggleItem.localizedTitle
            
            let switchControl: UISwitch
            if let switchAccessory = cell.accessoryView as? UISwitch {
                switchControl = switchAccessory
            } else {
                switchControl = UISwitch()
                switchControl.addTarget(self, action: #selector(switchControlValueDidChange(_:)), for: .valueChanged)
                cell.accessoryView = switchControl
                cell.selectionStyle = .none
            }
            
            switchControl.isOn = toggleItem.currentValue
            
            return cell
        }
    }
    
    
    // MARK: - UITableViewDelegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    // MARK: - Private
    
    private enum Section: Int {
        case generalToggles
        
        static let count: Int = 1
        
    }
    
    private enum GeneralToggles: Int {
        case darkMode
        case numericKeyboard
        
        static let count: Int = 2
        
        var localizedTitle: String {
            switch self {
            case .darkMode:        return NSLocalizedString("Dark Mode",        comment: "DarkModeSwitchTitle")
            case .numericKeyboard: return NSLocalizedString("Numeric Keyboard", comment: "NumericKeyboardSwitchTitle")
            }
        }
        
        var currentValue: Bool {
            get {
                switch self {
                case .darkMode:        return Theme.current.isDark
                case .numericKeyboard: return KeyboardInputManager.shared.isNumberBarEnabled
                }
            }
            set {
                switch self {
                case .darkMode:
                break // TODO
                case .numericKeyboard:
                    return KeyboardInputManager.shared.isNumberBarEnabled = newValue
                }
            }
            
        }
    }
    
    @objc private func switchControlValueDidChange(_ control: UISwitch) {
        guard let tableView = self.tableView,
            let indexPath = tableView.indexPathForRow(at: tableView.convert(control.bounds.origin, from: control)) else { return }
        
        switch Section(rawValue: indexPath.section)! {
        case .generalToggles:
            var toggle = GeneralToggles(rawValue: indexPath.row)!
            toggle.currentValue = control.isOn
        }
        
        
    }
    
}
