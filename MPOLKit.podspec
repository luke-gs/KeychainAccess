#
# Be sure to run `pod lib lint MPOLKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'MPOLKit'
s.version          = '0.1.0'
s.summary          = 'MPOLKit is to be used for all projects that require the MPOL framework. Also includs FormKit'

s.description      = <<-DESC
TODO: Add long description of the pod here.
DESC

s.homepage         = 'https://github.com/Gridstone/mPolKit-iOS'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'val@gridstone.com.au' => 'val@gridstone.com.au' }
s.source           = { :git => 'https://github.com/Gridstone/mPolKit-iOS.git', :tag => s.version.to_s }

s.ios.deployment_target = '9.0'

s.default_subspec = "Core"

s.subspec "Core" do |core|
core.source_files = 'MPOLKit/Classes/**/*'
s.resources = ['MPOLKit/Assets/MPOL/**/*', 'MPOLKit/Assets/FormKit/*']
end

s.subspec 'FormKit' do |formkit|
formkit.source_files = 'MPOLKit/Classes/FormKit/**/*'
formkit.resources = 'MPOLKit/Assets/FormKit/*'
end

# s.public_header_files = 'Pod/Classes/**/*.h'
# s.frameworks = 'UIKit', 'MapKit'
# s.dependency 'AFNetworking', '~> 2.3'
end
