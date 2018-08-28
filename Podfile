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
    pod 'lottie-ios', '2.1.3'
    pod 'PromiseKit', '~> 6.0'
    pod 'PromiseKit/CoreLocation', '~> 6.0'
	pod 'KeychainAccess', '~> 3.1.1'
    pod 'Cache', '~> 4.1.2'
    pod 'Cluster', '2.1.1'
end

target 'CoreKit' do
    project 'CoreKit/CoreKit.xcodeproj'
    mpol_kit_dependencies

    target 'CoreKitTests' do
        inherit! :search_paths
    end
end

target 'PatternKit' do
    project 'PatternKit/PatternKit.xcodeproj'
    mpol_kit_dependencies
    pod 'CoreKit', :path => '.'
    pod 'SketchKit', :path => '.'

    target 'PatternKitTests' do
        inherit! :search_paths
    end
end

target 'SketchKit' do
    project 'SketchKit/SketchKit.xcodeproj'
    mpol_kit_dependencies
    pod 'CoreKit', :path => '.'

    target 'SketchKitTests' do
        inherit! :search_paths
    end
end

target 'PublicSafetyKit' do
    project 'PublicSafetyKit/PublicSafetyKit.xcodeproj'
    mpol_kit_dependencies
    pod 'PatternKit', :path => '.'

    target 'PublicSafetyKitTests' do
        inherit! :search_paths
    end
end

target 'DemoAppKit' do
    project 'DemoAppKit/DemoAppKit.xcodeproj'
    mpol_kit_dependencies
    pod 'PublicSafetyKit', :path => '.'

    target 'DemoAppKitTests' do
        inherit! :search_paths
    end
end

target 'MPOLKit' do
    project 'MPOLKit.xcodeproj'
    mpol_kit_dependencies

    target "MPOLKitTests" do
        inherit! :search_paths
    end
end

