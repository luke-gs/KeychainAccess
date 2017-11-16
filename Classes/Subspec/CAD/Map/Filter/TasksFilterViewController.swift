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
    
    // MARK: - Views
    
    open var scrollView: UIScrollView!
    open var sectionsStackView: UIStackView!
    
    // MARK: General
    
    open var generalSection: UIView!
    open var generalHeader: TasksFilterHeader!
    open var resultsOutsidePatrolCheckbox: CheckBox!
    open var generalSeparator: UIView!
    
    // MARK: Incidents
    
    open var incidentsSection: UIView!
    open var incidentsHeader: TasksFilterHeader!
    open var priorityLabel: UILabel!
    open var p1Checkbox: CheckBox!
    open var p2Checkbox: CheckBox!
    open var p3Checkbox: CheckBox!
    open var p4Checkbox: CheckBox!
    open var priorityCheckboxStack: UIStackView!
    open var prioritySeparator: UIView!
    
    open var incidentsLabel: UILabel!
    open var resourcedCheckbox: CheckBox!
    open var unresourcedCheckbox: CheckBox!
    open var incidentStatusCheckboxStack: UIStackView!
    open var incidentsSeparator: UIView!
    
    // MARK: Patrol
    
    open var patrolSection: UIView!
    open var patrolHeader: TasksFilterHeader!
    open var patrolSeparator: UIView!
    
    // MARK: Broadcasts
    
    open var broadcastsSection: UIView!
    open var broadcastsHeader: TasksFilterHeader!
    open var broadcastsSeparator: UIView!
    
    // MARK: Resources
    
    open var resourcesSection: UIView!
    open var resourcesHeader: TasksFilterHeader!
    open var resourcesSeparator: UIView!
    open var resourcesLabel: UILabel!
    open var taskedCheckbox: CheckBox!
    open var untaskedCheckbox: CheckBox!
    open var taskStatusCheckboxStack: UIStackView!
    
    // MARK: Footer
    
    open var footerSection: UIView!
    open var footerSeparator: UIView!
    open var resetButton: UIButton!
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
    }

    // MARK: - Setup
    
    /// Creates and styles views
    private func setupViews() {
        edgesForExtendedLayout.remove(.top)
        
        // MARK: General
        
        generalSection = UIView()
        generalSection.translatesAutoresizingMaskIntoConstraints = false
        
        generalHeader = TasksFilterHeader(title: "General", showsToggle: false)
        generalHeader.translatesAutoresizingMaskIntoConstraints = false
        
        resultsOutsidePatrolCheckbox = CheckBox()
        resultsOutsidePatrolCheckbox.setTitle("Show results outside my Patrol Area", for: .normal)
        resultsOutsidePatrolCheckbox.setTitleColor(#colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1), for: .normal)
        resultsOutsidePatrolCheckbox.translatesAutoresizingMaskIntoConstraints = false
        
        generalSeparator = UIView()
        generalSeparator.backgroundColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 0.24)
        generalSeparator.translatesAutoresizingMaskIntoConstraints = false

        generalSection.addSubview(generalHeader)
        generalSection.addSubview(resultsOutsidePatrolCheckbox)
        generalSection.addSubview(generalSeparator)
        
        // MARK: Incidents
        
        incidentsSection = UIView()
        incidentsSection.translatesAutoresizingMaskIntoConstraints = false
        
        incidentsHeader = TasksFilterHeader(title: "Incidents", showsToggle: true)
        incidentsHeader.translatesAutoresizingMaskIntoConstraints = false
        
        priorityLabel = UILabel()
        priorityLabel.font = UIFont.systemFont(ofSize: 13)
        priorityLabel.text = "Priority"
        priorityLabel.textColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        p1Checkbox = CheckBox()
        p1Checkbox.setTitle("P1", for: .normal)
        p1Checkbox.setTitleColor(#colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1), for: .normal)
        p1Checkbox.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        p1Checkbox.isSelected = true
        p1Checkbox.isEnabled = false
        
        p2Checkbox = CheckBox()
        p2Checkbox.setTitle("P2", for: .normal)
        p2Checkbox.setTitleColor(#colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1), for: .normal)
        p2Checkbox.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        p2Checkbox.isSelected = true
        
        p3Checkbox = CheckBox()
        p3Checkbox.setTitle("P3", for: .normal)
        p3Checkbox.setTitleColor(#colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1), for: .normal)
        p3Checkbox.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        p3Checkbox.isSelected = true
        
        p4Checkbox = CheckBox()
        p4Checkbox.setTitle("P4", for: .normal)
        p4Checkbox.setTitleColor(#colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1), for: .normal)
        p4Checkbox.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        p4Checkbox.isSelected = true
        
        priorityCheckboxStack = UIStackView(arrangedSubviews: [p1Checkbox, p2Checkbox, p3Checkbox, p4Checkbox, UIView()])
        priorityCheckboxStack.axis = .horizontal
        priorityCheckboxStack.alignment = .leading
        priorityCheckboxStack.distribution = .fill
        priorityCheckboxStack.spacing = LayoutConstants.checkboxSpacing
        priorityCheckboxStack.translatesAutoresizingMaskIntoConstraints = false
        
        prioritySeparator = UIView()
        prioritySeparator.backgroundColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 0.24)
        prioritySeparator.translatesAutoresizingMaskIntoConstraints = false
        
        incidentsLabel = UILabel()
        incidentsLabel.font = UIFont.systemFont(ofSize: 13)
        incidentsLabel.text = "Show incidents that are"
        incidentsLabel.textColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
        incidentsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        resourcedCheckbox = CheckBox()
        resourcedCheckbox.setTitle("Resourced", for: .normal)
        resourcedCheckbox.setTitleColor(#colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1), for: .normal)
        resourcedCheckbox.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        resourcedCheckbox.translatesAutoresizingMaskIntoConstraints = false
        
        unresourcedCheckbox = CheckBox()
        unresourcedCheckbox.setTitle("Unresourced", for: .normal)
        unresourcedCheckbox.setTitleColor(#colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1), for: .normal)
        unresourcedCheckbox.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        unresourcedCheckbox.translatesAutoresizingMaskIntoConstraints = false
        
        incidentStatusCheckboxStack = UIStackView(arrangedSubviews: [resourcedCheckbox, unresourcedCheckbox, UIView()])
        incidentStatusCheckboxStack.axis = .horizontal
        incidentStatusCheckboxStack.spacing = LayoutConstants.checkboxSpacing
        incidentStatusCheckboxStack.translatesAutoresizingMaskIntoConstraints = false
        
        incidentsSeparator = UIView()
        incidentsSeparator.backgroundColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 0.24)
        incidentsSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        incidentsSection.addSubview(incidentsHeader)
        incidentsSection.addSubview(priorityLabel)
        incidentsSection.addSubview(priorityCheckboxStack)
        incidentsSection.addSubview(prioritySeparator)
        incidentsSection.addSubview(incidentsLabel)
        incidentsSection.addSubview(incidentStatusCheckboxStack)
        incidentsSection.addSubview(incidentsSeparator)
        
        // MARK: Patrol
        
        patrolSection = UIView()
        patrolSection.translatesAutoresizingMaskIntoConstraints = false
        
        patrolHeader = TasksFilterHeader(title: "Patrol", showsToggle: true)
        patrolHeader.translatesAutoresizingMaskIntoConstraints = false
        
        patrolSeparator = UIView()
        patrolSeparator.backgroundColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 0.24)
        patrolSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        patrolSection.addSubview(patrolHeader)
        patrolSection.addSubview(patrolSeparator)
        
        // MARK: Broadcasts
        
        broadcastsSection = UIView()
        broadcastsSection.translatesAutoresizingMaskIntoConstraints = false
        
        broadcastsHeader = TasksFilterHeader(title: "Broadcasts", showsToggle: true)
        broadcastsHeader.translatesAutoresizingMaskIntoConstraints = false
        
        broadcastsSeparator = UIView()
        broadcastsSeparator.backgroundColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 0.24)
        broadcastsSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        broadcastsSection.addSubview(broadcastsHeader)
        broadcastsSection.addSubview(broadcastsSeparator)
        
        // MARK: Resources
        
        resourcesSection = UIView()
        resourcesSection.translatesAutoresizingMaskIntoConstraints = false
        
        resourcesHeader = TasksFilterHeader(title: "Resources", showsToggle: true)
        resourcesHeader.translatesAutoresizingMaskIntoConstraints = false
        
        resourcesLabel = UILabel()
        resourcesLabel.font = UIFont.systemFont(ofSize: 13)
        resourcesLabel.text = "Show resources that are"
        resourcesLabel.textColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
        resourcesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        taskedCheckbox = CheckBox()
        taskedCheckbox.setTitle("Tasked", for: .normal)
        taskedCheckbox.setTitleColor(#colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1), for: .normal)
        taskedCheckbox.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        taskedCheckbox.translatesAutoresizingMaskIntoConstraints = false
        
        untaskedCheckbox = CheckBox()
        untaskedCheckbox.setTitle("Untasked", for: .normal)
        untaskedCheckbox.setTitleColor(#colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3843137255, alpha: 1), for: .normal)
        untaskedCheckbox.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        untaskedCheckbox.translatesAutoresizingMaskIntoConstraints = false
        
        taskStatusCheckboxStack = UIStackView(arrangedSubviews: [taskedCheckbox, untaskedCheckbox, UIView()])
        taskStatusCheckboxStack.axis = .horizontal
        taskStatusCheckboxStack.spacing = LayoutConstants.checkboxSpacing
        taskStatusCheckboxStack.translatesAutoresizingMaskIntoConstraints = false
        
        resourcesSeparator = UIView()
        resourcesSeparator.backgroundColor = #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 0.24)
        resourcesSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        resourcesSection.addSubview(resourcesHeader)
        resourcesSection.addSubview(resourcesLabel)
        resourcesSection.addSubview(taskStatusCheckboxStack)
        resourcesSection.addSubview(resourcesSeparator)
        
        // MARK: Stack
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        sectionsStackView = UIStackView(arrangedSubviews: [
            generalSection,
            incidentsSection,
            patrolSection,
            broadcastsSection,
            resourcesSection,
            UIView()
        ])
        
        sectionsStackView.axis = .vertical
        sectionsStackView.distribution = .fill
        sectionsStackView.spacing = LayoutConstants.sectionSpacing
        sectionsStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(sectionsStackView)
        
        // MARK: Footer

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

            // General
            
            generalHeader.topAnchor.constraint(equalTo: generalSection.topAnchor),
            generalHeader.leadingAnchor.constraint(equalTo: generalSection.leadingAnchor),
            generalHeader.trailingAnchor.constraint(equalTo: generalSection.trailingAnchor, constant: -24),
            
            resultsOutsidePatrolCheckbox.topAnchor.constraint(equalTo: generalHeader.bottomAnchor, constant: LayoutConstants.verticalMargin),
            resultsOutsidePatrolCheckbox.leadingAnchor.constraint(equalTo: generalSection.leadingAnchor),
            resultsOutsidePatrolCheckbox.trailingAnchor.constraint(equalTo: generalSection.trailingAnchor),
            
            generalSeparator.heightAnchor.constraint(equalToConstant: LayoutConstants.separatorHeight),
            generalSeparator.topAnchor.constraint(equalTo: resultsOutsidePatrolCheckbox.bottomAnchor, constant: LayoutConstants.separatorVerticalMargin),
            generalSeparator.leadingAnchor.constraint(equalTo: generalSection.leadingAnchor),
            generalSeparator.trailingAnchor.constraint(equalTo: generalSection.trailingAnchor),
            generalSeparator.bottomAnchor.constraint(equalTo: generalSection.bottomAnchor),
            
            // Incidents
            
            incidentsHeader.topAnchor.constraint(equalTo: incidentsSection.topAnchor),
            incidentsHeader.leadingAnchor.constraint(equalTo: incidentsSection.leadingAnchor),
            incidentsHeader.trailingAnchor.constraint(equalTo: incidentsSection.trailingAnchor, constant: -24),
            
            priorityLabel.topAnchor.constraint(equalTo: incidentsHeader.bottomAnchor, constant: LayoutConstants.verticalMargin),
            priorityLabel.leadingAnchor.constraint(equalTo: incidentsSection.leadingAnchor),
            priorityLabel.trailingAnchor.constraint(equalTo: incidentsSection.trailingAnchor),
            
            priorityCheckboxStack.topAnchor.constraint(equalTo: priorityLabel.bottomAnchor, constant: LayoutConstants.verticalMargin),
            priorityCheckboxStack.leadingAnchor.constraint(equalTo: incidentsSection.leadingAnchor, constant: -LayoutConstants.checkboxOffset),
            priorityCheckboxStack.trailingAnchor.constraint(equalTo: incidentsSection.trailingAnchor),
            
            prioritySeparator.heightAnchor.constraint(equalToConstant: LayoutConstants.separatorHeight),
            prioritySeparator.topAnchor.constraint(equalTo: priorityCheckboxStack.bottomAnchor, constant: LayoutConstants.separatorVerticalMargin),
            prioritySeparator.leadingAnchor.constraint(equalTo: incidentsSection.leadingAnchor),
            prioritySeparator.trailingAnchor.constraint(lessThanOrEqualTo: incidentsSection.trailingAnchor),
            prioritySeparator.widthAnchor.constraint(equalTo: incidentsSection.widthAnchor, multiplier: 0.5),
            
            incidentsLabel.topAnchor.constraint(equalTo: prioritySeparator.bottomAnchor, constant: LayoutConstants.verticalMargin),
            incidentsLabel.leadingAnchor.constraint(equalTo: incidentsSection.leadingAnchor),
            incidentsLabel.trailingAnchor.constraint(equalTo: incidentsSection.trailingAnchor),
            
            incidentStatusCheckboxStack.topAnchor.constraint(equalTo: incidentsLabel.bottomAnchor, constant: LayoutConstants.verticalMargin),
            incidentStatusCheckboxStack.leadingAnchor.constraint(equalTo: incidentsSection.leadingAnchor, constant: -LayoutConstants.checkboxOffset),
            incidentStatusCheckboxStack.trailingAnchor.constraint(equalTo: incidentsSection.trailingAnchor),
            
            incidentsSeparator.heightAnchor.constraint(equalToConstant: LayoutConstants.separatorHeight),
            incidentsSeparator.topAnchor.constraint(equalTo: incidentStatusCheckboxStack.bottomAnchor, constant: LayoutConstants.verticalMargin),
            incidentsSeparator.leadingAnchor.constraint(equalTo: incidentsSection.leadingAnchor),
            incidentsSeparator.trailingAnchor.constraint(equalTo: incidentsSection.trailingAnchor),
            incidentsSeparator.bottomAnchor.constraint(equalTo: incidentsSection.bottomAnchor),
            
            // Patrol
            
            patrolHeader.topAnchor.constraint(equalTo: patrolSection.topAnchor),
            patrolHeader.leadingAnchor.constraint(equalTo: patrolSection.leadingAnchor),
            patrolHeader.trailingAnchor.constraint(equalTo: patrolSection.trailingAnchor, constant: -24),
            
            patrolSeparator.heightAnchor.constraint(equalToConstant: LayoutConstants.separatorHeight),
            patrolSeparator.topAnchor.constraint(equalTo: patrolHeader.bottomAnchor, constant: LayoutConstants.separatorVerticalMargin),
            patrolSeparator.leadingAnchor.constraint(equalTo: patrolSection.leadingAnchor),
            patrolSeparator.trailingAnchor.constraint(equalTo: patrolSection.trailingAnchor),
            patrolSeparator.bottomAnchor.constraint(equalTo: patrolSection.bottomAnchor),
            
            // Broadcasts
            
            broadcastsHeader.topAnchor.constraint(equalTo: broadcastsSection.topAnchor),
            broadcastsHeader.leadingAnchor.constraint(equalTo: broadcastsSection.leadingAnchor),
            broadcastsHeader.trailingAnchor.constraint(equalTo: broadcastsSection.trailingAnchor, constant: -24),
            
            broadcastsSeparator.heightAnchor.constraint(equalToConstant: LayoutConstants.separatorHeight),
            broadcastsSeparator.topAnchor.constraint(equalTo: broadcastsHeader.bottomAnchor, constant: LayoutConstants.separatorVerticalMargin),
            broadcastsSeparator.leadingAnchor.constraint(equalTo: broadcastsSection.leadingAnchor),
            broadcastsSeparator.trailingAnchor.constraint(equalTo: broadcastsSection.trailingAnchor),
            broadcastsSeparator.bottomAnchor.constraint(equalTo: broadcastsSection.bottomAnchor),
            
            // Resources
            
            resourcesHeader.topAnchor.constraint(equalTo: resourcesSection.topAnchor),
            resourcesHeader.leadingAnchor.constraint(equalTo: resourcesSection.leadingAnchor),
            resourcesHeader.trailingAnchor.constraint(equalTo: resourcesSection.trailingAnchor, constant: -24),
            
            resourcesLabel.topAnchor.constraint(equalTo: resourcesHeader.bottomAnchor, constant: LayoutConstants.verticalMargin),
            resourcesLabel.leadingAnchor.constraint(equalTo: resourcesSection.leadingAnchor),
            resourcesLabel.trailingAnchor.constraint(equalTo: resourcesSection.trailingAnchor),
            
            taskStatusCheckboxStack.topAnchor.constraint(equalTo: resourcesLabel.bottomAnchor, constant: LayoutConstants.verticalMargin),
            taskStatusCheckboxStack.leadingAnchor.constraint(equalTo: resourcesSection.leadingAnchor, constant: -LayoutConstants.checkboxOffset),
            taskStatusCheckboxStack.trailingAnchor.constraint(equalTo: resourcesSection.trailingAnchor),
            
            resourcesSeparator.heightAnchor.constraint(equalToConstant: LayoutConstants.separatorHeight),
            resourcesSeparator.topAnchor.constraint(equalTo: taskStatusCheckboxStack.bottomAnchor, constant: LayoutConstants.verticalMargin),
            resourcesSeparator.leadingAnchor.constraint(equalTo: resourcesSection.leadingAnchor),
            resourcesSeparator.trailingAnchor.constraint(equalTo: resourcesSection.trailingAnchor),
            resourcesSeparator.bottomAnchor.constraint(equalTo: resourcesSection.bottomAnchor),
            
            // Footer
            
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
