#
# Be sure to run `pod lib lint PatternKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'PatternKit'
s.version          = '0.0.1'
s.summary          = 'PatternKit is a Gridstone general purpose UI framework.'

s.description      = <<-DESC
PatternKit contains UI design patterns that can be used by any Gridstone application.
DESC

s.homepage         = 'https://github.com/Gridstone/mPolKit-iOS'
s.author           = { 'Trent' => 'trent.fitzgibbon@motorolasolutions.com' }
s.source           = { :git => 'https://github.com/Gridstone/mPolKit-iOS.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'

s.source_files = 'PatternKit/Classes/**/*'
s.resources = 'Assets/**/*'

s.dependency 'CoreKit'

end
