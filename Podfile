platform :ios, '10.0'
use_frameworks!

workspace 'MPOL.xcworkspace'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Gridstone/SpecRepo-iOS.git'

target 'ClientKit' do
    project 'ClientKit/ClientKit.xcodeproj'
    
    #pod 'MPOLKit', :git=> 'https://github.com/Gridstone/mPolKit-iOS'
    pod 'MPOLKit', :path => '../mPolKit-iOS'
    
    target 'MPOL' do
        project 'MPOL.xcodeproj'
    end
end
