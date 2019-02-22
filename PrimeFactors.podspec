#
# Be sure to run `pod lib lint PrimeFactors.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PrimeFactors'
  s.version          = '0.2.0'
  s.summary          = 'Prime Number detection and Decomposition'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/primetimer/PrimeFactors'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'primetimer' => 'primetimertime@gmail.coom' }
  s.source           = { :git => 'https://github.com/primetimer/PrimeFactors.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

#s.ios.deployment_target = '8.0'
s.platforms = { :ios => "8.0", :osx => "10.7", :watchos => "2.0", :tvos => "9.0" }

  s.dependency 'BigInt'
  #s.source_files = 'PFactors/Classes/*.{swift}'
  s.source_files = 'PrimeFactors/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PrimeFactors' => ['PrimeFactors/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
