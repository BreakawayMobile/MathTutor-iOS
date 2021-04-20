# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/brightcove/BrightcoveSpecs.git'

def default_pods
  # Local pods for development
  podLocal = ENV['MT_ENV_HOME']
  #pod 'BMMobilePackage/Base', :path => podLocal + '/BMMobilePackage'
  #pod 'BMMobilePackage/Auth', :path => podLocal + '/BMMobilePackage'

  # Pods for MathTutor
  pod 'BMMobilePackage/Base', :git => 'https://github.com/BreakawayMobile/BMMobilePackage.git', :branch => 'development'
  pod 'BMMobilePackage/Auth', :git => 'https://github.com/BreakawayMobile/BMMobilePackage.git', :branch => 'development'
  pod 'SwiftLint', :inhibit_warnings => true
  pod 'Fabric', :inhibit_warnings => true
  pod 'Crashlytics', :inhibit_warnings => true
  pod 'iCarousel', :inhibit_warnings => true
  pod 'ScrollableStackView', :inhibit_warnings => true
  #pod 'GoogleConversionTracking'
  pod 'Firebase/Core', :inhibit_warnings => true
#  pod 'OpenSSL-for-iOS', '1.0.2.d.1'

  # Dependencies for BGSMobilePackage, only here to inhibit warnings
  pod 'RATreeView', :inhibit_warnings => true
  pod "Kingfisher", :inhibit_warnings => true
  pod "UIView-Autolayout", :inhibit_warnings => true
  pod "SDWebImage", :inhibit_warnings => true
  pod "Brightcove-Player-Core/dynamic", '6.0.6'
  pod "StorageKit", :inhibit_warnings => true
  pod "MBProgressHUD", :inhibit_warnings => true
  pod "CustomIOSAlertView", :inhibit_warnings => true
  pod "SlideMenuControllerSwift", :inhibit_warnings => true
  pod "iOSSharedViewTransition", :inhibit_warnings => true
  pod "SwipeView", :inhibit_warnings => true
  pod "CarbonKit", :inhibit_warnings => true
  pod "ChameleonFramework", :inhibit_warnings => true
  pod "treemapkit", :inhibit_warnings => true
  pod "RATreeView", :inhibit_warnings => true
  pod "ReactiveCocoa", :inhibit_warnings => true
  pod "Realm", :inhibit_warnings => true
  pod "PromiseKit", :inhibit_warnings => true
  pod "RealmSwift", :inhibit_warnings => true

end

target 'MathTutor' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MathTutor
  default_pods

  target 'MathTutorTests' do
    inherit! :search_paths
    # Pods for testing
    default_pods
  end

  target 'MathTutorUITests' do
    inherit! :search_paths
    # Pods for testing
    default_pods
  end

end

target 'MathTutor BWAY' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    # Pods for MathTutor
    default_pods

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
