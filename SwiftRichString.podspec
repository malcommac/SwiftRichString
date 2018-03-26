Pod::Spec.new do |s|
  s.name         = "SwiftRichString"
  s.version      = "2.0.0"
  s.summary      = "Elegant Strings & Attributed Strings Toolkit for Swift"
  s.description  = <<-DESC
    SwiftRichString is the best toolkit to work easily with Strings and Attributed Strings.
  DESC
  s.homepage     = "git@github.com:malcommac/SwiftRichString.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniele Margutti" => "me@danielemargutti.com" }
  s.social_media_url   = "http://twitter.com/danielemargutti"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "git@github.com:malcommac/SwiftRichString.git.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
