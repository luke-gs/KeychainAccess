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
    
    pod 'CoreKit', :path => '.'
    pod 'SketchKit', :path => '.'
    pod 'PatternKit', :path => '.'
    pod 'PublicSafetyKit', :path => '.'
end

target 'MPOLKit' do
    project 'MPOLKit.xcodeproj'
    mpol_kit_dependencies
end

