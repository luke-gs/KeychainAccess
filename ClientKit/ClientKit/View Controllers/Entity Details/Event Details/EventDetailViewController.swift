//
//  EventDetailViewController.swift
//  Pods
//
//  Created by Rod Brown on 26/5/17.
//
//

import UIKit
import MPOLKit

open class EventDetailViewController: FormCollectionViewController {

    // MARK: - Related types


    /// Represents a section within an `EventDetailViewController`.
    public struct EventDetailSection {
        public var title: String?
        public var items: [EventDetailItem]
    }


    /// Represents an item within an `EventDetailViewController`.
    public struct EventDetailItem {
        public enum Style {
            case header
            case item
            case valueField
            case entity(EntitySummaryDisplayable)
        }

        public var style: Style
        public var title: String?
        public var detail: String?
        public var placeholder: String?
        public var image: UIImage?
        public var preferredColumnCount: Int
        public var minimumContentWidth: CGFloat
        public var numberOfLines: Int

        public init(style: Style = .valueField, title: String? = nil, detail: String? = nil, placeholder: String? = nil, image: UIImage? = nil, preferredColumnCount: Int = 3, minimumContentWidth: CGFloat = 180.0, numberOfLines: Int = 0) {
            self.numberOfLines = numberOfLines
            self.style = style
            self.title = title?.ifNotEmpty()
            self.detail = detail?.ifNotEmpty()
            self.placeholder = placeholder
            self.image = image
            self.preferredColumnCount = preferredColumnCount
            self.minimumContentWidth = minimumContentWidth
        }
    }


    // MARK: - Public properties

    /// The event to display. The default is `nil`.
    open var event: Event? {
        didSet {
            updateSections()
        }
    }


    open var sections: [EventDetailSection] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }


    // MARK: - Public methods

    open func updateSections() {
        guard let event = event else {
            self.sections = []
            return
        }

        var sections = [EventDetailSection]()

        let header = EventDetailSection(title: "DETAILS", items: [
            EventDetailItem(style: .header, title: event.eventType ?? "Event", detail: "#" + event.id, preferredColumnCount: 1),
            EventDetailItem(title: "Status", detail: event.status ?? "-", preferredColumnCount: 2),
            EventDetailItem(title: "Occurred On", detail: dateTimeDisplayString(for: event.effectiveDate), preferredColumnCount: 2),
            EventDetailItem(title: "Created On", detail: dateTimeDisplayString(for: event.dateCreated), preferredColumnCount: 2),
            EventDetailItem(title: "Created By", detail: event.createdBy ?? "-", preferredColumnCount: 2),
            EventDetailItem(title: "Description", detail: displayString(for: event.eventDescription), preferredColumnCount: 1)
        ])
        sections.append(header)

        if let addresses = event.addresses, addresses.count > 0 {
            let numberOfAddresses = addresses.count
            let addressItems = addresses.map { item -> EventDetailItem in
                let title: String
                if let date = item.reportDate {
                    title = String(format: NSLocalizedString("%@ - Recorded as at %@", bundle: .mpolKit, comment: ""), item.type ?? "Unknown", DateFormatter.mediumNumericDate.string(from: date))
                } else {
                    title = String(format: NSLocalizedString("%@ - Recorded date unknown", bundle: .mpolKit, comment: ""), item.type ?? "Unknown")
                }

                return EventDetailItem(title: title, detail: item.formatted(), image: AssetManager.shared.image(forKey: .location), preferredColumnCount: 1)
            }

            let addressSection = EventDetailSection(title: "\(numberOfAddresses == 0 ? "NO" : String(numberOfAddresses)) \(numberOfAddresses == 1 ? "ADDRESS" : "ADDRESSES")", items: addressItems)

            sections.append(addressSection)
        }

        if let associatedPersons = event.associatedPersons, associatedPersons.count > 0 {
            let numberOfPersons = associatedPersons.count
            let personItems = associatedPersons.map { EventDetailItem(style: .entity($0)) }
            let personSection = EventDetailSection(title: "\(numberOfPersons == 0 ? "NO" : String(numberOfPersons)) \(numberOfPersons == 1 ? "PERSON" : "PEOPLE")", items: personItems)

            sections.append(personSection)
        }

        if let associatedVehicles = event.associatedVehicles, associatedVehicles.count > 0 {
            let numberOfVehicles = associatedVehicles.count
            let vehicleItems = associatedVehicles.map { EventDetailItem(style: .entity($0)) }
            let vehicleSection = EventDetailSection(title: "\(numberOfVehicles == 0 ? "NO" : String(numberOfVehicles)) \(numberOfVehicles == 1 ? "VEHICLE" : "VEHICLES")", items: vehicleItems)

            sections.append(vehicleSection)
        }

        self.sections = sections
    }

    public let source: MPOLSource
    public let eventId: String

    required public init(source: MPOLSource, eventId: String) {
        self.source = source
        self.eventId = eventId

        super.init()

        self.title = "Event"

        let noContentView = loadingManager.noContentView
        noContentView.titleLabel.text = NSLocalizedString("No Event Found", bundle: .mpolKit, comment: "")
        noContentView.subtitleLabel.text = NSLocalizedString("There are no details for this event", bundle: .mpolKit, comment: "")
        loadingManager.loadingLabel.text = "Retrieving event"

        loadingManager.state = .loading

        APIManager.shared.fetchEntityDetails(in: source, with: EntityFetchRequest<Event>(id: eventId)).then { [weak self] event -> () in
            if let `self` = self {
                self.event = event
                self.loadingManager.state = .loaded
            }
        }.catch { [weak self] error in
            self?.loadingManager.state = .noContent
        }
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        guard let collectionView = self.collectionView else { return }

        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
        collectionView.register(EntityCollectionViewCell.self)
        collectionView.register(EntityListCollectionViewCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let isCompact = traitCollection.horizontalSizeClass == .compact
        if isCompact != (previousTraitCollection?.horizontalSizeClass == .compact) {
            collectionView?.reloadData()
        }
    }

    // MARK: - UICollectionViewDataSource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            view.showsExpandArrow = false
            view.text = sections[indexPath.section].title

            return view
        }

        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }

    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath.section].items[indexPath.item]
        switch item.style {
        case .header:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            cell.imageView.image = item.image
            cell.titleLabel.font = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
            cell.titleLabel.text = item.title
            cell.subtitleLabel.text = item.detail
            return cell
        case .item:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            cell.imageView.image = item.image
            cell.titleLabel.font = .preferredFont(forTextStyle: .headline)
            cell.titleLabel.text = item.title
            cell.subtitleLabel.text = item.detail
            return cell
        case .valueField:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
            cell.imageView.image = item.image
            cell.isEditable = false
            cell.titleLabel.text = item.title
            cell.valueLabel.text = item.detail
            cell.placeholderLabel.text = item.placeholder
            cell.valueLabel.numberOfLines = item.numberOfLines
            return cell
        case .entity(let entity):
            if traitCollection.horizontalSizeClass != .compact {
                let cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
                cell.decorate(with: entity)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(of: EntityListCollectionViewCell.self, for: indexPath)
                cell.decorate(with: entity)
                return cell
            }
        }
    }


    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }


    // MARK: - CollectionViewDelegateFormLayout

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        let section = sections[section]
        if section.title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            return 0.0
        }
        return CollectionViewFormHeaderView.minimumHeight
    }

    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let item = sections[indexPath.section].items[indexPath.item]

        switch item.style {
        case .entity:
            if traitCollection.horizontalSizeClass != .compact {
                return EntityCollectionViewCell.minimumContentWidth(forStyle: .hero)
            }
            return collectionView.bounds.width
        default: break
        }

        var columnCount = item.preferredColumnCount
        if columnCount > 1 {
            columnCount = min(layout.columnCountForSection(withMinimumItemContentWidth: item.minimumContentWidth, sectionEdgeInsets: sectionEdgeInsets), columnCount)
        }

        return layout.columnContentWidth(forColumnCount: columnCount, sectionEdgeInsets: sectionEdgeInsets)
    }

    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let item = sections[indexPath.section].items[indexPath.item]

        switch item.style {
        case .header:
            let titleFont: UIFont? = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
            let titleSizing = StringSizing(string: item.title ?? "", font: titleFont, numberOfLines: 0)
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: titleSizing, subtitle: item.detail?.ifNotEmpty(), inWidth: itemWidth, compatibleWith: traitCollection, imageSize: item.image?.size ?? .zero) + 15.0
        case .item:
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: item.title, subtitle: item.detail?.ifNotEmpty(), inWidth: itemWidth, compatibleWith: traitCollection, imageSize: item.image?.size ?? .zero)
        case .valueField:
            let valueSizing = StringSizing(string: item.detail ?? (item.placeholder ?? ""), font: nil, numberOfLines: item.numberOfLines)
            return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: item.title, value: valueSizing, inWidth: itemWidth, compatibleWith: traitCollection, imageSize: item.image?.size ?? .zero)
        case .entity:
            if traitCollection.horizontalSizeClass != .compact {
                return EntityCollectionViewCell.minimumContentHeight(forStyle: .hero, compatibleWith: traitCollection)
            }
            return EntityListCollectionViewCell.minimumContentHeight(compatibleWith: traitCollection)
        }
    }

    @objc (displayStringForArray:) open func displayString(for array: [String]?) -> String {
        return array?.joined(separator: "\n").ifNotEmpty() ?? "-"
    }

    @objc (displayStringForDateTime:) open func dateTimeDisplayString(for date: Date?) -> String {
        guard let date = date else { return "-" }
        return DateFormatter.longDateAndTime.string(from: date)
    }

    @objc (displayStringForDateOnly:) open func dateOnlyDisplayString(for date: Date?) -> String {
        guard let date = date else { return "-" }
        return DateFormatter.mediumNumericDate.string(from: date)
    }

    open func displayString(for bool: Bool?) -> String {
        guard let bool = bool else { return "-" }
        return bool ? NSLocalizedString("Yes", bundle: .mpolKit, comment: "Boolean value") : NSLocalizedString("No", bundle: .mpolKit, comment: "Boolean value")
    }

    @objc (displayStringForString:) open func displayString(for string: String?) -> String {
        guard let string = string?.ifNotEmpty() else {
            return "-"
        }
        return string
    }

}

