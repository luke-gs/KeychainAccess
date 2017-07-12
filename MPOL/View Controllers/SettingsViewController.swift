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
private let buttonCellID = "ButtonCell"

class SettingsViewController: FormTableViewController {

    private var sections: [SettingSection]
    
    // MARK: - Intializers
    
    init() {
        var items = [Setting.darkMode]
        if KeyboardInputManager.shared.isNumberBarSupported {
            items.append(.numericKeyboard)
        }
        sections = [SettingSection(title: nil, items: items), SettingSection(title: nil, items: [.logOut])]
        
        super.init(style: .grouped)
        title = NSLocalizedString("Settings", comment: "SettingsTitle")
        
        wantsCalculatedContentHeight = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tableView = self.tableView else { return }
        
        let bundle = Bundle.main
        let appName       = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "MPOL"
        let bundleVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let buildNumber   = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 30.0))
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = appName + " Version: " + bundleVersion + " #" + buildNumber
        tableView.tableFooterView = label
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: buttonCellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: switchCellID)
    }

    
    // MARK: - UITableViewDataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = sections[indexPath.section].items[indexPath.row]
        
        switch setting.style {
        case .button:
            let cell = tableView.dequeueReusableCell(withIdentifier: buttonCellID, for: indexPath)
            cell.textLabel?.text = setting.localizedTitle
            return cell
        case .switchControl:
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellID, for: indexPath)
            
            cell.textLabel?.text = setting.localizedTitle
            
            let switchControl: UISwitch
            if let switchAccessory = cell.accessoryView as? UISwitch {
                switchControl = switchAccessory
            } else {
                switchControl = UISwitch()
                switchControl.addTarget(self, action: #selector(switchControlValueDidChange(_:)), for: .valueChanged)
                cell.accessoryView = switchControl
                cell.selectionStyle = .none
            }
            
            switchControl.isOn = setting.currentValue
            
            return cell
        }
    }
    
    
    // MARK: - UITableViewDelegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = sections[indexPath.section].items[indexPath.row]
        
        if setting.style == .button {
            sections[indexPath.section].items[indexPath.row].currentValue = true
            tableView.deselectRow(at: indexPath, animated: true)
            if setting == .logOut {
                dismiss(animated: true)
            }
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    // MARK: - Private
    
    private struct SettingSection {
        var title: String?
        var items: [Setting]
    }
    
    private enum SettingStyle {
        case switchControl
        case button
    }
    
    private enum Setting {
        case darkMode
        case numericKeyboard
        case logOut
        
        var style: SettingStyle {
            switch self {
            case .logOut:
                return .button
            case .darkMode, .numericKeyboard:
                return .switchControl
            }
        }
        
        var localizedTitle: String {
            switch self {
            case .darkMode:        return NSLocalizedString("Dark Mode",        comment: "DarkModeSwitchTitle")
            case .numericKeyboard: return NSLocalizedString("Numeric Keyboard", comment: "NumericKeyboardSwitchTitle")
            case .logOut:          return NSLocalizedString("Log Out",          comment: "NumericKeyboardSwitchTitle")
            }
        }
        
        var currentValue: Bool {
            get {
                switch self {
                case .darkMode:        return Theme.current.isDark
                case .numericKeyboard: return KeyboardInputManager.shared.isNumberBarEnabled
                case .logOut:          return false
                }
            }
            set {
                switch self {
                case .darkMode:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        _ = Theme.applyTheme(withName: newValue ? "Dark" : "Light")
                    }
                case .numericKeyboard:
                    KeyboardInputManager.shared.isNumberBarEnabled = newValue
                case .logOut:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        (UIApplication.shared.delegate as! AppDelegate).logOut()
                    })
                }
            }
        }
    }
    
    @objc private func switchControlValueDidChange(_ control: UISwitch) {
        guard let tableView = self.tableView,
            let indexPath = tableView.indexPathForRow(at: tableView.convert(control.bounds.origin, from: control)) else { return }
        
        sections[indexPath.section].items[indexPath.row].currentValue = control.isOn
    }
    
}
