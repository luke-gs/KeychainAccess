#
# Be sure to run `pod lib lint MPOLKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'CoreKitAppExtension'
s.version          = '0.0.1'
s.summary          = 'CoreKitAppExtension is a subset of CoreKit for use in application extensions.'

s.description      = <<-DESC
CoreKitAppExtension contains useful utilities that can be used by any Gridstone application extension.
DESC

s.homepage         = 'https://github.com/Gridstone/mPolKit-iOS'
s.author           = { 'Trent' => 'trent.fitzgibbon@motorolasolutions.com' }
s.source           = { :git => 'https://github.com/Gridstone/mPolKit-iOS.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'

s.source_files = 'CoreKit/CoreKit/Classes/App Group/**/*', 'CoreKit/CoreKit/Classes/Crypto/**/*'

s.dependency 'KeychainAccess', '~> 3.1.1'

# Export the CommonCrypto module to app using the kit
s.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/CoreKit/CommonCrypto' }
s.preserve_paths = 'CoreKit/CommonCrypto/module.modulemap'
  
end
