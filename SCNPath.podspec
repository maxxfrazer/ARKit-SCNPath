Pod::Spec.new do |s|
  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "SCNPath"
  s.version      = "0.1.0"
  s.summary      = "SCNPath lets you create paths for any purpose in AR."
  s.description  = <<-DESC
  					SCNPath lets you create a path from just centre points on the path you want to draw.
                   DESC
  s.homepage     = "https://github.com/maxxfrazer/ARKit-SCNPath"
  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT"
  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = "Max Cobb"
  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/maxxfrazer/ARKit-SCNPath.git", :tag => "#{s.version}" }
  s.swift_version = '4.2'
  s.ios.deployment_target = '12.0'
  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "SCNPath/*.swift"
end
