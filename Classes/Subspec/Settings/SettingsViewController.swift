//
//  SettingsViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

private let switchCellID = "SwitchCell"
private let buttonCellID = "ButtonCell"
private let plainCellID = "PlainCell"

final public class SettingsViewController: FormTableViewController {

    // MARK:- Public

    /// The sections of the table
    public let sections: [SettingSection]

    /// The sections pinned to the bottom of the screen
    public private(set) var pinnedSettings: [Setting]

    /// Initiaise the SettingsViewController with sections
    ///
    /// - Parameter settingSections: the sections
    public required init(settingSections: [SettingSection]) {
        self.sections = settingSections.filter{$0.type != .pinned}
        self.pinnedSettings = settingSections.filter{$0.type == .pinned}.flatMap{$0.settings}
        super.init(style: .grouped)
    }

    // MARK:- Private
    private var buttonsView: DialogActionButtonsView?

    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"

        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = 64
        
        createButtonViewIfNecessary()
        createConstraints()
    }

    private func createButtonViewIfNecessary() {
        guard pinnedSettings.count > 0 else { return }

        let actions: [DialogAction] = pinnedSettings.compactMap { setting in
            switch setting.type {
            case .plain:
                let buttonAction = DialogAction(title: setting.title,
                                                style: DialogActionStyle.default)
                return buttonAction
            case .button(let action):
                let buttonAction = DialogAction(title: setting.title,
                                                style: DialogActionStyle.default) { [unowned self] buttonAction in
                                                    action(self, nil)
                }
                return buttonAction
            case .switch(let (isOn, action)):
                let buttonAction = DialogAction(title: setting.title,
                                                style: DialogActionStyle.default) { buttonAction in
                                                    action(!isOn(), nil)
                }
                return buttonAction
            }
        }

        buttonsView = DialogActionButtonsView(actions: actions, layoutStyle: .vertical)
    }

    private func createConstraints() {
        var constraints = [NSLayoutConstraint]()
        var bottomConstraint: NSLayoutConstraint?

        if let tableView = tableView {
            tableView.translatesAutoresizingMaskIntoConstraints = false
            bottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

            constraints += [
                tableView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            ]

            // Add bottom buttons view constraints
            if let buttonsView = buttonsView {
                buttonsView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(buttonsView)
                bottomConstraint = buttonsView.topAnchor.constraint(equalTo: tableView.bottomAnchor)

                constraints += [
                    buttonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    buttonsView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
                    buttonsView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
                ]
            }

            constraints.append(bottomConstraint!)
        }

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func switchControlValueDidChange(_ control: UISwitch) {
        guard let tableView = self.tableView,
            let indexPath = tableView.indexPathForRow(at: tableView.convert(control.bounds.origin, from: control)) else { return }

        let setting = sections[indexPath.section].settings[indexPath.row]

        switch setting.type {
        case .switch(let (_, action)):
            action(control.isOn) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .button, .plain:
            break
        }
    }

    // MARK: - UITableViewDataSource

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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].settings.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = sections[indexPath.section].settings[indexPath.row]
        var cell: UITableViewCell!

        setting.onLoad?()

        switch setting.type {
        case .plain:
            cell = tableView.dequeueReusableCell(withIdentifier: plainCellID)
                ?? UITableViewCell(style: .subtitle, reuseIdentifier: plainCellID)
            cell.selectionStyle = .none
        case .button:
            cell = tableView.dequeueReusableCell(withIdentifier: buttonCellID)
                ?? UITableViewCell(style: .subtitle, reuseIdentifier: buttonCellID)
            cell.accessoryType = .disclosureIndicator
        case .switch(let (isOn, _)):
            cell = tableView.dequeueReusableCell(withIdentifier: switchCellID)
                ?? UITableViewCell(style: .subtitle, reuseIdentifier: switchCellID)

            let switchControl: UISwitch = cell.accessoryView as? UISwitch ?? UISwitch()
            switchControl.addTarget(self, action: #selector(switchControlValueDidChange(_:)), for: .valueChanged)
            cell.accessoryView = switchControl
            cell.selectionStyle = .none

            switchControl.onTintColor = ThemeManager.shared.theme(for: .current).color(forKey: .tint)
            switchControl.isOn = isOn()
        }

        cell.textLabel?.text = setting.title
        cell.detailTextLabel?.text = setting.subtitle
        cell.imageView?.image = setting.image?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)

        return cell
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
    }

    public override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView, let textLabel = header.textLabel {
            textLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            switch sections[section].type {
            case .pinned: break
            case .plain(title: let title):
                textLabel.text = title
            }
            textLabel.textColor = ThemeManager.shared.theme(for: userInterfaceStyle).color(forKey: .primaryText)
            view.backgroundColor = ThemeManager.shared.theme(for: userInterfaceStyle).color(forKey: .background)
        }
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = sections[indexPath.section].settings[indexPath.row]

        switch setting.type {
        case .button(let action):
            action(self) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .switch, .plain:
            break
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK:- Theming

    public override func apply(_ theme: Theme) {
        super.apply(theme)
        buttonsView?.backgroundColor = theme.color(forKey: .groupedTableCellBackground)
        view?.backgroundColor = theme.color(forKey: .background)
        tableView?.reloadData()
    }
}
