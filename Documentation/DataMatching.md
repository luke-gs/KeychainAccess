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


