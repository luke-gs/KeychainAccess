//
//  MapSettingsViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 6/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class MapSettingsViewController: ThemedPopoverViewController {

    private var viewModel: MapSettingsViewModel!
    
    // MARK: - Constants
    
    private let sideMargin: CGFloat = 16
    private let topMargin: CGFloat = 8

    // MARK: - Views
    private var typeLabel: UILabel!
    private var layersLabel: UILabel!
    private var layersDescriptionLabel: UILabel!
    private var modeSegmentedControl: UISegmentedControl!
    private var mapLayerCollectionView: MapSettingsLayersCollectionView!
    
    open override var wantsTransparentBackground: Bool {
        didSet {
            mapLayerCollectionView?.wantsTransparentBackground = wantsTransparentBackground
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
        title = viewModel.navTitle()
        
        navigationItem.rightBarButtonItem  = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(close))

        typeLabel = UILabel()
        typeLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        typeLabel.text = viewModel.typeLabelText()
        typeLabel.textColor = .primaryGray
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typeLabel)
        
        modeSegmentedControl = UISegmentedControl(items: viewModel.segments())
        modeSegmentedControl.selectedSegmentIndex = viewModel.selectedIndex()
        modeSegmentedControl.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
        modeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modeSegmentedControl)
        
        layersLabel = UILabel()
        layersLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        layersLabel.text = viewModel.layersLabelText()
        layersLabel.textColor = .primaryGray
        layersLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(layersLabel)
        
        layersDescriptionLabel = UILabel()
        layersDescriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        layersDescriptionLabel.text = viewModel.layersDescriptionLabelText()
        layersDescriptionLabel.textColor = .secondaryGray
        layersDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(layersDescriptionLabel)
        
        mapLayerCollectionView = MapSettingsLayersCollectionView(viewModel: viewModel)
        mapLayerCollectionView.view.backgroundColor = .clear
        mapLayerCollectionView.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(mapLayerCollectionView, toView: self.view)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        modeSegmentedControl.setContentHuggingPriority(.defaultHigh, for: .vertical)
        NSLayoutConstraint.activate([
            typeLabel.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor, constant: 24),
            typeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            typeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            modeSegmentedControl.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 20),
            modeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            modeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            layersLabel.topAnchor.constraint(equalTo: modeSegmentedControl.bottomAnchor, constant: 40),
            layersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            layersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            
            layersDescriptionLabel.topAnchor.constraint(equalTo: layersLabel.bottomAnchor, constant: 4),
            layersDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            layersDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            mapLayerCollectionView.view.topAnchor.constraint(equalTo: layersDescriptionLabel.bottomAnchor, constant: 10),
            mapLayerCollectionView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapLayerCollectionView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            mapLayerCollectionView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
        ])
    }
    
    // MARK: - Controls
    
    @objc private func segmentedControlDidChange() {
        viewModel.setMode(at: modeSegmentedControl.selectedSegmentIndex)
        mapLayerCollectionView.reloadForm()
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

open class MapSettingsLayersCollectionView: FormBuilderViewController {
    
    let viewModel: MapSettingsViewModel
    
    init(viewModel: MapSettingsViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func construct(builder: FormBuilder) {
        for (index, layer) in viewModel.layers.enumerated() {
            builder += OptionFormItem(title: layer.title)
                .width(.column(1))
                .onValueChanged { value in
                    self.viewModel.changedLayer(at: index, to: value)
                }
                .isEnabled(viewModel.isLayerEnabled(at: index))
                .isChecked(viewModel.isLayerOn(at: index))
                .separatorStyle(.none)
        }
    }
}
