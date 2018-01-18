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

    var initialOrientation: CGSize? {
        didSet {
            if initialOrientation == nil && oldValue != nil {
                initialOrientation = oldValue
            }
        }
    }

    lazy var canvas: SketchCanvas = {
        let canvas = SketchCanvas()
        canvas.frame = view.frame
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

        initialOrientation = canvas.frame.size

        canvas.delegate = self
        view.backgroundColor = .lightGray
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let orientation = initialOrientation else { return }
        var frame = canvas.frame

        coordinator.animate(alongsideTransition: { (context) in
            frame.size.width = orientation.width
            frame.size.height = orientation.height
            self.canvas.center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        }, completion: nil)
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

        // Animate the hiding of the control panel when the users touch
        // enter the area. Once in the area, the control panel will remain
        if shouldHide && controlPanel.alpha == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.controlPanel.alpha = 0
            })
        }
    }

    func canvasDidFinishSketching(_ canvas: Sketchable) {
        // When touches finish ensure that the control panel has an alpha
        // value of 1
        UIView.animate(withDuration: 0.3, animations: {
            self.controlPanel.alpha = 1
        })
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
