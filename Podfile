platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Gridstone/SpecRepo-iOS.git'

workspace 'MPOLKit'
project 'MPOLKit.xcodeproj'

def mpol_kit_dependencies
    pod 'Alamofire', '4.4.0'
    pod 'Unbox', '2.5.0'
    pod 'Wrap', '2.1.0'
    pod 'lottie-ios', '~> 2.0.2'
    pod 'PromiseKit', '4.3.1'    
end

target 'MPOLKit' do
    project 'MPOLKit.xcodeproj'
    mpol_kit_dependencies

    target "MPOLKitTests" do
        inherit! :search_paths
    end
end

