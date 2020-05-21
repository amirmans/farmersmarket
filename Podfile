source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!
target 'ManageMyMarket' do
pod 'AFNetworking', '~> 3.0'
pod 'SBJson'
pod 'SDWebImage', '~> 3.8'
pod 'AsyncImageView'
pod 'MBProgressHUD'
pod 'Reachability'
pod 'KASlideShow'
pod 'Stripe', '14.0.1'
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

