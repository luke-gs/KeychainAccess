# MPOLKit

[![CI Status](http://img.shields.io/travis/val@gridstone.com.au/MPOLKit.svg?style=flat)](https://travis-ci.org/val@gridstone.com.au/MPOLKit)
[![Version](https://img.shields.io/cocoapods/v/MPOLKit.svg?style=flat)](http://cocoapods.org/pods/MPOLKit)
[![License](https://img.shields.io/cocoapods/l/MPOLKit.svg?style=flat)](http://cocoapods.org/pods/MPOLKit)
[![Platform](https://img.shields.io/cocoapods/p/MPOLKit.svg?style=flat)](http://cocoapods.org/pods/MPOLKit)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## [Documentation](Documentation)

  * [PromiseCancellation](Documentation/PromiseCancellation.md)

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
**in: `AssetManager.swift`**

```
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

### Overriding images from other apps
```
  AssetManager.shared.registerImage(named: "myAmazingNewImage", in: Bundle.main, forKey: .myVeryWellDefinedDescription)

```

Images as part of MPOL will be PDF's at a large scale to accommodate for both iOS 11 vector scaling and iOS 10 rescaling of images. If you require an image of a certain size please use the `resizeImageWith` method on the image. This will provide an image of exact size to be used.

### Usage of resizeImageWith:
```
let scaledImage = image.resizeImageWith(newSize: CGSize(width: 24.0, height: 24.0), retainAspect: true, renderMode: .alwaysTemplate)

```
## Manifest

Manifest uses coreData to save and fetch manifestEntries. Fetches are delta oriented, however a full manifest may be pulled down if '0' is passed in the 'interval' parameter. ArchivedManifestEntry should be used when saving the entry to an object to best handle the encoding and decoding.

### Fetching a manifestEntry via id
```
vehicleType = Manifest.shared.entry(withId: id)
```

`ManifestCollection` can be extended to add new collection types for convience for retrieving.
### Usage
```
allVehicleTypes = Manifest.shared.entries(for: .VehicleTypes)
```

Preseeding a manifest item is in most cases a wise decision as it prevents long downloads and saving of a large manifest file. A convenience method to do this is `preseedDatebase(withURL: seedDate:)`, simply pass the location of the preseeded data base, and the time/date it was seeded and it will replace/add the database to the app and will treat it as the main database
### Preseeding manifest
```
// First check if needs to be preseeded
Manifest.shared.preseedDatebase(withURL: databaseURL, seedDate: preseedDate).then {
    // Best to save preseed to userdefaults so it doesn't preseed on every run
}
```

## Data Matching

When viewing an entity's details, there will be rules around how the data is matched between the data sources. There is a convenience object that is used in the `EntityDetailSectionsViewModel` to allow for data matching which should be passed in, in the `init`.

The rules that are defined in the `DataMatchable` structs will be used when fetching the entity details for a data source that isn't the initial selected data source from the Search Results screen.

More info on the the data matcher can be found in `MatchMaker.swift`.

1. Create a bunch of `DataMatchable` structs defining your matching behaviour. **Note:** you might need to create custom fetch requests depending on how the entity details are fetched.

```
struct MPOLToFNCPersonMatch: DataMatchable {
    var initialSource: EntitySource = MPOLSource.mpol
    var resultSource: EntitySource = MPOLSource.fnc

    func match(_ entity: MPOLKitEntity) -> Fetchable {
        let entity = entity as! Person

        let request = PersonFetchRequest(source: resultSource, request: EntityFetchRequest<Person>(id: entity.id))
        return EntityDetailFetch<Person>(request: request)
    }
}

struct FNCToMPOLPersonMatch: DataMatchable {
    var initialSource: EntitySource = MPOLSource.fnc
    var resultSource: EntitySource = MPOLSource.mpol

    func match(_ entity: MPOLKitEntity) -> Fetchable  {
        let entity = entity as! Person

        let request = PersonFetchRequest(source: resultSource, request: EntityFetchRequest<Person>(id: entity.surname))
        return EntityDetailFetch<Person>(request: request)
    }
}
```

2. Subclass the `MatchMaker` class and override the `matches` property, returning **your** matches (you can optionally also override the `findMatch(for:withInitialSource:andDestinationSource:)` for custom match searching behaviour).

```
public class PersonMatchMaker: MatchMaker {
    override public var matches: [DataMatchable]? {
        return [
            MPOLToFNCPersonMatch(),
            FNCToMPOLPersonMatch()
        ]
    }
}
```

3. Pass in **your** `MatchMaker` into `EntityDetailSectionsViewModel`.

```
let viewModel = EntityDetailSectionsViewModel(initialSource: entity.source!,
                                                              dataSources: dataSources,
                                                              andMatchMaker: PersonMatchMaker())

```

4. Intialize the `EntityDetailSplitViewController` wherever necessary with the viewModel as normal

```
EntityDetailSplitViewController<EntityDetailsDisplayable, PersonSummaryDisplayable>(viewModel: viewModel)
```




## Directory Manager

The directory manager attempts to make it easier to archive/unarchive objects.
Also has support for saving/reading form keychain.
Documentation is found in `DirectoryManager.swift`

### Usage:
1. Initialize it with a base URL

```
let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let manager = DirectoryManager(baseURL: url)
```

2. Directories

```
// To write:
directoryManager.write(someObject, to: "someSubDirectory")

//To write to complex directories (it will create any intermediate directories for you):
directoryManager.write(someObject, to: "someSubDirectory/someChildDirectory/someSubChildDirectory")

// To read (sadly still have to cast to your object at this stage):
let someObject = directoryManager.read(from: "someSubDirectory") as? SomeObject
```

3. Keychain

```

//To write:
directoryManager.write(token, toKeyChain: "token")

//To read:
let token = directoryManager.read(fromKeyChain: "token") as! OAuthAccessToken

```

## Generic Entity Search

The `GenericSearchViewController` allows for searching through entities with "type-ahead" functionality.

<img src="/ReadmeAssets/GenericSearch.png" alt="Generic Search" width="400" height="600">

1. Implement the `GenericSearchable` protocol on the entities that you want to search through.


```
struct Person: GenericSearchable {
    var title: String = "James"
    var subtitle: String? = "Neverdie"
    var section: String? = "Alive"
    var image: UIImage? = UIImage(named: "SidebarAlert")!

    func matches(searchString: String) -> Bool {
        return title.starts(with: searchString)
    }
}
```

2. Create a custom `GenericSearchViewModel` object, or just use the default implementation.


```
        // MARK: Generic Search VC
        let people: [GenericSearchable] = Array(repeating: Person(), count: 10)

        var searchVM = GenericSearchDefaultViewModel(items: people)
        searchVM.title = "Search People"
        searchVM.collapsableSections = true
        searchVM.hasSections = true
        searchVM.hidesSections = false
        searchVM.sectionPriority = ["Deceased", "Alive"]
```

3. Intialise the `GenericSearchViewController` with your viewModel and present however. Don't forgot to set the `GenericSearchDelegate` delegate of the `GenericSearchViewController` if you need to handle row selections.


```
        let viewController = GenericSearchViewController(viewModel: searchVM)
        viewController.delegate = self
        let navController = PopoverNavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        
        self.present(nc, animated: true)
```



## Author

val@gridstone.com.au, val@gridstone.com.au

## License

MPOLKit is available under the MIT license. See the LICENSE file for more info.
