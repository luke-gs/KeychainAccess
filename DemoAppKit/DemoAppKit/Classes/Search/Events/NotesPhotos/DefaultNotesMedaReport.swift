//
//  DefaultNotesMediaReport.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

open class DefaultNotesMediaReport: DefaultEventReportable, MediaContainer {

    var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    public var media: [MediaAsset] = []
    var operationName: String?
    var freeText: String?

    open override func configure(with event: Event) {
        super.configure(with: event)

        evaluator.registerKey(.viewed) { [weak self] in
            return self?.viewed ?? false
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case media
        case operationName
        case freeText
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        media = try container.decode([MediaAsset].self, forKey: .media)
        operationName = try container.decodeIfPresent(String.self, forKey: .operationName)
        freeText = try container.decodeIfPresent(String.self, forKey: .freeText)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(media, forKey: CodingKeys.media)
        try container.encode(operationName, forKey: CodingKeys.operationName)
        try container.encode(freeText, forKey: CodingKeys.freeText)

        try super.encode(to: encoder)
    }

    // Media
    open func add(_ media: [MediaAsset]) {
        media.forEach {
            if !self.media.contains($0) {
                self.media.append($0)
            }
        }
    }

   open func remove(_ media: [MediaAsset]) {
        media.forEach { asset in
            if let index = self.media.index(where: { $0 == asset }) {
                self.media.remove(at: index)
            }
        }
    }
}

extension DefaultNotesMediaReport: Summarisable {
    public var formItems: [FormItem] {
        var items = [FormItem]()
        items.append(LargeTextHeaderFormItem(text: "Media and Notes"))

        var photoCount = 0
        var audioCount = 0
        var videoCount = 0

        media.forEach { (mediaItem) in
            switch mediaItem.type {
            case .photo:
                photoCount += 1
            case .audio:
                audioCount += 1
            case .video:
                videoCount += 1
            }
        }

        items.append(RowDetailFormItem(title: "Photo Count", detail: "\(photoCount)"))
        items.append(RowDetailFormItem(title: "Audio Count", detail: "\(audioCount)"))
        items.append(RowDetailFormItem(title: "Video Count", detail: "\(videoCount)"))

        return items
    }
}
