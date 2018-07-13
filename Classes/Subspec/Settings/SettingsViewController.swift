//
//  SettingsViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

private let switchCellID = "SwitchCell"
private let buttonCellID = "ButtonCell"

final public class SettingsViewController: FormTableViewController {

    let sections: [SettingSection]
    var pinnedSection: [SettingSection]

    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(settingSections: [SettingSection]) {
        self.sections = settingSections.filter{$0.type != .pinned}
        self.pinnedSection = sections.filter{$0.type == .pinned}
        super.init(style: .plain)
        createButtonViewIfNecessary()
    }

    open func createButtonViewIfNecessary() {
        let buttons: [DialogActionView] = pinnedSection.flatMap{$0.settings}.compactMap { setting in
            switch setting.type {
            case .button(let action):
                let buttonAction = DialogAction(title: setting.title,
                                                style: DialogActionStyle.default) { [unowned self] buttonAction in
                                                    action(self)
                }
                let view = UIView()
                view.backgroundColor = .green
                return DialogActionView(action: buttonAction, view: view)
            case .switch(let (isOn, action)):
                let buttonAction = DialogAction(title: setting.title,
                                                style: DialogActionStyle.default) { buttonAction in
                                                    action(!isOn)
                }
                let view = UIView()
                view.backgroundColor = .magenta
                return DialogActionView(action: buttonAction, view: view)
            }
        }

        let buttonsView = DialogActionButtonsView(views: buttons)
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)

        tableView?.translatesAutoresizingMaskIntoConstraints = false

        // Make space for button view and position it below form
        if let tableView = tableView {
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor).withPriority(.almostRequired),

                buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
                ])
        }
    }

    // MARK: - UITableViewDataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section].type {
        case .plain(title: let title):
            return title
        case .pinned:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].settings.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = sections[indexPath.section].settings[indexPath.row]
        var cell: UITableViewCell!

        switch setting.type {
        case .button:
            cell = tableView.dequeueReusableCell(withIdentifier: buttonCellID)
                ?? UITableViewCell(style: .subtitle, reuseIdentifier: buttonCellID)
        case .switch(let (isOn, _)):
            cell = tableView.dequeueReusableCell(withIdentifier: switchCellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: switchCellID)

            let switchControl: UISwitch = cell.accessoryView as? UISwitch ?? UISwitch()

            switchControl.isUserInteractionEnabled = false
            //                switchControl.addTarget(self, action: #selector(switchControlValueDidChange(_:)), for: .valueChanged)
            cell.accessoryView = switchControl
            cell.selectionStyle = .none

            switchControl.onTintColor = ThemeManager.shared.theme(for: .current).color(forKey: .tint)
            switchControl.isOn = isOn
        }

        cell.textLabel?.text = setting.title
        cell.detailTextLabel?.text = setting.subtitle
        cell.imageView?.image = setting.image?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)

        return cell
    }

    // MARK: - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = sections[indexPath.section].settings[indexPath.row]

        switch setting.type {
        case .button(let action):
            action(self)
        case .switch(let (isOn, action)):
            action(!isOn)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

//        if setting.style == .button || setting.style == .none {
//            tableView.deselectRow(at: indexPath, animated: true)
//
//            if setting == .askBiometric {
//                dismiss(animated: true, completion: {
//                    UserSession.current.user?.setAppSettingValue(nil, forKey: .useBiometric)
//                })
//            } else if setting == .updateManifest {
//                let cell = tableView.cellForRow(at: indexPath)
//                let loadingAccessory = MPOLSpinnerView(style: .regular, color: tintColor)
//                cell?.accessoryView = loadingAccessory
//                cell?.detailTextLabel?.text = NSLocalizedString("Downloading...", comment: "")
//                loadingAccessory.play()
//                Manifest.shared.fetchManifest().ensure {
//                    loadingAccessory.stop()
//                    cell?.accessoryView = nil
//                    }.done {
//                        tableView.reloadData()
//                    }.catch { (error) in
//                        let alertImageView = ImageAccessoryItem(image: AssetManager.shared.image(forKey: .alert)!).view()
//                        (alertImageView as! UIImageView).tintColor = UIColor.orangeRed
//                        cell?.accessoryView = alertImageView
//                        cell?.detailTextLabel?.text = "An issue occured. Tap to try again."
//                }
//            } else if setting == .support {
//                // TODO: Implement this
//            } else if setting == .termsOfService {
//                let tsAndCsVC = TermsConditionsViewController(fileURL: Bundle.main.url(forResource: "termsandconditions", withExtension: "html")!)
//                tsAndCsVC.navigationItem.rightBarButtonItem = nil
//                tsAndCsVC.navigationItem.leftBarButtonItem = nil
//                tsAndCsVC.delegate = self
//
//                show(tsAndCsVC, sender: self)
//            } else if setting == .whatsNew {
//
//                let whatsNewFirstPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "WhatsNew"), title: "What's New",
//                                                           detail: """
//[MPOLA-1584] - Update Login screen to remove highlighting in T&Cs and forgot password.
//[MPOLA-1565] - Use manifest for event entity relationships.
//""")
//
//                let whatsNewVC = WhatsNewViewController(items: [whatsNewFirstPage])
//                whatsNewVC.title = "What's New"
//                whatsNewVC.delegate = self
//
//                show(whatsNewVC, sender: self)
//            }
//            else {
//                sections[indexPath.section].items[indexPath.row].currentValue = true
//            }
//            return
//        }

        tableView.deselectRow(at: indexPath, animated: false)
    }
}
