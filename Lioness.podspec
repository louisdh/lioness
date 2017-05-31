Pod::Spec.new do |s|
  s.name = 'Lioness'
  s.version = '0.5.0'
  s.license = 'MIT'
  s.summary = 'The Lioness Programming Language'
  s.homepage = 'https://github.com/louisdh/lioness'
  s.social_media_url = 'http://twitter.com/LouisDhauwe'
  s.authors = { 'Louis D\'hauwe' => 'louisdhauwe@silverfox.be' }
  s.source = { :git => 'https://github.com/louisdh/lioness.git', :tag => s.version }

  s.ios.deployment_target = '9.0'
  spec.osx.deployment_target  = '10.10'

  s.source_files = 'Lioness/**/*.swift'
end
