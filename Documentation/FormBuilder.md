## Form Builder

### Building Forms
TODO

### Utilities

##### Auto Layout Height

The `IntrinsicHeightFormBuilderViewController` form builder subclass can be used to get Auto Layout constraints to position the form collection view, and an intrinsic content size so the VC can be positioned without explicit height in a complex view hierarchy.

##### Submit Dialogs

The `SubmissionFormBuilderViewController` form builder subclass is a convenience class that provides some standard behaviour common to modal dialogs used to submit information to a backend endpoint.

It provides the following:
- Default Cancel/Done buttons
- Default dismiss behaviour
- Default loading state manager text and automatic setting of state
- Simpler handling for layout code when used in PopoverNavigationController
- Title/Subtitle navigation text
- Default promise chains for submitting data that include validation, loading, submit and retry handling

The only method requiring concrete implementation is `performSubmit()` which returns a promise and is used in the default submit chain. Eg
```
open override func performSubmit() -> Promise<Void> {
    return viewModel.submitForm()
}
```

You can customise any of the above behaviours by subclassing methods like `performValidation()` or `performClose(submitted: Bool)`.
