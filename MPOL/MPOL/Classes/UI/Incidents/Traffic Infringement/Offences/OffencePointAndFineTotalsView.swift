//
//  OffencePointAndFineTotalsView.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class OffencePointAndFineTotalsView: UIView {

    let demeritsValueLabel = UILabel()
    let demeritsTitleLabel = UILabel()
    let fineValueLabel = UILabel()
    let fineTitleLabel = UILabel()
    let demeritsView = UIView()
    let fineView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.08)

        //default text and fonts
        demeritsTitleLabel.text = "Demerit Points"
        fineTitleLabel.text = "Total Fine"
        demeritsValueLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        demeritsTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        fineValueLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        fineTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)

        layoutViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutViews() {
        //add items to subview
        demeritsView.addSubview(demeritsValueLabel)
        demeritsView.addSubview(demeritsTitleLabel)
        fineView.addSubview(fineValueLabel)
        fineView.addSubview(fineTitleLabel)
        addSubview(demeritsView)
        addSubview(fineView)

        //layout constraints
        demeritsView.translatesAutoresizingMaskIntoConstraints = false
        fineView.translatesAutoresizingMaskIntoConstraints = false
        demeritsValueLabel.translatesAutoresizingMaskIntoConstraints = false
        demeritsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        fineValueLabel.translatesAutoresizingMaskIntoConstraints = false
        fineTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            //demerits view
            demeritsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            demeritsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            demeritsView.topAnchor.constraint(equalTo: topAnchor),
            demeritsView.trailingAnchor.constraint(equalTo: centerXAnchor),

            //fine view
            fineView.leadingAnchor.constraint(equalTo: demeritsView.trailingAnchor),
            fineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            fineView.topAnchor.constraint(equalTo: topAnchor),
            fineView.trailingAnchor.constraint(equalTo: trailingAnchor),

            //demerits value label
            demeritsValueLabel.topAnchor.constraint(equalTo: demeritsView.topAnchor, constant: 36),
            demeritsValueLabel.centerXAnchor.constraint(equalTo: demeritsView.centerXAnchor),

            //demerits title label
            demeritsTitleLabel.topAnchor.constraint(equalTo: demeritsValueLabel.bottomAnchor, constant: 14),
            demeritsTitleLabel.centerXAnchor.constraint(equalTo: demeritsView.centerXAnchor),
            demeritsTitleLabel.bottomAnchor.constraint(equalTo: demeritsView.bottomAnchor, constant: -36),

            //fine value label
            fineValueLabel.topAnchor.constraint(equalTo: fineView.topAnchor, constant: 36),
            fineValueLabel.centerXAnchor.constraint(equalTo: fineView.centerXAnchor),

            //fine title label
            fineTitleLabel.topAnchor.constraint(equalTo: fineValueLabel.bottomAnchor, constant: 14),
            fineTitleLabel.centerXAnchor.constraint(equalTo: fineView.centerXAnchor),
            fineTitleLabel.bottomAnchor.constraint(equalTo: fineView.bottomAnchor, constant: -36)
        ])
    }
}
