//
//  SemanticVersion.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

// SemanticVersionComparer is a class that can be used to compare two version numbers
// given that they are provided in a semantic format eg "12.5.9.5", "12.5B"
//
// Simply provide 2 semantic version numbers to the versionsAreSame function, allong with a comparison
// type which is used to determine the accuracy of the comparison

public class SemanticVersion: Comparable {

    public let rawVersion: String

    // major version must be incremented if any non-backwards compatible changes are introduced to the public API. It MAY include minor and patch level changes. Patch and minor version MUST be reset to 0 when major version is incremented.
    public let major: String

    // minor must be incremented if new, backwards compatible functionality is introduced to the public API. It MUST be incremented if any public API functionality is marked as deprecated. It MAY be incremented if substantial new functionality or improvements are introduced within the private code. It MAY include patch level changes. Patch version MUST be reset to 0 when minor version is incremented.
    public let minor: String

    // patch must be incremented if only backwards compatible bug fixes are introduced. A bug fix is defined as an internal change that fixes incorrect behavior.
    public let patch: String

    // pre-release version may be denoted by appending a hyphen and a series of dot separated identifiers immediately following the patch version. Identifiers MUST comprise only ASCII alphanumerics and hyphen [0-9A-Za-z-].
    public let prerelease: String?

    // build metadata may be denoted by appending a plus sign and a series of dot separated identifiers immediately following the patch or pre-release version. Identifiers MUST comprise only ASCII alphanumerics and hyphen [0-9A-Za-z-]. Build metadata SHOULD be ignored when determining version precedence. Thus two versions that differ only in the build metadata, have the same precedence
    public let build: String?

    public init?(_ rawVersion: String) {

        let numberPattern = "0|[1-9][0-9]*"
        let alphaOrNumeric = "[0-9|A-Za-z]+"
        let versionPattern = "(" + numberPattern + ")(\\.(" + numberPattern + "))?(\\.(" + numberPattern + "))?"
        let preReleasePattern = "(-(" + alphaOrNumeric + "))?(\\.(" + alphaOrNumeric + "))?(\\.(" + alphaOrNumeric + "))?"
        let buildPattern = "(\\+([0-9A-Za-z-]+))?"
        let fullPattern = "^" + versionPattern + preReleasePattern + buildPattern + "$"
        let versionRegex = try! NSRegularExpression(pattern: fullPattern, options: [])

        let matches = versionRegex.matches(in: rawVersion, options: [], range: NSMakeRange(0, (rawVersion as NSString).length))

        if matches.count == 0 {
            return nil
        }

        self.rawVersion = rawVersion

        let buildSplitVersion = rawVersion.split(separator: "+")
        if buildSplitVersion.count > 1 {
            build = String(buildSplitVersion[1])
        } else {
            build = nil
        }

        let prereleaseSplitVersion = buildSplitVersion[0].split(separator: "-")
        if prereleaseSplitVersion.count > 1 {
            prerelease = String(prereleaseSplitVersion[1])
        } else {
            prerelease = nil
        }

        let splitVersion = prereleaseSplitVersion[0].split(separator: ".")

        major = String(splitVersion[0])
        minor = splitVersion.count > 1 ? String(splitVersion[1]) : "0"
        patch = splitVersion.count > 2 ? String(splitVersion[2]) : "0"
    }

    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {

        if lhs.major.compare(rhs.major) == .orderedAscending {
            return true
        }
        if lhs.minor.compare(rhs.minor) == .orderedAscending {
            return true
        }
        if lhs.patch.compare(rhs.patch) == .orderedAscending {
            return true
        }

        if lhs.prerelease != nil || rhs.prerelease != nil {
            return prereleaseLessThanComparison(lhs.prerelease ?? "0", rhs.prerelease ?? "0")
        }

        return false
    }

    private static func prereleaseLessThanComparison(_ lhsPrerelease: String, _ rhsPrerelease: String) -> Bool {

        var lhs = lhsPrerelease.split(separator: ".")
        var rhs = rhsPrerelease.split(separator: ".")

        // if the count of elements in each version are not the same
        // append sections to the shorter version
        if lhs.count != rhs.count {
            var shortToLong = [lhs, rhs].sorted {
                return $0.count < $1.count ? true : false
            }

            while shortToLong[0].count != shortToLong[1].count {
                shortToLong[0].append("0")
            }

            lhs = shortToLong[0]
            rhs = shortToLong[1]
        }

        var index = 0
        while index < lhs.count {
            if lhs[index].compare(rhs[index]) == .orderedAscending {
                return true
            }
            index += 1
        }
        return false
    }

    public static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor
               && lhs.patch == rhs.patch && lhs.prerelease == rhs.prerelease
    }
}
