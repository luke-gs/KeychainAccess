#
# Be sure to run `pod lib lint MPOLKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'MPOLKitCrypto'
s.version          = '0.0.1'
s.summary          = 'Crypto component of MPOLKit to be shared with app extensions.'

s.description      = <<-DESC
TODO: Add long description of the pod here.
DESC

s.homepage         = 'https://github.com/Gridstone/mPolKit-iOS'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'trentf@gridstone.com.au' => 'trentf@gridstone.com.au' }
s.source           = { :git => 'https://github.com/Gridstone/mPolKit-iOS.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'

# Export the CommonCrypto module to app using the kit
s.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/CommonCrypto' }
s.preserve_paths = 'CommonCrypto/module.modulemap'
  
s.source_files = 'Classes/Subspec/Crypto/**/*'

end
