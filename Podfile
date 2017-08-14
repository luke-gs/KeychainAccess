platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Gridstone/SpecRepo-iOS.git'

workspace 'MPOL'
project 'MPOL.xcodeproj'
project 'ClientKit/ClientKit.xcodeproj'

def mpol_kit
    pod 'MPOLKit', :git=> 'https://github.com/Gridstone/mPolKit-iOS'
#pod 'MPOLKit', :path => '../mPolKit-iOS'
end

target 'ClientKit' do
    project 'ClientKit/ClientKit.xcodeproj'
    mpol_kit
    
    target 'ClientKitTests' do
        inherit! :search_paths
    end
end

target 'MPOL' do
    project 'MPOL.xcodeproj'
    mpol_kit
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
