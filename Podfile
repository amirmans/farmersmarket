source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!
target 'TapForAll' do
pod 'AFNetworking'
pod 'SBJson'
pod 'SDWebImage'
pod 'AsyncImageView'
pod 'MBProgressHUD'
pod 'Reachability'
pod 'KASlideShow'
pod 'Stripe'
pod 'GoogleMaps'
pod 'SHMultipleSelect'
pod 'ActionSheetPicker-3.0'
pod 'BBBadgeBarButtonItem'
pod 'IQKeyboardManager'
pod 'NYAlertViewController'

post_install do |installer|
      installer.pods_project.targets.each do |target|
           target.build_configurations.each do |config|
                config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'NO'
           end
      end
 end
end

