Pod::Spec.new do |s|
  s.name         = "NodeKit"
  s.version      = "0.9.6"
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
    nks.frameworks = 'libcompression'
    nks.source_files =  "src/nodekit/NKScripting/**/*.{swift,h,m}"
    nks.resources =  [
          'src/nodekit/NKScripting/lib-scripting/**/*',
        ]
  end

  s.subspec 'NKElectro' do |nke|
    nke.source_files =  "src/nodekit/NKElectro/**/*.{swift,h,m}"
    nke.resources =  [
          'src/nodekit/NKElectro/lib-electro/**/*',
          'src/nodekit/NKElectro/NK_ElectroHost/www/default/**/*',
          'src/nodekit/NKElectro/NK_ElectroHost/splash/default/**/*'
        ]
  end

  s.subspec 'NKCore' do |nkc|
    nkc.source_files =  "src/nodekit/NKCore/**/*.{swift,h,m}"
    nkc.resources =  [
          'src/nodekit/NKCore/lib/**/*',
        ]
  end

end