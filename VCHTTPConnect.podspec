#
# Be sure to run `pod lib lint VCHTTPConnect.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VCHTTPConnect'
  s.version          = '0.0.23'
  s.summary          = 'Awesome and simple way to make HTTP connections on iOS using Swift 3.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is wrapper around the awesome SwiftHTTP library. The intention here is to be as simple as possible when making HTTP connections.
                       DESC

  s.homepage         = 'https://github.com/ripventura/VCHTTPConnect'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ripventura' => 'vitorcesco@gmail.com' }
  s.source           = { :git => 'https://github.com/ripventura/VCHTTPConnect.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'VCHTTPConnect/Classes/**/*'
  
  # s.resource_bundles = {
  #   'VCHTTPConnect' => ['VCHTTPConnect/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
s.dependency 'Alamofire', '4.4'
s.dependency 'ObjectMapper', '2.2'
s.dependency 'VCSwiftToolkit'
end
