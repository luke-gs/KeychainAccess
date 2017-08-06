# MPOLKit

[![CI Status](http://img.shields.io/travis/val@gridstone.com.au/MPOLKit.svg?style=flat)](https://travis-ci.org/val@gridstone.com.au/MPOLKit)
[![Version](https://img.shields.io/cocoapods/v/MPOLKit.svg?style=flat)](http://cocoapods.org/pods/MPOLKit)
[![License](https://img.shields.io/cocoapods/l/MPOLKit.svg?style=flat)](http://cocoapods.org/pods/MPOLKit)
[![Platform](https://img.shields.io/cocoapods/p/MPOLKit.svg?style=flat)](http://cocoapods.org/pods/MPOLKit)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MPOLKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MPOLKit"
```

## Asset Manager

The asset manager allows you to access the assets within different bundles
within MPOLKit. You can also register overrides for MPOL standard assets,
or add additional items to be managed.

By default, if you ask for MPOL standard items, MPOL will first check if any
custom items have been registered, and use them if it can find it. If no
custom item has been registered, or no asset has been found, it will use MPOL
default assets.

### Registering new images
```
in: AssetManager.swift
extension AssetManager {
  ...
  
  // My new section/screen
  public static let myVeryWellDefinedDescription = ImageKey("MyNewImage")
  
  ...
}
```

### Usage:
```
  if let image = AssetManager.shared.image(forKey: .myVeryWellDefinedDescription) {
    // use image
  }
```

## Overriding images from other apps
```
  AssetManager.shared.registerImage(named: "myAmazingNewImage", in: Bundle.main, forKey: .myVeryWellDefinedDescription)

```


## Author

val@gridstone.com.au, val@gridstone.com.au

## License

MPOLKit is available under the MIT license. See the LICENSE file for more info.
