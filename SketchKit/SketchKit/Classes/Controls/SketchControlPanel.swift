//
//  SketchControlPanel.swift
//  MPOLKit
//
//  Created by QHMW64 on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreKit

/// Basic implementation of a control panel that allows the user to
/// change pen mode, the size of the pen and choose from a selection of
/// 3 colours.
class SketchControlPanel: UIView, SketchColorPickable {

    let colors: [UIColor]
    private let penView: ControlPanelPenView = ControlPanelPenView()
    private let eraserView: UIImageView = UIImageView(image: AssetManager.shared.image(forKey: .rubber))

    lazy var colorPicker: ColorPicker = SimpleColorPicker(colors: colors)
    lazy private(set) var pixelWidthView: PixelWidthView = PixelWidthView()

    // Constraints to manage the animations of the pen and eraser
    // Was using frame based but caused issues when layouts occured
    var penTopConstraint: NSLayoutConstraint?
    var eraserTopConstraint: NSLayoutConstraint?

    weak var delegate: SketchControlPanelDelegate?

    // The current selected view the represents the mode of the control panel
    // Either pen or eraser
    // When this is changed animate the change between the two
    private var selectedView: UIView? {
        didSet {
            if oldValue == selectedView {
                return
            }

            if oldValue == self.eraserView {
                self.eraserTopConstraint?.constant += 25
            } else {
                self.penTopConstraint?.constant += 25
            }
            guard let selectedView = self.selectedView else {
                return
            }
            if selectedView == self.eraserView {
                self.eraserTopConstraint?.constant -= 25
            } else {
                self.penTopConstraint?.constant -= 25
            }

            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.layoutIfNeeded()
            }
        }
    }

    init(colors: [UIColor] = [.red, .blue, .darkGray]) {
        self.colors = colors

        super.init(frame: .zero)

        backgroundColor = .white

        let container = UIView()
        container.setContentHuggingPriority(.required, for: .horizontal)

        pixelWidthView.selectionHandler = {
            self.delegate?.controlPanelDidSelectWidth(self)
        }

        penView.isUserInteractionEnabled = true
        penView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toolTapped(gesture:))))

        eraserView.isUserInteractionEnabled = true
        eraserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toolTapped(gesture:))))

        colorPicker.colorSelectionHandler = { [unowned self] color in
            self.setSelectedMode(mode: .draw)
            self.penView.nib.image = self.penView.nib.image?.overlayed(with: color)
            self.delegate?.controlPanel(self, didSelectColor: color)
        }

        // Constraints
        let penTopConstraint = penView.topAnchor.constraint(equalTo: container.topAnchor, constant: -20)
        self.penTopConstraint = penTopConstraint
        let eraserTopConstraint = eraserView.topAnchor.constraint(equalTo: container.topAnchor, constant: -20)
        self.eraserTopConstraint = eraserTopConstraint

        // Boilerplate constraints
        [container, penView, eraserView, colorPicker, pixelWidthView].forEach { (view: UIView) in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }

        NSLayoutConstraint.activate([

            pixelWidthView.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 8.0),
            pixelWidthView.widthAnchor.constraint(equalToConstant: 50.0),
            pixelWidthView.topAnchor.constraint(equalTo: container.topAnchor),
            pixelWidthView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            penView.leadingAnchor.constraint(equalTo: pixelWidthView.trailingAnchor, constant: 20.0),
            penView.trailingAnchor.constraint(equalTo: eraserView.leadingAnchor, constant: -20.0),
            penTopConstraint,
            eraserTopConstraint,

            colorPicker.leadingAnchor.constraint(equalTo: eraserView.trailingAnchor, constant: 20.0),
            colorPicker.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            colorPicker.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -8.0),

            container.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            container.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.heightAnchor.constraint(equalTo: heightAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    @objc func toolTapped(gesture: UITapGestureRecognizer) {
        if selectedView == gesture.view {
            selectedView?.shake()
            return
        } else {
            selectedView = gesture.view
        }
        delegate?.controlPanel(self, didChangeDrawMode: selectedView == penView ? .draw : .erase)
    }

    func setSelectedMode(mode: SketchMode) {
        switch mode {
        case .draw:
            selectedView = penView
        case .erase:
            selectedView = eraserView
        }

    }

    func setSelectedColor(_ color: UIColor) {
        colorPicker.set(color)
    }

    func setSelectedNibSize(_ size: NibSize) {
        pixelWidthView.update(with: size)
    }
}
