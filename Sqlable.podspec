Pod::Spec.new do |s|
  s.name         = "Sqlable"
  s.version      = "1.1.2"
  s.summary      = "A short description of Sqlable."
  s.homepage     = "https://github.com/ulrikdamm/Sqlable"

  s.license      = "MIT"
  s.author       = { "Ulrik Flænø Damm" => "https://github.com/ulrikdamm" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/ulrikdamm/Sqlable.git", :commit => "332a479" }
  s.source_files  = "Sources"
  s.public_header_files = "Supporting files/*.h"
  s.module_map = "module.modulemap"

  s.library   = "sqlite"
  s.requires_arc = true
end
