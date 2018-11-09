//
//  PropertyDetailsReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import PatternKit

public class PropertyDetailsReport: Codable, MediaContainer {
    public var property: Property?
    public var details: [String: String] = [:]
    public var involvements: [String]?
    public var media: [MediaAsset] = []

    public required init() {}

    public convenience init(copyingReport: PropertyDetailsReport) {
        self.init()
        self.property = copyingReport.property
        self.details = copyingReport.details
        self.involvements = copyingReport.involvements
        self.media = copyingReport.media

        // Do a quick check to see that the media items even exist
        // TODO: Create a datastore which doesn't delete items from the system until onDone
        // TODO: FIX THIS SHIT
        var items = [MediaAsset]()
        for item in copyingReport.media {
            if FileManager.default.fileExists(at: item.url) {
                items.append(item)
            } else {
                copyingReport.remove([item])
            }
        }
        self.media = items
    }

    public func add(_ media: [MediaAsset]) {
        self.media.append(contentsOf: media)
    }

    public func remove(_ media: [MediaAsset]) {
        for item in media {
            guard let index = self.media.index(of: item) else { continue }
            self.media.remove(at: index)
        }
    }
}
