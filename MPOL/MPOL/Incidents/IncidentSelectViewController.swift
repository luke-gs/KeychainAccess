//
//  IncidentSelectViewController.swift
//  MPOL
//
//  Created by Pavel Boryseiko on 22/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class IncidentSelectViewController: ThemedPopoverViewController {

    open var tableView: UITableView!
    open var buttonsView: DialogActionButtonsView!

    // MARK: - Initializers

    public required init?(coder aDecoder: NSCoder) { MPLCodingNotSupported() }
    public init() {
        super.init(nibName: nil, bundle: nil)
        createSubviews()
        createConstraints()
    }

    // MARK: - View

    open override func viewDidLoad() {
        super.viewDidLoad()

        title = "New Event"
        view.backgroundColor = .clear

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        setupNavigationBarButtons()
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

    open func createSubviews() {
        tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .clear

        view.addSubview(tableView)

        let action = DialogAction(title: "Start From Scratch") { _ in self.dismissAnimated() }
        buttonsView = DialogActionButtonsView(actions: [action])
        view.addSubview(buttonsView)
    }

    open func createConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.translatesAutoresizingMaskIntoConstraints = false

        buttonsView.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor),

            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
            ])
    }

    @objc private func didTapCancelButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    open override func apply(_ theme: Theme) {
        super.apply(theme)
        guard let tableView = tableView else { return }

        let backgroundColor = ThemeManager.shared.theme(for: .dark) == theme ? theme.color(forKey: .background) : .clear
        tableView.backgroundColor = backgroundColor
        view.backgroundColor = backgroundColor

        for cell in tableView.visibleCells {
            cell.textLabel?.textColor = theme.color(forKey: .primaryText)
            cell.imageView?.tintColor = theme.color(forKey: .primaryText)
        }
    }
}

extension IncidentSelectViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
        cell.imageView?.tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!

        cell.imageView?.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.document)
        cell.textLabel?.text = "Incident Test"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}
