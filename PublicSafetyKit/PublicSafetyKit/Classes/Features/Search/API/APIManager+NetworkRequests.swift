//
//  APIManager+NetworkRequests.swift
//
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

extension APIManager {
    // MARK: - Requests

    /// Request for access token.
    ///
    /// Supports implicit `NSProgress` reporting.
    /// - Parameter grant: The grant type and required field for it.
    /// - Returns: A promise for access token.
    public func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> Promise<OAuthAccessToken> {

        let path = grant.path
        let parameters = grant.parameters

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters, method: .post)

        return try! performRequest(networkRequest)

    }

    /// performs a network request to revoke a refresh token
    /// typically done on logoff
    ///
    /// - Parameter token: token to be revoked
    /// - Parameter path: defaults to "logoff" but can be changed
    /// - Returns: A promise with the request
    public func revokeRefreshToken(_ token: String, at path: String = "logoff") -> Promise<(Data, HTTPURLResponse?)> {
        let parameters =  ["refreshToken": token]
        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters, method: .post)

        return try! performRequest(networkRequest)
    }

    /// Search for entity using specified request.
    ///
    /// Supports implicit `NSProgress` reporting.
    /// - Parameters:
    ///   - source: The data source of the entity to be searched.
    ///   - request: The request with the parameters to search the entity.
    /// - Returns: A promise to return search result of specified entity.
    public func searchEntity<SearchRequest: EntitySearchRequestable>(in source: EntitySource, with request: SearchRequest, withCancellationToken token: PromiseCancellationToken? = nil) -> Promise<SearchResult<SearchRequest.ResultClass>> {

        let path = "{source}/entity/{entityType}/search"
        var parameters = request.parameters
        parameters["source"] = source.serverSourceName
        parameters["entityType"] = SearchRequest.ResultClass.serverTypeRepresentation

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)

        return try! self.performRequest(networkRequest, withCancellationToken: token)
    }

    /// Fetch entity details using specified request.
    ///
    /// Supports implicit `NSProgress` reporting.
    /// - Parameters:
    ///   - source: The data source of entity to be fetched.
    ///   - request: The request with the parameters to fetch the entity.
    /// - Returns: A promise to return specified entity details.
    public func fetchEntityDetails<FetchRequest: Requestable>(in source: EntitySource, with request: FetchRequest, withCancellationToken token: PromiseCancellationToken? = nil) -> Promise<FetchRequest.ResultClass> {

        let path = "{source}/entity/{entityType}/{id}"

        var parameters = request.parameters
        parameters["source"] = source.serverSourceName
        parameters["entityType"] = FetchRequest.ResultClass.serverTypeRepresentation

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)

        return try! self.performRequest(networkRequest, withCancellationToken: token)
    }

    public func submitEvent<FetchRequest: Requestable>(in source: EntitySource, with request: FetchRequest, withCancellationToken token: PromiseCancellationToken? = nil) -> Promise<FetchRequest.ResultClass> {

        let path = "{source}/entity/{entityType}"

        var parameters = request.parameters
        parameters["source"] = source.serverSourceName
        parameters["entityType"] = FetchRequest.ResultClass.serverTypeRepresentation

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters, method: .post)

        return try! self.performRequest(networkRequest, withCancellationToken: token)
    }

    /// Fetch officer details for the current officer
    ///
    /// Supports implicit `NSProgress` reporting.
    /// - Parameters:
    ///   - source: The data source of officer to be fetched.
    ///   - request: The request with the parameters to fetch the officer.
    /// - Returns: A promise to return specified officer details.
    public func fetchCurrentOfficerDetails<FetchRequest: Requestable>(in source: EntitySource, with request: FetchRequest, withCancellationToken token: PromiseCancellationToken? = nil) -> Promise<FetchRequest.ResultClass> {

        let path = "{source}/entity/{entityType}/current"

        var parameters = request.parameters
        parameters["source"] = source.serverSourceName
        parameters["entityType"] = FetchRequest.ResultClass.serverTypeRepresentation

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)

        return try! self.performRequest(networkRequest, withCancellationToken: token)
    }
}
