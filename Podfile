platform :ios, '10.0'
use_frameworks!

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
