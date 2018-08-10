//
//  FancyEntityDatasourceViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public protocol FancyEntityDetailsDatasourceViewModelDelegate: class {
    func fancyEntityDetailsDatasourceViewModelDidBeginFetch(_ viewModel: FancyEntityDetailsDatasourceViewModel)
    func fancyEntityDetailsDatasourceViewModel(_ viewmodel: FancyEntityDetailsDatasourceViewModel, didEndFetchWith state: FancyEntityDetailsDatasourceViewModel.State)
}

public protocol EntityRetrieveStrategy {
    func retrieveUsingReferenceEntity(_ entity: MPOLKitEntity) -> Promise<[EntityState]>?
}

public enum EntityState {
    case summary(MPOLKitEntity)
    case detail(MPOLKitEntity)
}

public protocol FancyEntityDetailsDataSource {
    var viewControllers: [UIViewController] { get set }
    var source: EntitySource { get }
}

open class FancyEntityDetailsDatasourceViewModel {

    public enum State {
        case empty
        case loading
        case result([EntityState])
        case error(Error)
    }

    public var datasource: FancyEntityDetailsDataSource
    public weak var delegate: FancyEntityDetailsDatasourceViewModelDelegate?

    private(set) var state: State = .empty
    private let strategy: EntityRetrieveStrategy

    public init(datasource: FancyEntityDetailsDataSource, strategy: EntityRetrieveStrategy) {
        self.datasource = datasource
        self.strategy = strategy
    }

    public func retrieve(for entity: MPOLKitEntity) {
        state = .loading
        delegate?.fancyEntityDetailsDatasourceViewModelDidBeginFetch(self)

        strategy.retrieveUsingReferenceEntity(entity)?
            .done { [weak self] states in
                guard let `self` = self else { return }
                self.state = .result(states)
                self.delegate?.fancyEntityDetailsDatasourceViewModel(self, didEndFetchWith: .result(states))
            }.catch { [weak self] error in
                guard let `self` = self else { return }
                self.state = .error(error)
                self.delegate?.fancyEntityDetailsDatasourceViewModel(self, didEndFetchWith: .error(error))
        }
    }
}


