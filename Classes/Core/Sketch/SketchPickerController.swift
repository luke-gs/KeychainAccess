//
//  SketchPickerController.swift
//  MPOLKit
//
//  Created by QHMW64 on 11/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

protocol SketchPickerControllerDelegate: class {
    func sketchPickerController(_ picker: SketchPickerController, didFinishPickingSketch sketch: UIImage)
    func sketchPickerControllerDidCancel(_ picker: SketchPickerController)
}

class SketchPickerController: UIViewController, SketchControlPanelDelegate, SketchCanvasDelegate {

    weak var delegate: SketchPickerControllerDelegate?
    
    lazy var canvas: SketchyCanvas = {
        let canvas = SketchyCanvas()
        canvas.frame = view.frame
        canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return canvas
    }()
    lazy var controlPanel: SketchControlPanel = SketchControlPanel()

    lazy var doneItem: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        button.isEnabled = false
        return button
    }()
    lazy var trashItem: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearTapped))
        button.isEnabled = false
        return button
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(closeTapped))
        navigationItem.rightBarButtonItems = [
            doneItem,
            trashItem
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        canvas.delegate = self

        view.backgroundColor = .white
        view.addSubview(canvas)

        controlPanel.delegate = self
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlPanel)

        NSLayoutConstraint.activate([
            controlPanel.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
            controlPanel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 1.0),
            controlPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlPanel.heightAnchor.constraint(equalToConstant: 60.0)
        ])

        if let color = controlPanel.colors.first {
            controlPanel.setSelectedColor(color)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controlPanel.setSelectedMode(mode: canvas.sketchMode)
    }

    // MARK: - Sketch Control Panel Delegate

    func controlPanel(_ panel: SketchControlPanel, didSelectColor color: UIColor) {
        canvas.sketchMode = .draw
        canvas.setToolColor(color)
    }

    func controlPanel(_ panel: SketchControlPanel, didChangeDrawMode mode: SketchMode) {
        canvas.sketchMode = mode
    }

    func controlPanelDidSelectWidth(_ panel: SketchControlPanel) {
        let viewController = PixelWidthSelectionViewController()
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.delegate = viewController
        viewController.popoverPresentationController?.permittedArrowDirections = [.down]
        viewController.popoverPresentationController?.sourceView = panel.pixelWidthView
        viewController.popoverPresentationController?.sourceRect = panel.pixelWidthView.imageView.frame
        viewController.preferredContentSize = CGSize(width: 400, height: 150)
        viewController.selectionHandler = { [unowned self] nibSize in
            self.canvas.setToolWidth(nibSize.rawValue)
            self.controlPanel.pixelWidthView.update(with: nibSize)
            self.dismiss(animated: false, completion: nil)
        }
        navigationController?.present(viewController, animated: true, completion: nil)
    }

    // MARK: - Sketch Canvas Delegate

    func canvasDidStartSketching(_ canvas: Sketchable) {
        let isEmptyCanvas = canvas.isEmpty
        doneItem.isEnabled = !isEmptyCanvas
        trashItem.isEnabled = !isEmptyCanvas
    }

    func canvas(_ canvas: Sketchable, touchMovedTo position: CGPoint) {

        // Calculates whether the control panel should be hidden whilst panning

        let position = view.convert(position, to: view)
        let hidingHeight = controlPanel.frame.height + 100.0
        let shouldHide = position.y >= view.frame.maxY - hidingHeight

        // If the panel should hide set its alpha to a percentage of the control height
        controlPanel.alpha = shouldHide ? 1 - ((hidingHeight - (view.frame.maxY - 100 - position.y)) / hidingHeight) : 1
    }

    func canvasDidFinishSketching(_ canvas: Sketchable) {
        // When touches finish ensure that the control panel has an alpha
        // value of 1
        controlPanel.alpha = 1
    }

    // Private functions

    @objc private func closeTapped() {
        delegate?.sketchPickerControllerDidCancel(self)
    }

    @objc private func doneTapped() {
        if let image = canvas.renderedImage() {
            delegate?.sketchPickerController(self, didFinishPickingSketch: image)
        }
    }

    @objc private func clearTapped() {
        canvas.clearCanvas()
        doneItem.isEnabled = false
        trashItem.isEnabled = false
    }
}
