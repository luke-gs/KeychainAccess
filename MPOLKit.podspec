#
# Be sure to run `pod lib lint MPOLKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'MPOLKit'
s.version          = '0.3.2'
s.summary          = 'MPOLKit is to be used for all projects that require the MPOL framework.'

s.description      = <<-DESC
TODO: Add long description of the pod here.
DESC

s.homepage         = 'https://github.com/Gridstone/mPolKit-iOS'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'val@gridstone.com.au' => 'val@gridstone.com.au' }
s.source           = { :git => 'https://github.com/Gridstone/mPolKit-iOS.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'

# s.source_files = 'Classes/**/*'
# s.resources = 'Assets/*'

# Export the CommonCrypto module to app using the kit
s.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/CommonCrypto' }
s.preserve_paths = 'CommonCrypto/module.modulemap'
  
s.subspec 'CAD' do |ss|
	ss.source_files = 'Classes/Subspec/CAD/**/*'
end

# s.subspec 'Core' do |ss|
s.source_files = 'Classes/**/*'
s.exclude_files = 'Classes/Subspec/CAD/**/*'
s.resources = 'Assets/*'

s.dependency 'Alamofire', '4.5.1'
s.dependency 'Unbox', '2.5.0'
s.dependency 'Wrap', '2.1.1'
s.dependency 'lottie-ios', '~> 2.1.3'
s.dependency 'PromiseKit', '~> 6.0'
s.dependency 'PromiseKit/CoreLocation'
s.dependency 'KeychainAccess', '~> 3.1.1'
s.dependency 'Cache', '~> 4.1.2'
s.dependency 'Cluster', '2.1.1'
# end

end
