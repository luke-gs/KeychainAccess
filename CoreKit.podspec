#
# Be sure to run `pod lib lint CoreKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'CoreKit'
s.version          = '0.0.1'
s.summary          = 'CoreKit is a Gridstone general purpose framework.'

s.description      = <<-DESC
CoreKit contains useful utilities and SDK extensions that can be used by any Gridstone application.
DESC

s.homepage         = 'https://github.com/Gridstone/mPolKit-iOS'
s.author           = { 'Trent' => 'trent.fitzgibbon@motorolasolutions.com' }
s.source           = { :git => 'https://github.com/Gridstone/mPolKit-iOS.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'

s.source_files = 'CoreKit/CoreKit/Classes/**/*'
s.resources = 'CoreKit/CoreKit/Resources/**/*'

s.dependency 'Alamofire', '4.5.1'
s.dependency 'Unbox', '2.5.0'
s.dependency 'PromiseKit', '~> 6.0'
s.dependency 'PromiseKit/CoreLocation'
s.dependency 'KeychainAccess', '~> 3.1.1'
s.dependency 'Cache', '~> 4.1.2'

# Export the CommonCrypto module to app using the kit
s.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/CoreKit/CommonCrypto' }
s.preserve_paths = 'CoreKit/CommonCrypto/module.modulemap'  

end
