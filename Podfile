workspace 'MotionAnimator.xcworkspace'
use_frameworks!

target "MotionAnimatorCatalog" do
  pod 'CatalogByConvention'
  pod 'MotionAnimator', :path => './'
  project 'examples/apps/Catalog/MotionAnimatorCatalog.xcodeproj'
end

target "UnitTests" do
  project 'examples/apps/Catalog/MotionAnimatorCatalog.xcodeproj'
  pod 'MotionAnimator', :path => './'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['SWIFT_VERSION'] = "3.0"
      if target.name.start_with?("Motion")
        configuration.build_settings['WARNING_CFLAGS'] ="$(inherited) -Wall -Wcast-align -Wconversion -Werror -Wextra -Wimplicit-atomic-properties -Wmissing-prototypes -Wno-sign-conversion -Wno-unused-parameter -Woverlength-strings -Wshadow -Wstrict-selector-match -Wundeclared-selector -Wunreachable-code -Wno-error=deprecated -Wno-error=deprecated-implementations"
      end
    end
  end
end
