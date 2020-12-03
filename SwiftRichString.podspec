Pod::Spec.new do |s|
  s.name         = "SwiftRichString"
  s.version      = "4.0.0-alpha-5"
  s.summary      = "Elegant Attributed String composition in Swift sauce"
  s.description  = <<-DESC
    SwiftRichString is the best toolkit to work easily with Strings and Attributed Strings.
  DESC
  s.homepage     = "https://github.com/malcommac/SwiftRichString"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniele Margutti" => "hello@danielemargutti.com" }
  s.social_media_url   = "https://twitter.com/danielemargutti"
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.11"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.2"
  s.source       = { :git => "https://github.com/malcommac/SwiftRichString.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.ios.public_header_files =  'Sources/**/*.h'
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2',
    'OTHER_LDFLAGS' => '-lxml2'
  }
  s.frameworks  = "Foundation"
  s.swift_versions = ['5.0', '5.1', '5.3']
end
