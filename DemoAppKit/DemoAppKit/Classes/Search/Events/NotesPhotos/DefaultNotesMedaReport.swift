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

public class DefaultNotesMediaReport: EventReportable, MediaContainer {
    public let weakEvent: Weak<Event>

    var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    public var media: [MediaAsset] = []
    var operationName: String?
    var freeText: String?

    public var evaluator: Evaluator = Evaluator()

    public required init(event: Event) {
        self.weakEvent = Weak(event)
        commonInit()
    }

    public func commonInit() {
        if let event = self.event {
            evaluator.addObserver(event)
        }
        evaluator.registerKey(.viewed) { [weak self] in
            return self?.viewed ?? false
        }
    }

    // Coding

    public static var supportsSecureCoding: Bool = true

    private enum Coding: String {
        case media
        case operationName
        case freeText
        case event
    }

    public required init?(coder aDecoder: NSCoder) {
        media = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.media.rawValue) as! [MediaAsset]
        operationName = aDecoder.decodeObject(of: NSString.self, forKey: Coding.operationName.rawValue) as String?
        freeText = aDecoder.decodeObject(of: NSString.self, forKey: Coding.freeText.rawValue) as String?
        weakEvent = aDecoder.decodeWeakObject(forKey: Coding.event.rawValue)
        commonInit()
    }


    public func encode(with aCoder: NSCoder) {
        aCoder.encode(media, forKey: Coding.media.rawValue)
        aCoder.encode(operationName, forKey: Coding.operationName.rawValue)
        aCoder.encode(freeText, forKey: Coding.freeText.rawValue)
    }

    // Media
   public func add(_ media: [MediaAsset]) {
        media.forEach {
            if !self.media.contains($0) {
                self.media.append($0)
            }
        }
    }

   public func remove(_ media: [MediaAsset]) {
        media.forEach { asset in
            if let index = self.media.index(where: { $0 == asset }) {
                self.media.remove(at: index)
            }
        }
    }

    // Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
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
