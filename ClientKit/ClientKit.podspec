#
# Be sure to run `pod lib lint ClientKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'ClientKit'
s.version          = '1.0'
s.summary          = 'ClientKit contains functionality specific to a single client, and sits on top of the MPOL framework.'

s.description      = <<-DESC
TODO: Add long description of the pod here.
DESC

s.homepage         = 'https://github.com/Gridstone/mPol-iOS/ClientKit'
s.author           = { 'val@gridstone.com.au' => 'val@gridstone.com.au' }
s.source           = { :git => 'https://github.com/Gridstone/mPol-iOS/ClientKit', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'

s.source_files = 'ClientKit/**/*.swift'
# s.resources = 'Assets/*'

s.dependency 'MPOLKit'

end
