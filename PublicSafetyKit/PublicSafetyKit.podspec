#
# Be sure to run `pod lib lint PublicSafetyKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'PublicSafetyKit'
s.version          = '0.0.1'
s.summary          = 'PublicSafetyKit is a Public Safety related iOS framework.'

s.description      = <<-DESC
PublicSafetyKit contains network API, data models and UI related to Gridstone's PSCore architecture.
DESC

s.homepage         = 'https://github.com/Gridstone/mPolKit-iOS'
s.author           = { 'Trent' => 'trent.fitzgibbon@motorolasolutions.com' }
s.source           = { :git => 'https://github.com/Gridstone/mPolKit-iOS.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'

s.source_files = 'PublicSafetyKit/Classes/**/*'
s.resources = 'PublicSafetyKit/Resources/**/*'

s.dependency 'PatternKit'
s.dependency 'Wrap', '2.1.1'

end
