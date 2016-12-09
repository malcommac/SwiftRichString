Pod::Spec.new do |spec|
  spec.name = 'SwiftRichString'
  spec.version = '0.9.0'
  spec.summary = 'Elegant and painless Attributed String (NSAttributedString) in Swift'
  spec.homepage = 'https://github.com/malcommac/SwiftRichString'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'Daniele Margutti' => 'me@danielemargutti.com' }
  spec.social_media_url = 'http://twitter.com/danielemargutti'
  spec.source = { :git => 'https://github.com/malcommac/SwiftRichString.git', :tag => "#{spec.version}" }
  spec.source_files = 'Sources/**/*.swift'
  spec.ios.deployment_target = '7.0'
  spec.watchos.deployment_target = '2.0'
  spec.osx.deployment_target = '10.10'
  spec.tvos.deployment_target = '9.0'
  spec.requires_arc = true
  spec.module_name = 'SwiftRichString'
end
