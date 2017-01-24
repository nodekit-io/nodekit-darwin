Pod::Spec.new do |s|
s.name         = "NKElectro"
s.version      = "0.8.11"
s.summary      = "The universal, open-source, embedded engine"
s.description  = "NodeKit is the universal, open-source, embedded engine that provides a full ES5 / Node.js instance inside desktop and mobile applications for OS X, iOS, Android, and Windows."
s.homepage     = "https://github.com/nodekit-io/nodekit"
s.license      = { :type => 'APACHE-2', :file => 'LICENSE' }
s.author       = { "OffGrid Networks" => 'admin@offgridn.com' }
s.source       = { :git => "https://github.com/nodekit-io/nodekit-darwin.git", :tag => "v0.8.11" }

s.ios.deployment_target = '9.0'
s.osx.deployment_target = '10.11'
s.requires_arc = true

s.source_files =  "src/nodekit/NKElectro/**/*.{swift,h,m}"
s.resources =  [
'src/nodekit/NKElectro/lib-electro.nkar',
'src/nodekit/NKElectro/NK_ElectroHost/www/default.nkar',
'src/nodekit/NKElectro/NK_ElectroHost/splash/default.nkar'
]
s.dependency 'NKScripting'

end
