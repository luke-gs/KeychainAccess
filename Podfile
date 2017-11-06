platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Gridstone/SpecRepo-iOS.git'

workspace 'MPOLKit'
project 'MPOLKit.xcodeproj'

def mpol_kit_dependencies
    pod 'Alamofire', '4.5.1'
    pod 'Unbox', '2.5.0'
    pod 'Wrap', '2.1.1'
    pod 'lottie-ios', '~> 2.1.3'
    pod 'PromiseKit', '~> 4.4.0'
    pod 'PromiseKit/CoreLocation'
	pod 'KeychainSwift', '~> 8.0'
    pod 'Cache', '~> 4.1.2
end

target 'MPOLKit' do
    project 'MPOLKit.xcodeproj'
    mpol_kit_dependencies

    target "MPOLKitTests" do
        inherit! :search_paths
    end
end

