//
//  DefaultEntitiesListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

class DefaultEntitiesListViewModel: EntitiesListViewModel {

    weak var delegate: EntityEditActionable?
    let report: DefaultEntitiesListReport
    let incidentType: IncidentType
    var entitySelectionViewModel: EntitySummarySelectionViewModel
    var selectedInvolvements: [String]?
    var building: AdditionalActionBuilding = DefaultAdditionalActionBuilding()
    var screenBuilding: AdditionalActionScreenBuilding = DefaultAdditionalActionScreenBuilding()

    required init(report: DefaultEntitiesListReport, incidentType: IncidentType) {
        self.report = report
        self.incidentType = incidentType

        let createdSectionViewModel = CreatedEntitySummarySelectionSectionViewModel()
        let recentSectionViewModel = RecentEntitySummarySelectionSectionViewModel()
        createdSectionViewModel.allowedEntityTypes = [Person.self, Vehicle.self, Address.self, Organisation.self]
        recentSectionViewModel.allowedEntityTypes = [Person.self, Vehicle.self, Address.self, Organisation.self]

        self.entitySelectionViewModel = EntitySummarySelectionViewModel(sections: [createdSectionViewModel, recentSectionViewModel])
    }

    func displayable(for entity: MPOLKitEntity) -> EntitySummaryDisplayable {
        switch entity {
        case is Person:
            return PersonSummaryDisplayable(entity)
        case is Vehicle:
            return VehicleSummaryDisplayable(entity)
        case is Organisation:
            return OrganisationSummaryDisplayable(entity)
        case is Address:
            return AddressSummaryDisplayable(entity)
        default:
            fatalError("No valid displayable for entity: \(entity.id)")
        }
    }

    func involvements(for entity: MPOLKitEntity) -> [String] {
        return incidentType.involvements(for: entity)
    }

    func additionalActions(for entity: MPOLKitEntity) -> [String] {

        var types = [AdditionalActionType]()
        switch entity {
        case is Person:
            // "Custody Report", "Referral Report"
            types = [.personSearch]
        case is Vehicle:
            // "Vehicle Tow Report", "Vehicle MVC Report", "Vehicle Search"
            types = [.vehicleTow]
        default:
            break
        }
        return types.map { $0.rawValue }
    }

    func report(for action: AdditionalAction) -> ActionReportable {
        switch action.additionalActionType {
        case .personSearch:
            return PersonSearchReport(incident: report.incident, additionalAction: action)
        case .vehicleTow:
            return VehicleTowReport(incident: report.incident, additionalAction: action)
        default:
            fatalError("Invalid AdditionActionType")
        }
    }

    func editItems(for entity: MPOLKitEntity) -> [ActionSheetButton] {
        var items = [ActionSheetButton]()
        let editImage = AssetManager.shared.image(forKey: .edit)
        let infoImage = AssetManager.shared.image(forKey: .infoFilled)
        if !involvements(for: entity).isEmpty {
            items.append(ActionSheetButton(title: "Manage Involvements", icon: editImage, tintColor: UIColor.black, action: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.completeEditAction(on: entity, actionType: .involvement)
            }))
        }
        if !additionalActions(for: entity).isEmpty {
            items.append(ActionSheetButton(title: "Manage Additional Actions", subtitle: nil, icon: editImage, tintColor: UIColor.black, action: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.completeEditAction(on: entity, actionType: .additionalAction)
            }))
        }
        items.append(ActionSheetButton(title: "View Record", icon: infoImage, action: { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.completeEditAction(on: entity, actionType: .viewRecord)
        }))
        return items
    }
}
