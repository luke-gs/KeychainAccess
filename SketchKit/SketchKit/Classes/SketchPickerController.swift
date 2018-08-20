//
//  SketchPickerController.swift
//  MPOLKit
//
//  Created by QHMW64 on 11/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreKit

public protocol SketchPickerControllerDelegate: class {
    func sketchPickerController(_ picker: SketchPickerController, didFinishPickingSketch sketch: UIImage)
    func sketchPickerControllerDidCancel(_ picker: SketchPickerController)
}

public class SketchPickerController: UIViewController, SketchControlPanelDelegate, SketchCanvasDelegate {

    public weak var delegate: SketchPickerControllerDelegate?

    lazy var canvas: SketchCanvas = {
        let canvas = SketchCanvas()
        canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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

    public init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(closeTapped))
        navigationItem.rightBarButtonItems = [
            doneItem,
            trashItem
        ]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []
        canvas.delegate = self
        view.backgroundColor = #colorLiteral(red: 0.9450874925, green: 0.9411465526, blue: 0.9451001287, alpha: 1)
        view.addSubview(canvas)

        controlPanel.delegate = self
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.setContentHuggingPriority(.required, for: .horizontal)
        view.addSubview(controlPanel)

        NSLayoutConstraint.activate([
            controlPanel.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
            controlPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlPanel.heightAnchor.constraint(equalToConstant: 60.0)
        ])

        if let color = controlPanel.colors.first {
            controlPanel.setSelectedColor(color)
        }
        controlPanel.setSelectedNibSize(NibSize(value: canvas.currentTool.toolWidth))
    }

    override public var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom != .phone
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            if let image = self.canvas.renderedImage() {
                let newSize = image.sizeFittingAspect(scaledTo: size)
                var frame = self.canvas.frame
                frame.size.height = newSize.height
                frame.size.width = newSize.width
                self.canvas.frame = frame
                self.canvas.center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            }
        }, completion: nil)
    }

    override public func viewDidAppear(_ animated: Bool) {
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
        controlPanel.setSelectedNibSize(NibSize(value: canvas.currentTool.toolWidth))
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

    public func canvasDidStartSketching(_ canvas: Sketchable) {
        let isEmptyCanvas = canvas.isEmpty
        doneItem.isEnabled = !isEmptyCanvas
        trashItem.isEnabled = !isEmptyCanvas
    }

    public func canvas(_ canvas: Sketchable, touchMovedTo position: CGPoint) {

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

    public func canvasDidFinishSketching(_ canvas: Sketchable) {
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

fileprivate extension UIImage {

    // Calculate a new size of the image that fits into the provided rect
    // that respects the aspect ratio of the image
    func sizeFittingAspect(scaledTo toSize: CGSize) -> CGSize {

        let widthRatio  = toSize.width  / size.width
        let heightRatio = toSize.height / size.height

        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        return newSize
    }
}
