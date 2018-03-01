## User Storage


User Storage is a layer on top of Directory Manager and FileManager stuff. It is intended to be a simply way to store and retrieve objects by key that are relevant to a particular user, for example recent searches.

Separate instances of UserStorage initialised with the same userID will have access to the same stored files.

Files can be saved with `add(object: Any, key: String, flag: UserStorageFlag)`

`UserStorageFlag` is an enum. When desired, all stored objects with a specified flag can be deleted.

For example: `UserStorage(userID: "abcd").purge(flag: .session)`

`UserStorageFlag` has the `.custom(String)` case to add flags on demand.


# FileSystem Fun
`UserStorage` converts all flags and keys to "Storage safe" strings. That is, no forward slashes or capital letters.  
This is because some FileSystems accept `Scifi` and `scifi` as two separate files, others will throw an error. This was problematic when running unit tests across different developer machines. It could be a problem on iOS too, so this is to be safe.