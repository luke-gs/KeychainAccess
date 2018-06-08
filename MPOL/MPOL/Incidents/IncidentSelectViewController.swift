//
//  IncidentSelectViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

open class IncidentSelectViewController: ThemedPopoverViewController {

    open var tableView: UITableView!
    // TODO: Implement this to use the New Incident Type
    open var didSelectIncident: ((IncidentType?) -> ())?

    // MARK: - Initializers

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public init() {
        super.init(nibName: nil, bundle: nil)

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - View

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.tableFooterView = UIView()
        title = "New Event"
        view.backgroundColor = .clear

        createConstraints()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.backgroundColor = UIColor.white
        tableView.sectionFooterHeight = 0
        setupNavigationBarButtons()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(self.theme)
    }

    /// We need to override viewDidLayoutSubviews as well as willTransition due to behaviour of popover controller
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupNavigationBarButtons()
    }

    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.setupNavigationBarButtons()
        }, completion: nil)
    }

    /// Adds or removes bar button items for the curernt presented state
    open func setupNavigationBarButtons() {
        if presentingViewController != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton(_:)))
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        }
    }

    func createConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }

    @objc private func didTapCancelButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    open override func apply(_ theme: Theme) {
        super.apply(theme)
        guard let tableView = tableView else { return }
        let backgroundColor = theme.color(forKey: .background)
        tableView.backgroundColor = backgroundColor
        view.backgroundColor = backgroundColor
        tableView.visibleCells.forEach(self.theme)
        tableView.visibleSectionHeaderViews.forEach({
            if let view = $0 as? UITableViewHeaderFooterView {
                view.textLabel?.textColor = theme.color(forKey: .primaryText)
            }
        })
    }

    // TODO: Implement this to use the New Incident Type
    private func showEvent(with incident: IncidentType?) {
        dismissAnimated()
        didSelectIncident?(incident)
    }

    private func theme(_ cell: UITableViewCell) {
        let theme = ThemeManager.shared.theme(for: .current)
        cell.textLabel?.textColor = theme.color(forKey: .primaryText)
        cell.imageView?.tintColor = theme.color(forKey: .primaryText)
    }
}

extension IncidentSelectViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return IncidentListSection.numberOfSections
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IncidentListSection(rawValue: section)!.rowCount
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView, let textLabel = header.textLabel {
            textLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            textLabel.text = IncidentListSection(rawValue: section)!.sectionHeaderTitle
            textLabel.textColor = theme.color(forKey: .primaryText)
        }
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        theme(cell)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let section = IncidentListSection(rawValue: indexPath.section)!

        switch section {
        case .browse:
            // TODO: Remove and implement with filtering functionality, displaying incidents for the selected category in a new screen
            let alert = UIAlertController(title: "Categories Not Yet Implemented", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .recentlyUsed:
            // TODO: Implement this to use the New Incident Type
            showEvent(with: IncidentType.allIncidentTypes()[indexPath.row])
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!

        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear

        let section = IncidentListSection(rawValue: indexPath.section)!

        cell.imageView?.image = section.cellImage
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)

        switch section {
        case .browse:
            cell.textLabel?.text = IncidentCategory.allIncidentCategories[indexPath.row].title
        case .recentlyUsed:
            // TODO: Implement this to use the New Incident Type
            cell.textLabel?.text = IncidentType.allIncidentTypes()[indexPath.row].rawValue
        }
        return cell
    }
}

// Local enum for getting titles, counts etc. for each section in the table view
fileprivate enum IncidentListSection: Int {
    case browse
    case recentlyUsed

    static var numberOfSections: Int {
        return 2
    }

    var sectionHeaderTitle: String {
        switch self {
        case .browse:
            return "Browse"
        case .recentlyUsed:
            return "Recently Used"
        }
    }

    var rowCount: Int {
        switch self {
        case .browse:
            return IncidentCategory.allIncidentCategories.count
        case .recentlyUsed:
            // TODO: Implement this to use the New Incident Type
            return IncidentType.allIncidentTypes().count
        }
    }

    var cellImage: UIImage? {
        switch self {
        case .browse:
            return AssetManager.shared.image(forKey: AssetManager.ImageKey.list)
        case .recentlyUsed:
            return AssetManager.shared.image(forKey: AssetManager.ImageKey.document)
        }
    }
}

// TODO: Remove existing IncidentType, rename this one and then implement it. Move to KIT as well.
/// Defines the various Incident Types that are available.
public enum NewIncidentType {
    case interceptReport
    case trafficInfringement
    case domesticViolence

    var title: String {
        switch self {
        case .interceptReport:
            return "Intercept Report"
        case .trafficInfringement:
            return "Traffic Infringement"
        case .domesticViolence:
            return "Domestic Violence"
        }
    }

    var category: IncidentCategory {
        switch self {
        case .interceptReport:
            return .personOffences
        case .trafficInfringement:
            return .trafficOffences
        case .domesticViolence:
            return .personOffences
        }
    }

    func involvements(for entity: MPOLKitEntity) -> [String] {
        switch self {
        case .interceptReport, .domesticViolence:
            if entity is Person {
                return ["Respondant", "Aggrieved", "Claimant", "Custody", "Informant", "Interviewed", "Named Person", "Subject", "Witness"]
            } else if entity is Vehicle {
                return ["Involved in Offence","Involved in Crash","Damaged", "Towed", "Abandoned", "Defective"]
            }
        case .trafficInfringement:
            if entity is Person {
                return ["Involved in Offence", "Involved in Crash", "Driver"]
            } else if entity is Vehicle {
                return ["Damaged", "Towed", "Abandoned", "Defective", "Used"]
            }
        }
        fatalError("No Involvements for IncidentType")
    }

    static var allIncidentTypes: [NewIncidentType] {
        return [.interceptReport, .trafficInfringement, .domesticViolence]
    }
}

/// Category for splitting up Incident Types. Each Incident Type knows what its category is.
public enum IncidentCategory {
    case all
    case personOffences
    case trafficOffences
    case goodOrderOffences

    var title: String {
        switch self {
        case .all:
            return "Show All"
        case .goodOrderOffences:
            return "Good Order Offences"
        case .personOffences:
            return "Person Offences"
        case .trafficOffences:
            return "Traffic Offences"
        }
    }

    static var allIncidentCategories: [IncidentCategory] {
        return [.all, .trafficOffences, .personOffences, .goodOrderOffences]
    }
}
