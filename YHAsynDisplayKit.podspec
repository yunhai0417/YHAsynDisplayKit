Pod::Spec.new do |s|
  s.name         = 'YHAsynDisplayKit'
  s.version      = '0.0.1' 
  s.summary      = 'YHKit'
  s.homepage     = "https://github.com/yunhai0417/YHAsynDisplayKit.git"
  s.license      = "MIT"
  s.author       = { "wuyunhai" => "363067575@qq.com" }
  s.social_media_url   = ""
  s.source = {:git => 'https://github.com/yunhai0417/YHAsynDisplayKit.git'}
  
  s.platform = :ios,'9.0'
  s.swift_version = '5.0'
  s.static_framework = true
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  s.exclude_files = 'YHAsynDisplayKit/YHAsynDisplayKit/info.plist'
  s.subspec 'Core' do |spec|
    spec.source_files = 'YHAsynDisplayKit/YHAsynDisplayKit/**/*.{h,m,swift}'
    spec.public_header_files = 'YHAsynDisplayKit/YHAsynDisplayKit/**/*.{h}'
    spec.frameworks = 'QuartzCore','UIKit','CoreGraphics','CFNetwork'
    
    spec.dependency 'SDWebImage' 
  end
  
  
end
