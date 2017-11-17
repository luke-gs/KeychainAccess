//
//  TasksFilterViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 15/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksFilterViewController: UIViewController {
    
    private struct LayoutConstants {
        static let sectionSpacing: CGFloat = 32
        static let verticalMargin: CGFloat = 16
        static let footerHeight: CGFloat = 64
        static let separatorVerticalMargin: CGFloat = 24
        static let separatorHeight: CGFloat = 1
        static let checkboxSpacing: CGFloat = 32
        /// Checkbox class strangely has a slight leading offset
        static let checkboxOffset: CGFloat = 5
    }
    
    public let sections: [MapFilterSection]
    
    // MARK: - Views
    
    open var scrollView: UIScrollView!
    open var sectionsStackView: UIStackView!
    
    open var footerSection: UIView!
    open var footerSeparator: UIView!
    open var resetButton: UIButton!
    
    public init(sections: [MapFilterSection]) {
        self.sections = sections
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
    }

    // MARK: - Setup
    
    /// Creates and styles views
    private func setupViews() {
        edgesForExtendedLayout.remove(.top)
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let sectionViews: [MapFilterSectionView] = sections.map {
            let section = MapFilterSectionView(section: $0)
            return section
        }
        
        sectionsStackView = UIStackView(arrangedSubviews: sectionViews + [UIView()])
        
        sectionsStackView.axis = .vertical
        sectionsStackView.distribution = .fill
        sectionsStackView.spacing = LayoutConstants.sectionSpacing
        sectionsStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(sectionsStackView)
        footerSection = UIView()
        footerSection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerSection)

        footerSeparator = UIView()
        footerSeparator.backgroundColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 0.24)
        footerSeparator.translatesAutoresizingMaskIntoConstraints = false
        footerSection.addSubview(footerSeparator)

        resetButton = UIButton()
        resetButton.setTitle("Reset Filter", for: .normal)
        resetButton.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        footerSection.addSubview(resetButton)
    }

    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).withPriority(.almostRequired),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).withPriority(.almostRequired),
            scrollView.bottomAnchor.constraint(equalTo: footerSection.topAnchor).withPriority(.almostRequired),
            scrollView.widthAnchor.constraint(equalTo: sectionsStackView.widthAnchor).withPriority(.almostRequired),
            
            sectionsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            sectionsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            sectionsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            sectionsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            footerSection.heightAnchor.constraint(equalToConstant: LayoutConstants.footerHeight),
            footerSection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerSection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerSection.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            footerSeparator.heightAnchor.constraint(equalToConstant: LayoutConstants.separatorHeight),
            footerSeparator.topAnchor.constraint(equalTo: footerSection.topAnchor),
            footerSeparator.leadingAnchor.constraint(equalTo: footerSection.leadingAnchor),
            footerSeparator.trailingAnchor.constraint(equalTo: footerSection.trailingAnchor),

            resetButton.topAnchor.constraint(equalTo: footerSection.topAnchor),
            resetButton.leadingAnchor.constraint(equalTo: footerSection.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: footerSection.trailingAnchor),
            resetButton.bottomAnchor.constraint(equalTo: footerSection.bottomAnchor),
        ])
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let wantsTransparentBackground = traitCollection.horizontalSizeClass != .compact
        let theme = ThemeManager.shared.theme(for: .current)
        view.backgroundColor = wantsTransparentBackground ? UIColor.clear : theme.color(forKey: .background)
    }
}
