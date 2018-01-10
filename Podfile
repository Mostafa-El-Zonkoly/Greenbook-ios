# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'greenBook' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for greenBook

pod 'SDWebImage', '~>3.8'
pod 'MBProgressHUD', '~> 1.0.0'
pod 'Alamofire', '~>4.3.0'
pod 'Fabric'
pod 'Crashlytics'
pod 'Toast-Swift', '~> 2.0.0'
pod 'ReachabilitySwift'
pod 'NVActivityIndicatorView'
pod 'SwiftMessages'
pod 'Cosmos', '~> 12.0'
pod 'XLPagerTabStrip'
pod 'FTImageViewer'
pod 'Kingfisher'
pod 'Firebase'
pod 'Firebase/Core'
pod 'Firebase/Messaging'
pod 'Firebase/Database'
pod 'Firebase/DynamicLinks'
pod 'Firebase/Auth'
pod 'Firebase/Storage'
pod 'FacebookCore'
pod 'FacebookLogin'
pod 'FacebookShare'
pod 'GoogleMaps'
pod 'GooglePlaces'
pod 'GooglePlacesAPI'
pod 'GoogleAPIClientForREST/Drive', '~> 1.2.1'
pod 'Google/SignIn', '~> 3.0.3'
pod 'DropDown'
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |configuration|
            # these libs work now only with Swift3.2 in Xcode9
            if ['ObjectMapper'].include? target.name
                configuration.build_settings['SWIFT_VERSION'] = "3.2"
            end
        end
    end
end
end
