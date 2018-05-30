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
    private var handler: BiometricUserHandler?
    
    // MARK: - Intializers
    
    init() {
        var items = [Setting.darkMode]
        if KeyboardInputManager.shared.isNumberBarSupported {
            items.append(.numericKeyboard)
        }

        sections = [SettingSection(title: nil, items: items)]


        if let user = UserSession.current.user {
            let biometricHandler = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain)
            handler = biometricHandler
            if let useBiometricValue = user.appSettingValue(forKey: .useBiometric) as? String, let useBiometric = UseBiometric(rawValue: useBiometricValue) {
                // If user agreed, allow them to clear their agreement.
                if useBiometric == .agreed {
                    sections.append(SettingSection(title: nil, items: [.biometric]))
                }
                // If user says no, allow them to change their mind.
                else if useBiometric == .asked {
                    sections.append(SettingSection(title: nil, items: [.askBiometric]))
                }
            }
        }

        sections.append(SettingSection(title: nil, items: [.logOut]))

        super.init(style: .grouped)
        title = NSLocalizedString("Settings", comment: "SettingsTitle")
        calculatesContentHeight = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tableView = self.tableView else { return }
        
        tableView.tableFooterView = tableFooterView()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: buttonCellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: switchCellID)
    }

    func tableFooterView() -> UIStackView {
        let stackView = UIStackView(frame: CGRect(x: 0.0, y: 0.0, width: 310.0, height: 80.0))
        stackView.axis = .vertical
        stackView.alignment = .center

        let bundle = Bundle.main
        let appName         = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Unknown"
        let bundleVersion   = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let buildNumber     = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        let serverURL       = try! APIManager.shared.configuration.url.asURL().absoluteString

        func footerLabel() -> UILabel {
            let label = UILabel()
            label.font = UIFont.preferredFont(forTextStyle: .body)
            label.textColor = .gray
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }

        let versionLabel = footerLabel()
        versionLabel.text = appName + " Version: " + bundleVersion + " #" + buildNumber
        stackView.addArrangedSubview(versionLabel)

        let urlLabel = footerLabel()
        urlLabel.text = "Server URL: " + serverURL
        urlLabel.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(urlLabel)

        return stackView
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
            tableView.deselectRow(at: indexPath, animated: true)
            if setting == .logOut {
                dismiss(animated: true, completion: { [weak self] in
                    self?.sections[indexPath.section].items[indexPath.row].currentValue = true
                })
            } else if setting == .askBiometric {
                dismiss(animated: true, completion: { 
                    UserSession.current.user?.setAppSettingValue(nil, forKey: .useBiometric)
                })
            } else {
                sections[indexPath.section].items[indexPath.row].currentValue = true
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
        case biometric
        case askBiometric
        case logOut
        
        var style: SettingStyle {
            switch self {
            case .logOut, .askBiometric:
                return .button
            case .darkMode, .biometric, .numericKeyboard:
                return .switchControl
            }
        }
        
        var localizedTitle: String {
            switch self {
            case .darkMode:        return NSLocalizedString("Dark Mode",        comment: "DarkModeSwitchTitle")
            case .numericKeyboard: return NSLocalizedString("Numeric Keyboard", comment: "NumericKeyboardSwitchTitle")
            case .biometric:       return NSLocalizedString("Use Face/TouchID", comment: "")
            case .askBiometric:    return NSLocalizedString("Reset Face/TouchID Preference", comment: "")
            case .logOut:          return NSLocalizedString("Log Out",          comment: "NumericKeyboardSwitchTitle")
            }
        }
        
        var currentValue: Bool {
            get {
                switch self {
                case .darkMode:        return ThemeManager.shared.currentInterfaceStyle == .dark
                case .numericKeyboard: return KeyboardInputManager.shared.isNumberBarEnabled
                case .biometric:       return true
                case .askBiometric:    return false
                case .logOut:          return false
                }
            }
            set {
                switch self {
                case .darkMode:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        ThemeManager.shared.currentInterfaceStyle = newValue ? .dark : .light
                    }
                case .numericKeyboard:
                    KeyboardInputManager.shared.isNumberBarEnabled = newValue
                case .logOut:
                    (UIApplication.shared.delegate as! AppDelegate).logOut()
                default:
                    break
                }
            }
        }
    }
    
    @objc private func switchControlValueDidChange(_ control: UISwitch) {
        guard let tableView = self.tableView,
            let indexPath = tableView.indexPathForRow(at: tableView.convert(control.bounds.origin, from: control)) else { return }

        var setting = sections[indexPath.section].items[indexPath.row]
        if setting == .biometric {
            handler?.clear()
            UserSession.current.user?.setAppSettingValue(nil, forKey: .useBiometric)
            dismiss(animated: true, completion: { [weak self] in
                self?.sections[indexPath.section].items[indexPath.row].currentValue = true
            })
        }

        setting.currentValue = control.isOn
    }
    
}
