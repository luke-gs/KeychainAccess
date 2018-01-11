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

class SketchPickerController: UIViewController {

    weak var delegate: SketchPickerControllerDelegate?
    
    lazy var canvas: SketchyCanvas = {
        let canvas = SketchyCanvas()
        canvas.frame = view.frame
        canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return canvas
    }()

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
    }

    @objc private func closeTapped() {
        delegate?.sketchPickerControllerDidCancel(self)
    }

    @objc private func doneTapped() {
        if let image = canvas.renderedImage() {
            delegate?.sketchPickerController(self, didFinishPickingSketch: image)
        }
    }
}
