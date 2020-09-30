# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Accountable' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Accountable
	pod 'Firebase/Analytics'	
	pod 'Firebase/Crashlytics'
	pod 'Firebase/Firestore'
	pod 'Firebase/Auth'
	pod 'Firebase/Messaging'
	pod 'FirebaseFirestoreSwift'

  target 'AccountableTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'AccountableUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.2'
    end
  end
end
