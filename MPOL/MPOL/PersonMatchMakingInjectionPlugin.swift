//
//  PersonMatchMakingInjectionPlugin.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import Alamofire
import PromiseKit
import ClientKit

struct PersonMatchMakingInjectionPlugin: PluginType {

    func processResponse(_ response: Alamofire.DataResponse<Data>) -> Promise<Alamofire.DataResponse<Data>> {

        let processedResponse: DataResponse<Data>
        let result = APIManager.JSONObjectResponseSerializer().serializedResponse(from: response)
        // If it's successful, mutate the response, otherwise leave it as is.
        if var value = result.value {
            value["externalIdentifiers"] = [
                MPOLSource.pscore.rawValue: "2ff46c89-6388-435b-8bcf-df16e0785127",
                MPOLSource.nat.rawValue: "2ff46c89-6388-435b-8bcf-df16e0785127",
                MPOLSource.rda.rawValue: "2ff46c89-6388-435b-8bcf-df16e0785127",
            ]

            let modifiedData = try! JSONSerialization.data(withJSONObject: value, options: [])
            let result = Result.success(modifiedData)
            processedResponse = DataResponse(request: response.request, response: response.response, data: modifiedData, result: result, timeline: response.timeline)
        } else {
            processedResponse = response
        }

        return Promise.value(processedResponse)
    }

    static var defaultPersonMatchMakingInjectionPlugin: Plugin {
        let pattern = PatternsMatchRules(patterns: ["https://*/person/2ff46c89-6388-435b-8bcf-df16e0785127"])
        return PersonMatchMakingInjectionPlugin().withRule(.whitelist(pattern))
    }
}
