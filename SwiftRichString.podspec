Pod::Spec.new do |s|
  s.name         = "SwiftRichString"
  s.version      = "0.9.9"
  s.summary      = "Elegant Attributed Strings (NSAttributedString) in Swift"
  s.homepage     = "https://github.com/malcommac/SwiftRichString"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniele Margutti" => "me@danielemargutti.com" }
  s.social_media_url   = "http://twitter.com/danielemargutti"
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/malcommac/SwiftRichString.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*.swift"
  s.frameworks  = "Foundation"
  s.requires_arc = true
  s.module_name = 'SwiftRichString'
end
