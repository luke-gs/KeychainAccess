//
//  PluginTests.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 11/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class PluginTests: XCTestCase {

    let candidates = [URL(string: "random")!, URL(string: "string")!, URL(string: "goes")!, URL(string: "here")!]

    func testThatItMatchesAllowAllRule() {

        // Given
        let plugin = Plugin(AuditPlugin(), rule: .allowAll)

        // When
        // Doesn't matter what the value of `to` is, should match.
        let result = plugin.isApplicable(to: URL(string: "fun")!)

        // Then
        XCTAssertTrue(result)

    }

    func testThatItMatchesWhitelistRule() {

        // Given
        let stringMatchingRule = URLRulesMatch { $0.absoluteString == "fun" }
        let plugin = Plugin(AuditPlugin(), rule: .whitelist(stringMatchingRule))

        // When
        let result = plugin.isApplicable(to: URL(string: "fun")!)

        // Then
        XCTAssertTrue(result)
    }

    func testThatItFiltersWhitelistRuleWhenItDoesNotMatch() {

        // Given
        let stringMatchingRule = URLRulesMatch { $0.absoluteString == "fun" }
        let plugin = Plugin(AuditPlugin(), rule: .whitelist(stringMatchingRule))

        candidates.forEach {
            // When
            let result = plugin.isApplicable(to: $0)

            // Then
            // Anything that isn't whitelisted should not be applicable.
            XCTAssertFalse(result)
        }

    }

    func testThatItFiltersBlacklistRuleWhenMatches() {

        // Given
        let stringMatchingRule = URLRulesMatch { $0.absoluteString == "fun" }
        let plugin = Plugin(AuditPlugin(), rule: .blacklist(stringMatchingRule))

        // When
        let result = plugin.isApplicable(to: URL(string: "fun")!)

        // Then
        XCTAssertFalse(result)
    }

    func testThatItAllowsBlacklistRuleWhenItDoesNotMatch() {

        // Given
        let stringMatchingRule = URLRulesMatch { $0.absoluteString == "fun" }
        let plugin = Plugin(AuditPlugin(), rule: .blacklist(stringMatchingRule))

        candidates.forEach {
            // When
            let result = plugin.isApplicable(to: $0)

            // Then
            // Anything that isn't blacklisted should be applicable.
            XCTAssertTrue(result)
        }

    }

    func testThatPluginAllowAllCreationIsCorrect() {

        // Given
        let plugin = AuditPlugin()

        // When
        let result = plugin.allowAll()

        // Then
        switch result.rule {
        case .allowAll:
            XCTAssertTrue(true)
        default:
            XCTFail("Rule doesn't match")
        }
    }

    func testThatPluginCreationWithPassedInRuleIsCorrect() {

        // Given
        let plugin = AuditPlugin()
        let stringMatchingRule = URLRulesMatch { $0.absoluteString == "fun" }

        // When
        let result = plugin.withRule(.blacklist(stringMatchingRule))

        // Then
        switch result.rule {
        case .blacklist(_):
            XCTAssertTrue(true)
        default:
            XCTFail("Rule doesn't match")
        }

    }

}
