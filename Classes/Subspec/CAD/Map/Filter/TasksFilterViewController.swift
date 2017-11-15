//
//  TasksFilterViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 15/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksFilterViewController: UIViewController {
    
    // MARK: - Views
    
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
        
        
        sectionsStackView = UIStackView(arrangedSubviews: [
            generalSection,
            incidentsSection,
            UIView()
        ])
        sectionsStackView.axis = .vertical
        sectionsStackView.distribution = .fill
        sectionsStackView.spacing = LayoutConstants.sectionSpacing
        sectionsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sectionsStackView)
        
        sectionsStackView.backgroundColor = .green
    }
    
    private struct LayoutConstants {
        static let sectionSpacing: CGFloat = 32
        static let verticalMargin: CGFloat = 16
        static let separatorVerticalMargin: CGFloat = 24
        static let separatorHeight: CGFloat = 1
        static let checkboxSpacing: CGFloat = 32
        /// Checkbox class strangely has a slight leading offset
        static let checkboxOffset: CGFloat = 5
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            sectionsStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            sectionsStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            sectionsStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            sectionsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // General
            
            generalHeader.topAnchor.constraint(equalTo: generalSection.topAnchor),
            generalHeader.leadingAnchor.constraint(equalTo: generalSection.leadingAnchor),
            generalHeader.trailingAnchor.constraint(equalTo: generalSection.trailingAnchor),
            
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
            incidentsHeader.trailingAnchor.constraint(equalTo: incidentsSection.trailingAnchor),
            
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
            
        ])
    }
    
}
