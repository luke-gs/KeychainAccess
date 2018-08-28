//
//  WaveformView.swift
//  MPOLKit
//
//  Created by QHMW64 on 25/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class WaveformView: UIView {

    public var numberOfWaves: Int = 3 
    public var waveColor: UIColor = UIColor(red:0.26, green:0.65, blue:0.86, alpha:1.00)
    public var primaryLineWidth: CGFloat = 5.0
    public var secondaryLineWidth: CGFloat = 2.0

    public private(set) var amplitude: CGFloat = 1.0
    public var idleAmplitude: CGFloat = 0.01
    public var frequency: CGFloat = 1.5
    private var phase: CGFloat = 0.0
    public var density: CGFloat = 5.0

    public var phaseShift: CGFloat = -0.15

    public init() {
        super.init(frame: .zero)
        backgroundColor = .clear
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.clear(rect)

        backgroundColor?.set()
        context.fill(rect)

        for i in stride(from: 0, to: numberOfWaves, by: 1) {
            let strokeWidth = i == 0 ? primaryLineWidth : secondaryLineWidth
            context.setLineWidth(strokeWidth)

            let halfHeight = bounds.height * 0.5
            let width = bounds.width
            let midX = bounds.midX

            let maxAmplitude = halfHeight - (strokeWidth * 2)
            let progress: CGFloat = 1.0 - CGFloat(i) / CGFloat(numberOfWaves)
            let normalAmplitude = (1.5 * progress - (2.0 / CGFloat(numberOfWaves))) * amplitude

            let multiplier = min(1.0, (progress / 3.0 * 2.0) + (1/3))
            waveColor.withAlphaComponent(multiplier * waveColor.cgColor.alpha).set()

            for x in stride(from: 0, to: width + density, by: density) {
                let scaling: CGFloat = -pow(1 / midX * (x - midX), 2) + 1

                let pi = CGFloat.pi
                let y: CGFloat = scaling * maxAmplitude * normalAmplitude * sin(2 * pi * (x / width) * frequency + phase) + halfHeight
                let nextPoint = CGPoint(x: x, y: y)

                if x == 0 {
                    context.move(to: nextPoint)
                } else {
                    context.addLine(to: nextPoint)
                }
            }

            context.strokePath()
        }
    }

    public func updateWave(for level: CGFloat) {
        phase += phaseShift
        amplitude = max(level, idleAmplitude)

        setNeedsDisplay()
    }
}
