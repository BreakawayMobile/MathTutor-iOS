# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/brightcove/BrightcoveSpecs.git'

def default_pods
  # Local pods for development
  podLocal = ENV['POD_LOCAL_HOME']
  #pod 'BGSMobilePackage/Base', :path => podLocal + '/BGSMobilePackage'
  #pod 'BGSMobilePackage/Auth', :path => podLocal + '/BGSMobilePackage'

  # Pods for MathTutor
  pod 'BGSMobilePackage/Base', :git => 'https://github.com/BrightcovePS/BGSMobilePackage.git', :branch => 'development'
  pod 'BGSMobilePackage/Auth', :git => 'https://github.com/BrightcovePS/BGSMobilePackage.git', :branch => 'development'
  pod 'SwiftLint'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'iCarousel'
  pod 'ScrollableStackView'
  #pod 'GoogleConversionTracking'
  pod 'Firebase/Core'
#  pod 'OpenSSL-for-iOS', '1.0.2.d.1'
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

target 'MathTutor BGS' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    # Pods for MathTutor
    default_pods

end
