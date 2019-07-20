Pod::Spec.new do |s|
  s.name         = "SwiftRichString"
  s.version      = "3.0.1"
  s.summary      = "Elegant Strings & Attributed Strings Toolkit for Swift"
  s.description  = <<-DESC
    SwiftRichString is the best toolkit to work easily with Strings and Attributed Strings.
  DESC
  s.homepage     = "https://github.com/malcommac/SwiftRichString"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniele Margutti" => "hello@danielemargutti.com" }
  s.social_media_url   = "https://twitter.com/danielemargutti"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/malcommac/SwiftRichString.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
  s.swift_version = "5.0"
end
