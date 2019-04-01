Pod::Spec.new do |s|
  s.name                  = "SCNPath"
  s.version               = "1.1.0"
  s.summary               = "SCNPath lets you create paths for any purpose in AR using just centre points for your path."
  s.homepage              = "https://github.com/maxxfrazer/ARKit-SCNPath"
  s.license               = { :type => 'MIT', :file => 'LICENSE'  }
  s.author                = { "Max Cobb" => "maxxc@mac.com" }
  s.source                = { :git => "https://github.com/maxxfrazer/ARKit-SCNPath.git", :tag => "#{s.version}" }
  s.platform              = :ios, '12.0'
  s.swift_version         = '5.0'
  s.frameworks            = 'SceneKit'
  s.source_files          = "SCNPath/*.swift", ".swiftlint.yml"
end
