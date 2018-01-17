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
