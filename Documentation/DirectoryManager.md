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
