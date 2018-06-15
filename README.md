# mPol-iOS

## Hyperion

> Hyperion is a hidden plugin drawer that can easily be integrated into any app. The drawer sits discreetly 🙊 under the app so that it is there when you need it and out of the way when you don't. Hyperion plugins are designed to make inspection of your app quick and simple.

### Usage of Hyperion

Shake the device to activate

### Integrate your mPolKit PR in your mPol PR build check:

Larry uses our lovely [Pod Brancher](https://github.com/Gridstone/Pod-Brancher) to sneakily change the branch in the Podfile if you specify it in the body of your PR. 

To use it, add `{kit-branch='MyBranch'}` anywhere in the description of your PR, replacing `MyBranch` with the branch your Kit PR is from.

### Podfile Changes

Whenever changing the Podfile of Search or CAD app, please also update the matching Podfile.larry file which is used by Larry to do a build. Larry needs a custom version so the mpolkit pod is pulled from github rather than using a local development pod. See above for customising which branch of mpolkit he pulls.

These Podfile.larry files were added to prevent having to manually copy any updated Podfiles to Larry itself after merging a PR with a Podfile change.
