//
//  EntityDetailsSplitViewModel.swift
//  ClientKit
//
//  Created by RUI WANG on 15/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import PromiseKit

public struct EntityFetchRequest<T: MPOLKitEntityProtocol>: EntityFetchRequestable {
    
    public typealias ResultClass = T
    
    public let id: String
    
    public var parameters: [String: Any] {
        return ["id": id]
    }
}

public class EntityDetailsFetchRequest<T: MPOLKitEntity> {
    public let request: EntityFetchRequest<T>
    
    public let source: EntitySource
    
    public init(source: EntitySource, request: EntityFetchRequest<T>) {
        self.source = source
        self.request = request
    }
    
    public func fetch() -> Promise<T> {
        return fetchPromise().then { result in
            return result
        }
    }
    
    public func fetchPromise() -> Promise<T> {
        MPLRequiresConcreteImplementation()
    }
}

public class PersonFetchRequest: EntityDetailsFetchRequest<Person> {
    
    public init(source: MPOLSource, request: EntityFetchRequest<Person>) {
        super.init(source: source, request: request)
    }
    
    public override func fetchPromise() -> Promise<Person> {
        return MPOLAPIManager.shared.fetchEntityDetails(in: source as! MPOLSource, with: request)
    }
}

public class VehicleFetchRequest: EntityDetailsFetchRequest<Vehicle> {
    
    public init(source: MPOLSource, request: EntityFetchRequest<Vehicle>) {
        super.init(source: source, request: request)
    }
    
    public override func fetchPromise() -> Promise<Vehicle> {
        return MPOLAPIManager.shared.fetchEntityDetails(in: source as! MPOLSource, with: request)
    }
}



public enum FetchState {
    case idle
    case fetching
    case finished
}

public struct FetchResult<T: MPOLKitEntity> {
    public var request: EntityDetailsFetchRequest<T>
    public var entity: T?
    public var state: FetchState = .idle
    public var error: Error?
}

public protocol EntityDetailsFetchDelegate: class {
    
    func entityDetailsFetch<T>(_ entityDetailsFetch: EntityDetailsFetch<T>, didBeginFetch request: EntityDetailsFetchRequest<T>)
    
    func entityDetailsFetch<T>(_ entityDetailsFetch: EntityDetailsFetch<T>, didFinishFetch request: EntityDetailsFetchRequest<T>)
}

public class EntityDetailsFetch<T: MPOLKitEntity>: FetchResultViewModelable {

    public let requests: [EntityDetailsFetchRequest<T>]
    
    public weak var delegate: EntityDetailsFetchDelegate?
    
    public private(set) var results: [FetchResult<T>] = []
    
    public var state: FetchState {
        if results.count == 0 {
            return .idle
        } else if let _ = results.first(where: { $0.state == .fetching }) {
            return .fetching
        } else {
            return .finished
        }
    }
    
    public init(requests: [EntityDetailsFetchRequest<T>]) {
        self.requests = requests
    }
    
    public func performFetch() {
        guard state != .fetching else { return }
        
        for request in requests {
            fetch(for: request)
        }
    }
    
    private func fetch(for request: EntityDetailsFetchRequest<T>) {
        firstly {
            beginFetch(for: request)
            return request.fetch()
            }.then { [weak self] result in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3 ) {

                self?.endFetch(for: request, entity: result)
                }
            }.catch { [weak self] in
                self?.endFetch(for: request, error: $0)
        }
    }
    
    private func beginFetch(for request: EntityDetailsFetchRequest<T>) {
        
        let result = FetchResult(request: request, entity: nil, state: .fetching, error: nil)
        
        if let index = results.index(where: { $0.request === request }) {
            results[index] = result
        } else if let index = requests.index(where: { $0 === request }), index < results.count {
            results.insert(result, at: index)
        } else {
            results.append(result)
        }
        
        delegate?.entityDetailsFetch(self, didBeginFetch: request)
    }
    
    
    private func endFetch(for request: EntityDetailsFetchRequest<T>, entity: T) {
        
        guard let index = results.index(where: { $0.request === request }) else { return }
        
        let result = FetchResult(request: request, entity: entity, state: .finished, error: nil)
        results[index] = result
        
        delegate?.entityDetailsFetch(self, didFinishFetch: request)
    }
    
    private func endFetch(for request: EntityDetailsFetchRequest<T>, error: Error) {
        guard let index = results.index(where: { $0.request === request }) else { return }

        let result = FetchResult(request: request, entity: nil, state: .finished, error: error)
        results[index] = result

        delegate?.entityDetailsFetch(self, didFinishFetch: request)
    }
}

public protocol FetchResultViewModelable {
    
    weak var delegate: EntityDetailsFetchDelegate? { get set }
    func performFetch()
   
}

public protocol EntityDetailsSectionsDelegate: class {
    
    func entityDetailsSectionsDidUpdateResults(_ entityDetailsSectionsViewModel: EntityDetailsSectionsViewModel)
}

public struct EntityFetchResult {
    public var result: MPOLKitEntity?
    public var state: FetchState = .idle
    public var error: Error?
}

public class EntityDetailsSectionsViewModel {
    
    public var sources: [MPOLSource]!
    
    public var entityFetch: FetchResultViewModelable? {
        didSet { entityFetch?.delegate = self }
    }
    
    public var detailsSectionsDataSource: EntityDetailSectionsDataSource?
    
    public weak var delegate: EntityDetailsSectionsDelegate?
    
    public var entity: MPOLKitEntity
    
    public var results: [MPOLSource: EntityFetchResult] = [:]
    
    public init(sources: [MPOLSource]? = [.mpol], entity: MPOLKitEntity) {
        
        self.sources = sources
        self.entity = entity

        initializeDetailsSections()
    }
    
    public func performFetch() {
        entityFetch?.performFetch()
    }
    
    private func initializeDetailsSections() {
        
        /// need to refector somehow
        if entity is Person {
            let requests = sources.map {
                PersonFetchRequest(source: $0, request: EntityFetchRequest<Person>(id: entity.id))
            }
            
            entityFetch = EntityDetailsFetch<Person>(requests: requests)
            detailsSectionsDataSource = PersonDetailsSectionsDataSource()
        }
        else if entity is Vehicle {
            let requests = sources.map {
                VehicleFetchRequest(source: $0, request: EntityFetchRequest<Vehicle>(id: entity.id))
            }
            
            entityFetch = EntityDetailsFetch<Vehicle>(requests: requests)
            detailsSectionsDataSource = VehicleDetailsSectionsDataSource()

        }
    }
    
    public func dataSource(at index: Int) -> MPOLSource {
        return sources[index]
    }
}

extension EntityDetailsSectionsViewModel: EntityDetailsFetchDelegate {
    
    public func entityDetailsFetch<T>(_ entityDetailsFetch: EntityDetailsFetch<T>, didBeginFetch request: EntityDetailsFetchRequest<T>) {
        print("Did begin fetching>>>>")
        
        detailsSectionsDataSource?.detailsViewControllers.forEach {
            $0.loadingManager.state = .loading
        }

//        if let result = entityDetailsFetch.results.first {
//            self.results = [EntityFetchResult(result: result.entity, state: result.state, error: result.error, source: request.source as! MPOLSource)]
//        }
        
        
        
//        entityDetailsFetch.results.map {
//            results[request.source] = EntityFetchResult(result: $0.entity, state: $0.state, error: $0.error)
//        }
        guard let result = entityDetailsFetch.results.first(where: { $0.request === request } ) else {
            return
        }
        
        let source = request.source as! MPOLSource
        
        results[source] = EntityFetchResult(result: result.entity, state: result.state, error: result.error)
        
        self.delegate?.entityDetailsSectionsDidUpdateResults(self)
    }
    
    public func entityDetailsFetch<T>(_ entityDetailsFetch: EntityDetailsFetch<T>, didFinishFetch request: EntityDetailsFetchRequest<T>) {
        print("Did End fetching<<<<<")

///        if let result = entityDetailsFetch.results.first {
            
//                        self.results = [EntityFetchResult(result: nil, state: result.state, error: result.error)]
            
//            self.results = [EntityFetchResult(result: result.entity, state: result.state, error: result.error)]
            
            guard let result = entityDetailsFetch.results.first(where: { $0.request === request } ) else {
                return
            }
            
            let source = request.source as! MPOLSource
            
            results[source] = EntityFetchResult(result: result.entity, state: result.state, error: result.error)
            
//            let rs = EntityFetchResult(result: result.entity, state: result.state, error: result.error)
//            
//            let dict: [MPOLSource : EntityFetchResult] = [request.source as! MPOLSource: rs]
//            print(dict)
            
            print(">>>>SOURCE: \(request.source as! MPOLSource)")
        
        if let error = result.error {
            if source == sources.first! {
                detailsSectionsDataSource?.detailsViewControllers.forEach {
                    $0.entity = nil
                    
                    let noContentView = $0.loadingManager.noContentView
                    noContentView.imageView.image = AssetManager.shared.image(forKey: .refresh)
                    noContentView.imageView.tintColor = #colorLiteral(red: 0.6044161711, green: 0.6313971979, blue: 0.6581829122, alpha: 0.6420554578)
                    
                    noContentView.titleLabel.text = NSLocalizedString(error.localizedDescription, comment: "")
                    let actionButton = noContentView.actionButton
                    actionButton.titleLabel?.font = .systemFont(ofSize: 15.0, weight: UIFontWeightSemibold)
                    actionButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)
                    actionButton.setTitle(NSLocalizedString("Retry Download", comment: ""), for: .normal)
                    actionButton.addTarget(self, action: #selector(newSearchButtonDidSelect(_:)), for: .primaryActionTriggered)
                }
            }
        } else {
            if source == sources.first! {
                detailsSectionsDataSource?.detailsViewControllers.forEach {
                    $0.entity = (result.entity as? Entity)
                }
            }
        }
        
        self.delegate?.entityDetailsSectionsDidUpdateResults(self)
    }
    
    @objc
    private func newSearchButtonDidSelect(_ button: UIButton) {
       // delegate?.searchRecentsControllerDidSelectNewSearch(self)
        self.performFetch()
    }
    
}




////// Entity Sections

public protocol EntityDetailSectionsDataSource {
    var detailsViewControllers: [EntityDetailCollectionViewController] { get }
    
}

public class PersonDetailsSectionsDataSource: EntityDetailSectionsDataSource  {
    
    public var detailsViewControllers: [EntityDetailCollectionViewController] = [ PersonInfoViewController(),
                                                                                  EntityAlertsViewController(),
                                                                                  EntityAssociationsViewController(),
                                                                                  PersonOccurrencesViewController(),
                                                                                  PersonCriminalHistoryViewController()]
}

public class VehicleDetailsSectionsDataSource: EntityDetailSectionsDataSource  {
    
    public var detailsViewControllers: [EntityDetailCollectionViewController] = [ VehicleInfoViewController(),
                                                                                  EntityAlertsViewController(),
                                                                                  EntityAssociationsViewController(),
                                                                                  PersonCriminalHistoryViewController()]
}

