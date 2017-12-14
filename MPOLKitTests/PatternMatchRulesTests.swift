//
//  PatternMatchRulesTests.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 14/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import MPOLKit

class PatternMatchRulesTests: XCTestCase {

    func test() {
        let pattern = "http://*/foo*"
        let matcher = PatternMatchRules(pattern: pattern)
        let matchTestURLs = urls(from: ["http://www.google.com/foo", "http://example.com/foo/bar.html"])

        for testURL in matchTestURLs {
            XCTAssertTrue(matcher.isMatch(testURL))
        }
    }

    func test2() {
        let pattern = "https://*.google.com/foo*bar"
        let matcher = PatternMatchRules(pattern: pattern)
        let matchTestURLs = urls(from: ["https://www.google.com/foo/baz/bar", "https://docs.google.com/foobar"])

        for testURL in matchTestURLs {
            XCTAssertTrue(matcher.isMatch(testURL))
        }
    }

    func test3() {
        let pattern = "http://*/*"
        let matcher = PatternMatchRules(pattern: pattern)
        let matchTestURLs = urls(from: ["http://www.google.com/", "http://example.org/foo/bar.html"])

        for testURL in matchTestURLs {
            XCTAssertTrue(matcher.isMatch(testURL))
        }
    }

    func test4() {
        let pattern = "*://mail.google.com/*"
        let matcher = PatternMatchRules(pattern: pattern)
        let matchTestURLs = urls(from: ["http://mail.google.com/foo/baz/bar", "https://mail.google.com/foobar"])

        for testURL in matchTestURLs {
            XCTAssertTrue(matcher.isMatch(testURL))
        }
    }

    func test5() {
        let pattern = "http://example.org/foo/bar.html"
        let matcher = PatternMatchRules(pattern: pattern)
        let matchTestURLs = urls(from: ["http://example.org/foo/bar.html"])

        for testURL in matchTestURLs {
            XCTAssertTrue(matcher.isMatch(testURL))
        }

        let failURL = URL(string: "http://example.org/foo/bar.aspx")!
        XCTAssertFalse(matcher.isMatch(failURL))
    }


    // Aggregate the above.
    func testPatternsMatchRules() {
        let patterns = ["http://*/foo*", "https://*.google.com/foo*bar", "*://mail.google.com/*", "http://example.org/foo/bar.html"]
        let matcher = PatternsMatchRules(patterns: patterns)

        let matchTestURLs = urls(from: ["http://www.google.com/foo", "http://example.com/foo/bar.html", "http://mail.google.com/foo/baz/bar", "https://mail.google.com/foobar", "http://example.org/foo/bar.html"])

        for testURL in matchTestURLs {
            XCTAssertTrue(matcher.isMatch(testURL))
        }

        let failURL = URL(string: "http://example.org/test/bar.aspx")!
        XCTAssertFalse(matcher.isMatch(failURL))

    }

    func urls(from strings: [String]) -> [URL] {
        return strings.map {
            return URL(string: $0)!
        }
    }
    
}
