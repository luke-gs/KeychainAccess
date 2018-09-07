//
//  PersonCriminalHistoryViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

open class PersonCriminalHistoryViewModel: EntityDetailFilterableFormViewModel {
    
    private var person: Person? {
        return entity as? Person
    }
    
    private var criminalHistory: [CriminalHistory] {
        var history: [CriminalHistory] = offenderCharges
        history.append(contentsOf: offenderConvictions)
        return history
    }

    private var offenderCharges: [OffenderCharge] {
        return person?.offenderCharges ?? []
    }

    private var offenderConvictions: [OffenderConviction] {
        return person?.offenderConvictions ?? []
    }
    
    // MARK: - EntityDetailFormViewModel
    
    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {

        builder.title = title
        builder.enforceLinearLayout = .always

        let offenderCharges = filteredOffenderCharges
        if !offenderCharges.isEmpty {
            builder += LargeTextHeaderFormItem(text: headerForCharges())
                .separatorColor(.clear)
            
            for item in offenderCharges {

                let display = OffenderChargeDisplay(item)
                builder += display.formItem()
                    .highlightStyle(.fade)
                    .onSelection({ [weak self] _ in
                        self?.presentCriminalHistorySummary(in: viewController, criminalHistory: item)
                    })
            }
        }

        let offenderConvictions = filteredOffenderConvictions
        if !offenderConvictions.isEmpty {
            builder += LargeTextHeaderFormItem(text: headerForConvictions())
                .separatorColor(.clear)

            for item in offenderConvictions {

                let display = OffenderConvictionDisplay(item)
                builder += display.formItem()
                    .highlightStyle(.fade)
                    .onSelection({ [weak self] _ in
                        self?.presentCriminalHistorySummary(in: viewController, criminalHistory: item)
                    })
            }
        }
        
        delegate?.updateLoadingState(filteredCriminalHistory.isEmpty ? .noContent : .loaded)
    }
    
    open override var title: String? {
        return NSLocalizedString("Criminal History", comment: "")
    }
    
    open override var noContentTitle: String? {
        return NSLocalizedString("No Records Found", comment: "")
    }
    
    open override var noContentSubtitle: String? {
        if criminalHistory.isEmpty {
            return NSLocalizedString("There is no Criminal History information available", comment: "")
        } else {
            return NSLocalizedString("This filter has no matching Criminal History", comment: "")
        }
    }
    
    open override  var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .list)
    }
    
    open override var sidebarCount: UInt? {
        return UInt(criminalHistory.count)
    }
    
    // MARK: - Filtering
    
    fileprivate var filterDateRange: FilterDateRange?
    fileprivate var sorting: DateSorting = .newest

    func filteredCriminalHistory<T: CriminalHistory>(from criminalHistory: [T]) -> [T] {
        var filtered = criminalHistory
        var filters: [FilterDescriptor<T>] = []
        if let dateRange = self.filterDateRange {
            filters.append(FilterRangeDescriptor<T, Date>(key: { $0.occurredDate }, start: dateRange.startDate, end: dateRange.endDate))
        }

        let sort: SortDescriptor<T>
        switch self.sorting {
        case .newest, .oldest:
            sort = SortDescriptor<T>(ascending: self.sorting == .oldest) { $0.occurredDate }
        }

        filtered = filtered.filter(using: filters)
        filtered = filtered.sorted(using: [sort])

        return filtered
    }

    var filteredOffenderCharges: [OffenderCharge] {
        return filteredCriminalHistory(from: offenderCharges)
    }

    var filteredOffenderConvictions: [OffenderConviction] {
        return filteredCriminalHistory(from: offenderConvictions)
    }

    private var filteredCriminalHistory: [CriminalHistory] {
        var history: [CriminalHistory] = filteredOffenderCharges
        history.append(contentsOf: filteredOffenderConvictions)
        return history
    }
    
    open override var isFilterApplied: Bool {
        return filterDateRange != nil || sorting != .newest
    }
    
    open override var filterOptions: [FilterOption] {
        let dateRange = filterDateRange ?? FilterDateRange(title: NSLocalizedString("Date Range", comment: ""), startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        let sorting = FilterList(title: NSLocalizedString("Sort By", comment: ""), displayStyle: .list, options: DateSorting.allCases, selectedIndexes: DateSorting.allCases.indexes(where: { self.sorting == $0 }))
        
        return [dateRange, sorting]
    }
    
    open override func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        controller.presentingViewController?.dismiss(animated: true)
        
        guard applyingChanges else { return }
        
        controller.filterOptions.forEach {
            switch $0 {
            case let filterList as FilterList where filterList.options.first is DateSorting:
                self.sorting = filterList.options[filterList.selectedIndexes].first as? DateSorting ?? self.sorting
            case let dateRange as FilterDateRange:
                if dateRange.startDate == nil && dateRange.endDate == nil {
                    self.filterDateRange = nil
                } else {
                    self.filterDateRange = dateRange
                }
            default:
                break
            }
        }
        
        delegate?.updateBarButtonItems()
        delegate?.reloadData()
    }

    open func headerForConvictions() -> String? {
        return String.localizedStringWithFormat(NSLocalizedString("%d Conviction(s)", comment: ""), filteredOffenderConvictions.count)
    }

    open func headerForCharges() -> String? {
        return String.localizedStringWithFormat(NSLocalizedString("%d Charge(s)", comment: ""), filteredOffenderCharges.count)
    }
    
    open func title(for item: CriminalHistory) -> String? {
        return item.primaryCharge?.ifNotEmpty() ?? NSLocalizedString("Unknown Offence", comment: "")
    }
    
    open func subtitle(for item: CriminalHistory) -> String? {
        let lastOccurred: String
        if let date = item.occurredDate {
            lastOccurred = DateFormatter.preferredDateStyle.string(from: date)
        } else {
            lastOccurred = NSLocalizedString("Unknown", comment: "Unknown date")
        }
        return String(format: NSLocalizedString("Last occurred: %@", comment: ""), lastOccurred)
    }

    private func presentCriminalHistorySummary(in viewController: UIViewController, criminalHistory: CriminalHistory) {
        let viewModel = CriminalHistorySummaryViewModel(criminalHistory: criminalHistory)
        let criminalHistoryVC = CriminalHistorySummaryViewController(viewModel: viewModel)

        let navController = ThemedNavigationController(rootViewController: criminalHistoryVC)
        navController.modalPresentationStyle = .formSheet
        viewController.present(navController, animated: true, completion: nil)
    }

}

public struct OffenderConvictionDisplay: DetailDisplayable, FormItemable {
    let offenderConviction: OffenderConviction

    public init(_ offenderConviction: OffenderConviction) {
        self.offenderConviction = offenderConviction
    }

    public var title: StringSizing? {
        let title = offenderConviction.primaryCharge?.ifNotEmpty() ?? NSLocalizedString("Unknown Offence", comment: "")
        return title.sizing(withNumberOfLines: 0)
    }

    public var subtitle: StringSizing? {
        guard let courtName = offenderConviction.courtName else {
            return NSLocalizedString("Unknown conviction information", comment: "").sizing(withNumberOfLines: 0)
        }

        let dateString: String
        if let date = offenderConviction.occurredDate {
            dateString = DateFormatter.preferredDateStyle.string(from: date)
        } else {
            dateString = NSLocalizedString("Unknown date", comment: "Unknown date")
        }
        
        let locationString = offenderConviction.jurisdiction != nil ? " (\(offenderConviction.jurisdiction!))": ""
        return String(format: NSLocalizedString("Convicted by %@ on %@%@", comment: ""), courtName, dateString, locationString).sizing(withNumberOfLines: 0)
    }

    public var detail: StringSizing? {
        let title = offenderConviction.offenceDescription?.ifNotEmpty() ?? NSLocalizedString("Unknown Offence", comment: "")
        return title.sizing(withNumberOfLines: 0)
    }
}

public struct OffenderChargeDisplay: DetailDisplayable, FormItemable {
    let offenderCharge: OffenderCharge

    public init(_ offenderCharge: OffenderCharge) {
        self.offenderCharge = offenderCharge
    }


    public var title: StringSizing? {
        let title = offenderCharge.primaryCharge?.ifNotEmpty() ?? NSLocalizedString("Unknown Offence", comment: "")
        return title.sizing(withNumberOfLines: 0)
    }

    public var subtitle: StringSizing? {
        guard let courtName = offenderCharge.courtName else {
            return NSLocalizedString("Unknown charge information", comment: "").sizing(withNumberOfLines: 0)
        }

        let dateString: String
        if let date = offenderCharge.occurredDate {
            dateString = DateFormatter.preferredDateStyle.string(from: date)
        } else {
            dateString = NSLocalizedString("Unknown date", comment: "Unknown date")
        }
        return String(format: NSLocalizedString("Charged by %@ on %@", comment: ""), courtName, dateString).sizing(withNumberOfLines: 0)
    }

    public var detail: StringSizing? {

        let next: String
        if let date = offenderCharge.nextCourtDate {
            next = DateFormatter.preferredDateStyle.string(from: date)
        } else {
            next = NSLocalizedString("Unknown date", comment: "Unknown date")
        }
        return String(format: NSLocalizedString("Next Court Date: %@", comment: ""), next).sizing(withNumberOfLines: 0)
    }
}
