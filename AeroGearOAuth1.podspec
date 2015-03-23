Pod::Spec.new do |s|
  s.name         = "AeroGearOAuth1"
  s.version      = "0.0.1"
  s.summary      = "OAuth1a client library based on aerogear-ios-http"
  s.homepage     = "https://github.com/aerogear/aerogear-ios-oauth2"
  s.license      = 'Apache License, Version 2.0'
  s.author       = "Red Hat, Inc."
  s.source       = { :git => 'https://github.com/corinnekrych/aerogear-ios-oauth1.git', :tag => s.version }
  s.platform     = :ios, 8.0
  s.source_files = 'AeroGearOAuth1/*.{swift}'
  s.requires_arc = true
  s.framework = 'Security'
  s.dependency 'AeroGearHttp', '0.2.0'
  s.dependency 'CryptoSwift', '0.0.8'
end