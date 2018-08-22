#
# Be sure to run `pod lib lint DemoAppKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'DemoAppKit'
s.version          = '0.0.1'
s.summary          = 'DemoAppKit is a Public Safety related iOS framework for PSCore demo apps.'

s.description      = <<-DESC
DemoAppKit contains network API, data models and UI related to Gridstone's PSCore demo apps.
DESC

s.homepage         = 'https://github.com/Gridstone/mPolKit-iOS'
s.author           = { 'Trent' => 'trent.fitzgibbon@motorolasolutions.com' }
s.source           = { :git => 'https://github.com/Gridstone/mPolKit-iOS.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'

s.source_files = 'DemoAppKit/DemoAppKit/Classes/**/*'
s.resources = 'DemoAppKit/DemoAppKit/Resources/**/*'

s.dependency 'PatternKit'
s.dependency 'Wrap', '2.1.1'

end
