platform :ios, '10.0'
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Gridstone/SpecRepo-iOS.git'

workspace 'MPOLKit'
project 'MPOLKit.xcodeproj'
project 'MPOLKitDemo/MPOLKitDemo.xcodeproj'

def mpol_kit_dependencies
    pod 'Alamofire', '4.4.0'
    pod 'Unbox', '2.5.0'
    pod 'Wrap', '2.1.0'
    pod 'lottie-ios', '1.5.2'
end

target 'MPOLKit' do
    project 'MPOLKit.xcodeproj'
    mpol_kit_dependencies

    target "MPOLKitTests" do
        inherit! :search_paths
    end
end

target 'MPOLKitDemo' do
    project 'MPOLKitDemo/MPOLKitDemo.xcodeproj'
    mpol_kit_dependencies
end
