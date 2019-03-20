Pod::Spec.new do |s|
  s.name = 'Signals'
  s.version = '6.0.1'
  s.license = 'MIT'
  s.summary = 'Elegant eventing'
  s.homepage = 'https://github.com/artman/Signals'
  s.social_media_url = 'http://twitter.com/artman'
  s.authors = { 'Tuomas Artman' => 'tuomas@artman.fi' }
  s.source = { :git => 'https://github.com/artman/Signals.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Signals/Signal.swift'
  s.ios.source_files = 'Signals/iOS/*.swift'
  s.tvos.source_files = 'Signals/iOS/*.swift'
  
  s.swift_version = '4.2'
end
