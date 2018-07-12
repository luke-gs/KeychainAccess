//
//  SettingsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 7/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

private let switchCellID = "SwitchCell"
private let buttonCellID = "ButtonCell"
private let standardCellID = "StandardCell"
fileprivate let manifestLastUpdateKey = "Manifest_LastUpdate"


class SettingsViewController: FormTableViewController, WhatsNewViewControllerDelegate, TermsConditionsViewControllerDelegate {

    private var sections: [SettingSection]
    private var handler: BiometricUserHandler?
    
    // MARK: - Intializers
    
    init() {
        var items = [Setting]()

        if KeyboardInputManager.shared.isNumberBarSupported {
            items.append(Setting.numericKeyboard)
        }

        items.append(Setting.darkMode)

        if let user = UserSession.current.user {
            let biometricHandler = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain)
            handler = biometricHandler
            if let useBiometricValue = user.appSettingValue(forKey: .useBiometric) as? String, let useBiometric = UseBiometric(rawValue: useBiometricValue) {
                // If user agreed, allow them to clear their agreement.
                if useBiometric == .agreed {
                    items.append(Setting.biometric)
                }
                    // If user says no, allow them to change their mind.
                else if useBiometric == .asked {
                    items.append(Setting.askBiometric)
                }
            }
        }

        items.append(Setting.editSignature)

        sections = [SettingSection(title: "Accessibility", items: items)]

        sections.append(SettingSection(title: "General", items: [Setting.updateManifest, Setting.support, Setting.termsOfService, Setting.whatsNew]))

        super.init(style: .grouped)
        title = NSLocalizedString("Settings", comment: "SettingsTitle")
        calculatesContentHeight = true

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeSelected))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tableView = self.tableView else { return }
        
        tableView.tableFooterView = tableFooterView()

        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")



        self.wantsTransparentBackground = false
    }

    func tableFooterView() -> UIView {
        let stackView = UIStackView(frame: CGRect(x: 0.0, y: 0.0, width: 310.0, height: 60.0))
        stackView.axis = .vertical
        stackView.alignment = .center

        let logOutButton = UIButton()
        logOutButton.setTitleColor(tintColor, for: .normal)
        logOutButton.setTitle("Log Off This Device", for: .normal)

        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)

        stackView.addArrangedSubview(logOutButton)

        return stackView
    }

    @objc func logOut() {
        dismiss(animated: true) {
            (UIApplication.shared.delegate as! AppDelegate).logOut()
        }
    }
    
    // MARK: - UITableViewDataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    public override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView, let textLabel = header.textLabel {
            textLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            textLabel.text = sections[section].title
            textLabel.textColor = ThemeManager.shared.theme(for: userInterfaceStyle).color(forKey: .primaryText)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = sections[indexPath.section].items[indexPath.row]
        
        switch setting.style {
        case .none:
            var cell = tableView.dequeueReusableCell(withIdentifier: standardCellID)
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: standardCellID)
            }
            cell?.textLabel?.text = setting.localizedTitle
            cell?.detailTextLabel?.text = setting.localizedSubtitle
            cell?.imageView?.image = setting.image?.withRenderingMode(.alwaysTemplate)

            return cell!
        case .button:
            var cell = tableView.dequeueReusableCell(withIdentifier: buttonCellID)
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: buttonCellID)
            }
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.text = setting.localizedTitle
            cell?.detailTextLabel?.text = setting.localizedSubtitle
            cell?.imageView?.image = setting.image?.withRenderingMode(.alwaysTemplate)

            return cell!
        case .switchControl:
            var cell = tableView.dequeueReusableCell(withIdentifier: switchCellID)
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: switchCellID)
            }
            cell?.textLabel?.text = setting.localizedTitle
            cell?.detailTextLabel?.text = setting.localizedSubtitle
            cell?.imageView?.image = setting.image?.withRenderingMode(.alwaysTemplate)
            cell?.imageView?.tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
            
            let switchControl: UISwitch
            if let switchAccessory = cell?.accessoryView as? UISwitch {
                switchControl = switchAccessory
            } else {
                switchControl = UISwitch()
                switchControl.addTarget(self, action: #selector(switchControlValueDidChange(_:)), for: .valueChanged)
                cell?.accessoryView = switchControl
                cell?.selectionStyle = .none
            }

            switchControl.onTintColor = ThemeManager.shared.theme(for: .current).color(forKey: .tint)
            switchControl.isOn = setting.currentValue
            
            return cell!
        }
    }
    
    
    // MARK: - UITableViewDelegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = sections[indexPath.section].items[indexPath.row]
        
        if setting.style == .button || setting.style == .none {
            tableView.deselectRow(at: indexPath, animated: true)

            if setting == .askBiometric {
                dismiss(animated: true, completion: { 
                    UserSession.current.user?.setAppSettingValue(nil, forKey: .useBiometric)
                })
            } else if setting == .updateManifest {
                let cell = tableView.cellForRow(at: indexPath)
                let loadingAccessory = MPOLSpinnerView(style: .regular, color: tintColor)
                cell?.accessoryView = loadingAccessory
                cell?.detailTextLabel?.text = NSLocalizedString("Downloading...", comment: "")
                loadingAccessory.play()
                Manifest.shared.fetchManifest().ensure {
                    loadingAccessory.stop()
                    cell?.accessoryView = nil
                }.done {
                    tableView.reloadData()
                }.catch { (error) in
                    let alertImageView = ImageAccessoryItem(image: AssetManager.shared.image(forKey: .alert)!).view()
                    (alertImageView as! UIImageView).tintColor = UIColor.orangeRed
                    cell?.accessoryView = alertImageView
                    cell?.detailTextLabel?.text = "An issue occured. Tap to try again."
                }
            } else if setting == .support {
                // TODO: Implement this
            } else if setting == .termsOfService {
                let tsAndCsVC = TermsConditionsViewController(fileURL: Bundle.main.url(forResource: "termsandconditions", withExtension: "html")!)
                tsAndCsVC.navigationItem.rightBarButtonItem = nil
                tsAndCsVC.navigationItem.leftBarButtonItem = nil
                tsAndCsVC.delegate = self

                show(tsAndCsVC, sender: self)
            } else if setting == .whatsNew {

                let whatsNewFirstPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "WhatsNew"), title: "What's New",
                                                           detail: """
[MPOLA-1565] - Use manifest for event entity relationships.
""")

                let whatsNewVC = WhatsNewViewController(items: [whatsNewFirstPage])
                whatsNewVC.title = "What's New"
                whatsNewVC.delegate = self

                show(whatsNewVC, sender: self)
            }
            else {
                sections[indexPath.section].items[indexPath.row].currentValue = true
            }
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func termsConditionsController(_ controller: TermsConditionsViewController, didFinishAcceptingConditions accept: Bool) {
        navigationController?.popToRootViewController(animated: true)
    }

    
    // MARK: - Private
    
    private struct SettingSection {
        var title: String?
        var items: [Setting]
    }
    
    private enum SettingStyle {
        case switchControl
        case button
        case none
    }
    
    private enum Setting {
        case darkMode
        case numericKeyboard
        case biometric
        case askBiometric
        case editSignature
        case updateManifest
        case support
        case termsOfService
        case whatsNew
        
        var style: SettingStyle {
            switch self {
            case .updateManifest:
                return .none
            case .askBiometric, .editSignature, .support, .termsOfService, .whatsNew:
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
            case .editSignature:   return NSLocalizedString("Edit Signature",   comment: "")
            case .updateManifest:
                return NSLocalizedString("Update Manifest",   comment: "")
            case .support:
                return NSLocalizedString("Support",   comment: "")
            case .termsOfService:
                return NSLocalizedString("Terms of Service",   comment: "")
            case .whatsNew:
                return NSLocalizedString("What's New",   comment: "")
            }
        }

        var localizedSubtitle: String? {
            switch self {
            // TODO: Fix this, currently hard coded.
            case .updateManifest:
                let date = UserDefaults.standard.object(forKey: manifestLastUpdateKey) as? Date ?? Date()
                return NSLocalizedString("Updated \(timeToNow(from: date))",   comment: "")
            case .support:
                let bundle = Bundle.main
                let bundleVersion   = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
                let buildNumber     = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
                return  NSLocalizedString("Version " + bundleVersion + " #" +  buildNumber, comment: "")
            default:
                return nil
            }
        }

        var image: UIImage? {
            switch self {
            case .darkMode:
                return AssetManager.shared.image(forKey: .nightMode)
            case .numericKeyboard:
                return AssetManager.shared.image(forKey: .keyboard)
            case .biometric:
                return AssetManager.shared.image(forKey: .touchId)
            case .askBiometric:
                return nil
            case .editSignature:
                return AssetManager.shared.image(forKey: .edit)
            default:
                return nil
            }
        }
        
        var currentValue: Bool {
            get {
                switch self {
                case .darkMode:        return ThemeManager.shared.currentInterfaceStyle == .dark
                case .numericKeyboard: return KeyboardInputManager.shared.isNumberBarEnabled
                case .biometric:       return true
                case .askBiometric:    return false
                case .editSignature:   return false
                case .updateManifest:  return false
                case .support:         return false
                case .termsOfService:  return false
                case .whatsNew:        return false
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
                default:
                    break
                }
            }
        }

        private func timeToNow(from date: Date) -> String {

            let now = Date()
            let calendar: Calendar = Calendar.current

            let dateComponents = calendar.dateComponents([.day, .hour, .minute, .second], from: date, to: now)

            guard let days = dateComponents.day, let hours = dateComponents.hour, let min = dateComponents.minute, let sec = dateComponents.second else { return "" }

            if (days > 0) {
                 return "\(days) Day\(days > 1 ? "s" : "") Ago"
            } else if (hours > 0) {
                return "\(hours) Hour\(hours > 1 ? "s" : "") Ago"
            }  else if (min > 0) {
                return "\(min) Minute\(min > 1 ? "s" : "") Ago"
            } else if (sec > 0) {
                return "\(sec) Second\(sec > 1 ? "s" : "") Ago"
            }

            return ""
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

    @objc func closeSelected() {
        dismissAnimated()
    }

    @objc func whatsNewViewControllerDidTapDoneButton(_ whatsNewViewController: WhatsNewViewController) {
        whatsNewViewController.navigationController?.popToRootViewController(animated: true)
    }
}
