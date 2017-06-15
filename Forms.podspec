Pod::Spec.new do |s|
  s.name         = "Forms"
  s.version      = "0.0.1"
  s.summary      = "Buiseness logic for mobile forms."

  s.description  = <<-DESC
  Library provides logic to drive your forms. No UI is provide.
  It's provide all neccesasary attributes of form including validators,
  but is really flexible to customized for your needs
                   DESC

  s.homepage     = "https://github.com/yariksmirnov/Forms"
  s.screenshots  = "example.gif"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Yaroslav Smirnov" => "yarikbonch@gmail.com" }
  s.social_media_url   = "http://twitter.com/yariksmirnov"
  s.platform     = :ios
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/yariksmirnov/Forms.git", :tag => "#{s.version}" }
  s.source_files  = "Sources", "Sources/**/*.{swift}"
  s.framework  = "CoreTelephony"

end
