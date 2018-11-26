//
//  DefaultEventLocationViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

public class DefaultEventLocationViewModel {

    /// This variable matches the 'eventLocation' location involvement manefest item
    public static var eventLocationInvolvement = NSLocalizedString("Event Location", comment: "")
    weak var report: DefaultLocationReport!

    /// As we prefill the event with an empty location this count returns 1 when locations array is empty
    var displayCount: UInt {
        let count = report.eventLocations.isEmpty ? 1 : report.eventLocations.count
        return UInt(count)
    }

    init(report: DefaultLocationReport) {
        self.report = report
    }

    func construct(for viewController: DefaultEventLocationViewController, with builder: FormBuilder) {
        builder.title = NSLocalizedString("Location", comment: "")
        builder.enforceLinearLayout = .always

        builder += LargeTextHeaderFormItem(text: String.localizedStringWithFormat(NSLocalizedString("Locations (%d)", comment: ""), displayCount))
            .separatorColor(.clear)
            .actionButton(title: NSLocalizedString("Add", comment: ""),
                          handler: { [weak viewController] _ in
                            guard let viewController = viewController else { return }
                            viewController.addLocation()
            })

        // if we have no location add empty location to list
        if report.eventLocations.isEmpty {
            builder += SubtitleFormItem(title: NSLocalizedString("Not Yet Specified", comment: ""))
                .subtitle(DefaultEventLocationViewModel.eventLocationInvolvement)
                .image(AssetManager.shared.image(forKey: .entityLocation))
                .accessory(ItemAccessory.pencil)
                .onSelection({ [weak viewController] cell in
                    guard let viewController = viewController else { return }
                    viewController.onSelection(cell)
                })
            // else add location to list for each in array
        } else {

            let deleteAction = CollectionViewFormEditAction(title: NSLocalizedString("Remove", comment: ""),
                                                            color: UIColor.red, handler: { [weak self] (_, indexPath) in
                                                                guard let self = self else { return }
                                                                self.removeLocation(at: indexPath)
                                                                viewController.sidebarItem.count = UInt(self.displayCount)
                                                                viewController.reloadForm()
            })

            for (offset, location) in report.eventLocations.enumerated() {

                builder += SubtitleFormItem(title: location.addressString)
                    .subtitle(invovlements(for: location))
                    .image(AssetManager.shared.image(forKey: .entityLocation))
                    .accessory(ItemAccessory.pencil)
                    .onSelection({ [weak viewController] cell in
                        guard let viewController = viewController else { return }
                        viewController.onSelection(cell)
                    })
                    .editActions(offset > 0 ? [deleteAction] : [])
            }
        }
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    func invovlements(for location: EventLocation) -> StringSizable? {

        let noInvolvementText = NSAttributedString(string: NSLocalizedString("No involvements", comment: ""),
                                                   attributes: [.foregroundColor: UIColor.orangeRed])
        return location.involvement ?? noInvolvementText
    }

    func removeLocation(at indexPath: IndexPath) {

        // check if location is 'Event Location' if so move this involvement to first location in list
        if report.eventLocations[indexPath.row].involvement?.string == DefaultEventLocationViewModel.eventLocationInvolvement {
            report.eventLocations[0].involvement = DefaultEventLocationViewModel.eventLocationInvolvement
        }

        report.eventLocations.remove(at: indexPath.row)
    }
}
