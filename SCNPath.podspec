Pod::Spec.new do |s|
  s.name                  = "SCNPath"
  s.version               = "1.3.0"
  s.summary               = "SCNPath lets you create paths for any purpose in AR using just centre points for your path."
  s.homepage              = "https://github.com/maxxfrazer/ARKit-SCNPath"
  s.license               = { :type => 'MIT', :file => 'LICENSE'  }
  s.author                = { "Max Cobb" => "maxxc@mac.com" }
  s.source                = { :git => "https://github.com/maxxfrazer/ARKit-SCNPath.git", :tag => "#{s.version}" }
  s.platform              = :ios, '13.0'
  s.swift_version         = '5.3'
  s.frameworks            = 'SceneKit', 'RealityKit'
  s.source_files          = "Sources/SCNPath/*.swift", ".swiftlint.yml"
end
