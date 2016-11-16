Pod::Spec.new do |s|
  s.name         = "Monocle"
  s.version      = "0.0.2"
  s.summary      = "A lens as a µFramework."
  s.homepage     = "https://github.com/robb/Monocle"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Robert Böhnke" => "robb@robb.is" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"

  s.source = { :git => "https://github.com/robb/Monocle.git", :tag => "#{s.version}" }
  s.source_files  = "Monocle/*.swift"

  s.requires_arc = true

end
