Pod::Spec.new do |s|
  s.name         = "SwiftRichString"
  s.version      = "3.7.2"
  s.summary      = "Elegant Strings & Attributed Strings Toolkit for Swift"
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
  #ås.source_files  = "Sources/SwiftRichString/**/*.swift"
  s.frameworks  = "Foundation"
  s.swift_versions = ['5.0', '5.1', '5.3']

  #s.dependency 'SwiftRichString/CHTMLSAXParser'

  s.subspec 'CHTMLSAXParser' do |ss|
    ss.source_files = 'Sources/CHTMLSAXParser/**/*.swift'
    ss.ios.deployment_target = '9.0'
    ss.osx.deployment_target = '10.11'
    ss.tvos.deployment_target = '9.2'
    ss.watchos.deployment_target = '2.0'
  end

  s.subspec 'SwiftRichString' do |ss|
    ss.source_files  = "Sources/SwiftRichString/**/*.swift"
    s.dependency 'SwiftRichString/CHTMLSAXParser'
    ss.ios.deployment_target = '9.0'
    ss.osx.deployment_target = '10.11'
    ss.tvos.deployment_target = '9.2'
    ss.watchos.deployment_target = '2.0'
  end

end
