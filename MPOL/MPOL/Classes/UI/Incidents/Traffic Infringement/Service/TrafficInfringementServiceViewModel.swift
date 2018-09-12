//
//  TrafficInfringementServiceViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

public class TrafficInfringementServiceViewModel {
    public var title: String
    private(set) var report: TrafficInfringementServiceReport

    var people: [Person] {
        guard let incident = report.incident else { fatalError("Incident Doesn't Exist") }
        let entities = report.event?.entityManager.relationships(for: incident).map { $0.baseObject }
        return entities?.compactMap { $0 as? Person } ?? []
    }

    var currentLoadingManagerState: LoadingStateManager.State {
        return people.isEmpty ? .noContent : .loaded 
    }

    open var allEmails: [String] {

        let contacts = people.compactMap { $0.contacts }.flatMap { $0 }

        return contacts.filter { $0.type == .email }.compactMap { $0.value }
    }

    open var allMobiles: [String] {

        let contacts = people.compactMap { $0.contacts }.flatMap { $0 }

        return contacts.filter { $0.type == .mobile }.compactMap { $0.value }
    }

    open var allFullAddresses: [String] {
        return people.compactMap { $0.addresses }.flatMap { $0 }.compactMap { $0.fullAddress }
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    public required init(report: Reportable) {

        guard let report = report as? TrafficInfringementServiceReport else {
            fatalError("Failed to report to traffic infringment service report")
        }

        self.report = report
        self.title = "Service"
    }

    public func selectedValues(for serviceType: ServiceType) -> [String] {

        var result = [String]()
        switch serviceType {
        case .email:
            if let email = report.selectedEmail {
                result.append(email)
            }
        case .mms:
            if let mobile = report.selectedMobile {
                result.append(mobile)
            }
        case .post:
            if let address = report.selectedAddress {
                result.append(address)
            }
        }
        return result
    }

    public func selectedServiceType(type: ServiceType) {
        report.selectedServiceType = type
    }

    public func setSelectedEmail(emails: [String]) {
        report.selectedEmail = emails.first
    }

    public func setSelectedMobile(mobiles: [String]) {
        report.selectedMobile = mobiles.first
    }

    public func setSelectedAddress(addresses: [String]) {
        report.selectedAddress = addresses.first
    }

    public func updateValidation() {

        var result = false
        if !people.isEmpty {
            if let type = report.selectedServiceType {
                result = true
                switch type {
                case .email:
                    result = (report.selectedEmail != nil && report.selectedAddress != nil)
                case .mms:
                    result = (report.selectedMobile != nil && report.selectedAddress != nil)
                case .post:
                    result = report.selectedAddress != nil
                }
            }
        }
        report.hasContactDetails = result
    }

}

