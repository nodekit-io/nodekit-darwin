Pod::Spec.new do |s|
s.name         = "NKCore"
s.version      = "0.8.7"
s.summary      = "The universal, open-source, embedded engine"
s.description  = "NodeKit is the universal, open-source, embedded engine that provides a full ES5 / Node.js instance inside desktop and mobile applications for OS X, iOS, Android, and Windows."
s.homepage     = "https://github.com/nodekit-io/nodekit"
s.license      = { :type => 'APACHE-2', :file => 'LICENSE' }
s.author       = { "OffGrid Networks" => 'admin@offgridn.com' }
s.source       = { :git => "https://github.com/nodekit-io/nodekit-darwin.git", :tag => "v0.8.7" }

s.ios.deployment_target = '9.0'
s.osx.deployment_target = '10.11'
s.requires_arc = true

s.source_files =  "src/nodekit/NKCore/**/*.{swift,h,m}"
s.resources =  [
'src/nodekit/NKCore/lib-core.nkar',
]
s.dependency 'NKScripting'

end
