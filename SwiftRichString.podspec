Pod::Spec.new do |spec|
  spec.name = 'SwiftRichString'
  spec.version = '0.9.8'
  spec.summary = 'Elegant and painless Attributed String (NSAttributedString) in Swift'
  spec.homepage = 'https://github.com/malcommac/SwiftRichString'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'Daniele Margutti' => 'me@danielemargutti.com' }
  spec.social_media_url = 'http://twitter.com/danielemargutti'
  spec.source = { :git => 'https://github.com/malcommac/SwiftRichString.git', :tag => "#{spec.version}" }
  spec.source_files = 'Sources/**/*.swift'
  spec.ios.deployment_target = '8.0'
  spec.tvos.deployment_target = '9.0'
  spec.requires_arc = true
  spec.module_name = 'SwiftRichString'
end
