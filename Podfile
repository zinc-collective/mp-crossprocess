# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

project 'CrossProcess.xcodeproj'

target 'CrossProcess' do
    
    # pod 'Fabric', '~> 1.6.7'
    # pod 'Crashlytics', '~> 3.7.0'
    
end



post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end