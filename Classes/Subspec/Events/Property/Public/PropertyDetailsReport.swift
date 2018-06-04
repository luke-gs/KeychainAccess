//
//  PropertyDetailsReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public class PropertyDetailsReport: MediaContainer {
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
    }

    func add(_ media: [MediaAsset]) {
        self.media.append(contentsOf: media)
    }

    func remove(_ media: [MediaAsset]) {
        for item in media {
            guard let index = self.media.index(of: item) else { return }
            self.media.remove(at: index)
        }
    }
}
