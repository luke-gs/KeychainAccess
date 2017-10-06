//
//  MapSettingsViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 6/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class MapSettingsViewController: UIViewController, PopoverViewController {

    private var viewModel: MapSettingsViewModel!
    
    // MARK: - Constants
    
    private let sideMargin: CGFloat = 16
    private let topMargin: CGFloat = 8

    // MARK: - Views
    
    private var modeSegmentedControl: UISegmentedControl!
    private var divider: UIView!
    private var trafficLabel: UILabel!
    private var trafficSwitch: UISwitch!
    
    var wantsTransparentBackground: Bool = true {
        didSet {
            view.backgroundColor = wantsTransparentBackground ? .clear : .white
        }
    }
    
    // MARK: - Setup
    
    init(viewModel: MapSettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    /// Creates and styles views
    private func setupViews() {
        title = "Map Settings"
        edgesForExtendedLayout = []
        navigationItem.rightBarButtonItem  = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(close))

        modeSegmentedControl = UISegmentedControl(items: viewModel.segments())
        modeSegmentedControl.selectedSegmentIndex = viewModel.selectedIndex()
        modeSegmentedControl.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
        modeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modeSegmentedControl)
        
        divider = UIView()
        divider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        divider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(divider)
        
        trafficLabel = UILabel()
        trafficLabel.text = "Traffic"
        trafficLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trafficLabel)
        
        trafficSwitch = UISwitch()
        trafficSwitch.isOn = viewModel.isTrafficEnabled()
        trafficSwitch.addTarget(self, action: #selector(trafficSwitchDidChange), for: .valueChanged)
        trafficSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trafficSwitch)
        
        preferredContentSize = CGSize(width: 340, height: 100)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        modeSegmentedControl.setContentHuggingPriority(.defaultHigh, for: .vertical)
        NSLayoutConstraint.activate([
            modeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor, constant: topMargin),
            modeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sideMargin),
            modeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sideMargin),
            
            divider.topAnchor.constraint(equalTo: modeSegmentedControl.bottomAnchor, constant: topMargin),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sideMargin),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sideMargin),
            divider.heightAnchor.constraint(equalToConstant: 1),

            trafficLabel.topAnchor.constraint(greaterThanOrEqualTo: divider.bottomAnchor),
            trafficLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -sideMargin),
            trafficLabel.centerYAnchor.constraint(equalTo: trafficSwitch.centerYAnchor),
            trafficLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sideMargin),
            trafficLabel.trailingAnchor.constraint(lessThanOrEqualTo: trafficSwitch.leadingAnchor, constant: -sideMargin),
            
            trafficSwitch.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: topMargin),
            trafficSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sideMargin),
            trafficSwitch.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -sideMargin),
        ])
    }
    
    // MARK: - Controls
    
    @objc private func segmentedControlDidChange() {
        viewModel.setMode(at: modeSegmentedControl.selectedSegmentIndex)
    }
    
    @objc private func trafficSwitchDidChange() {
        viewModel.setTrafficEnabled(trafficSwitch.isOn)
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
