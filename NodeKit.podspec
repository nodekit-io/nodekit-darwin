Pod::Spec.new do |s|
  s.name         = "NodeKit"
  s.version      = "0.8.0"
  s.summary      = "The universal, open-source, embedded engine"
  s.description  = "NodeKit is the universal, open-source, embedded engine that provides a full ES5 / Node.js instance inside desktop and mobile applications for OS X, iOS, Android, and Windows."
  s.homepage     = "https://github.com/nodekit-io/nodekit"
  s.license      = { :type => 'APACHE-2', :file => 'LICENSE' }
  s.author       = { "OffGrid Networks" => 'admin@offgridn.com' }
  s.source       = { :git => "https://github.com/nodekit-io/nodekit-darwin.git" }

  s.ios.deployment_target = '9.3'
  s.osx.deployment_target = '10.11'
  s.requires_arc = true

  s.subspec 'NKScripting' do |nks|
    nks.libraries = 'compression'
    nks.source_files =  "src/nodekit/NKScripting/**/*.{swift,h,m}"
    nks.resources =  [
          'src/nodekit/NKScripting/lib-scripting.nkar',
        ]
  end

  s.subspec 'NKElectro' do |nke|
    nke.source_files =  "src/nodekit/NKElectro/**/*.{swift,h,m}"
    nke.resources =  [
          'src/nodekit/NKElectro/lib-electro.nkar',
          'src/nodekit/NKElectro/NK_ElectroHost/www/default.nkar',
          'src/nodekit/NKElectro/NK_ElectroHost/splash/default.nkar'
        ]
  end

  s.subspec 'NKCore' do |nkc|
    nkc.source_files =  "src/nodekit/NKCore/**/*.{swift,h,m}"
    nkc.resources =  [
          'src/nodekit/NKCore/lib-core.nkar',
        ]
  end

end

Pod::Spec.new do |s|
s.name         = "NKScripting"
s.version      = "0.8.0"
s.summary      = "The universal, open-source, embedded engine"
s.description  = "NodeKit is the universal, open-source, embedded engine that provides a full ES5 / Node.js instance inside desktop and mobile applications for OS X, iOS, Android, and Windows."
s.homepage     = "https://github.com/nodekit-io/nodekit"
s.license      = { :type => 'APACHE-2', :file => 'LICENSE' }
s.author       = { "OffGrid Networks" => 'admin@offgridn.com' }
s.source       = { :git => "https://github.com/nodekit-io/nodekit-darwin.git" }

s.ios.deployment_target = '9.3'
s.osx.deployment_target = '10.11'
s.requires_arc = true

s.libraries = 'compression'
s.source_files =  "src/nodekit/NKScripting/**/*.{swift,h,m}"
s.resources =  [
'src/nodekit/NKScripting/lib-scripting.nkar',
]

end


Pod::Spec.new do |s|
s.name         = "NKElectro"
s.version      = "0.8.0"
s.summary      = "The universal, open-source, embedded engine"
s.description  = "NodeKit is the universal, open-source, embedded engine that provides a full ES5 / Node.js instance inside desktop and mobile applications for OS X, iOS, Android, and Windows."
s.homepage     = "https://github.com/nodekit-io/nodekit"
s.license      = { :type => 'APACHE-2', :file => 'LICENSE' }
s.author       = { "OffGrid Networks" => 'admin@offgridn.com' }
s.source       = { :git => "https://github.com/nodekit-io/nodekit-darwin.git" }

s.ios.deployment_target = '9.3'
s.osx.deployment_target = '10.11'
s.requires_arc = true

s.source_files =  "src/nodekit/NKElectro/**/*.{swift,h,m}"
s.resources =  [
'src/nodekit/NKElectro/lib-electro.nkar',
'src/nodekit/NKElectro/NK_ElectroHost/www/default.nkar',
'src/nodekit/NKElectro/NK_ElectroHost/splash/default.nkar'
]


end


Pod::Spec.new do |s|
s.name         = "NKCore"
s.version      = "0.8.0"
s.summary      = "The universal, open-source, embedded engine"
s.description  = "NodeKit is the universal, open-source, embedded engine that provides a full ES5 / Node.js instance inside desktop and mobile applications for OS X, iOS, Android, and Windows."
s.homepage     = "https://github.com/nodekit-io/nodekit"
s.license      = { :type => 'APACHE-2', :file => 'LICENSE' }
s.author       = { "OffGrid Networks" => 'admin@offgridn.com' }
s.source       = { :git => "https://github.com/nodekit-io/nodekit-darwin.git" }

s.ios.deployment_target = '9.3'
s.osx.deployment_target = '10.11'
s.requires_arc = true

s.source_files =  "src/nodekit/NKCore/**/*.{swift,h,m}"
s.resources =  [
'src/nodekit/NKCore/lib-core.nkar',
]

end