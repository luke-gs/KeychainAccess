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
CoreKit contains useful utilities that are inline with Gridstone current projected road maps.
DESC

s.homepage         = 'https://github.com/Gridstone/mPolKit-iOS'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Herli' => 'cwmx78@motorolasolutions.com' }
s.source           = { :git => 'https://github.com/Gridstone/mPolKit-iOS.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'

s.source_files = 'Source/**/*'
s.resources = 'Assets/*'

s.dependency 'Alamofire', '4.5.1'
s.dependency 'Unbox', '2.5.0'
s.dependency 'Wrap', '2.1.1'
s.dependency 'PromiseKit', '~> 6.0'
s.dependency 'PromiseKit/CoreLocation'
s.dependency 'KeychainAccess', '~> 3.1.1'
s.dependency 'Cache', '~> 4.1.2'

end
