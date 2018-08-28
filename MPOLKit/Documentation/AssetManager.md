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