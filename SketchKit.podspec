#
# Be sure to run `pod lib lint SketchKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'SketchKit'
s.version          = '0.0.1'
s.summary          = 'SketchKit is a drawing framework.'

s.description      = <<-DESC
SketchKit contains useful utilities for sketching with touch on a canvas.
DESC

s.homepage         = 'https://github.com/Gridstone/mPolKit-iOS'
s.author           = { 'Trent' => 'trent.fitzgibbon@motorolasolutions.com' }
s.source           = { :git => 'https://github.com/Gridstone/mPolKit-iOS.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'

s.source_files = 'SketchKit/SketchKit/Classes/**/*'
s.resources = 'SketchKit/SketchKit/Resources/**/*'

s.dependency 'CoreKit'

end
