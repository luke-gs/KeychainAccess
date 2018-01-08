## Plugin Matching Rule

The rule allows conditional application of plugin to the network requests in `APIManager`.

There are 3 types of applicable rules:
- allowAll
- whitelist
- blacklist

`allowAll` will allow plugin to be applicable to all network requests.

`whitelist` and `blacklist` have associated value of `RulesMatching` protocol conformant. `RulesMatching` conformant will be passed a URL and then it has to decide whether it's a match.


`whitelist` will allow plugin to be applicable **_only_** to the one that passes `RulesMatching`.

`blacklist` will allow plugin to be applicable to all **_except_** to the one that passes `RulesMatching`.

The `PluginType` and `PluginFilterRule` is wrapped in a `Plugin` struct to be passed to `APIManager`.

There is a convenience extension to `PluginType` to make wrapping them easier. They are `.allowAll()` and `.withRule(_:)`

Example:

```
let auditPlugin = AuditPlugin()
// Pair them with the rule to be passed to APIManager
let wrapped = auditPlugin.withRule(.allowAll)
```