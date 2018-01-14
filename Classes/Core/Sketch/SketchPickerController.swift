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

class SketchPickerController: UIViewController, SketchControlPanelDelegate {

    weak var delegate: SketchPickerControllerDelegate?
    
    lazy var canvas: SketchyCanvas = {
        let canvas = SketchyCanvas()
        canvas.frame = view.frame
        canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return canvas
    }()
    lazy var controlPanel: SketchControlPanel = SketchControlPanel()

    init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(closeTapped))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(canvas)

        controlPanel.delegate = self
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlPanel)

        NSLayoutConstraint.activate([
            controlPanel.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
            controlPanel.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
            controlPanel.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            controlPanel.heightAnchor.constraint(equalToConstant: 60.0)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controlPanel.setSelectedMode(mode: canvas.sketchMode)
        controlPanel.setSelectedColor(.black)
    }

    // MARK: - Sketch Control Panel Delegate

    func controlPanel(_ panel: SketchControlPanel, didSelectColor color: UIColor) {
        canvas.sketchMode = .draw
        canvas.setToolColor(color)
    }

    func controlPanel(_ panel: SketchControlPanel, didChangeDrawMode mode: SketchMode) {
        canvas.sketchMode = mode
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
}
