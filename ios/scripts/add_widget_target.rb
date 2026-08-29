#!/usr/bin/env ruby
# Adds the HonestFernWidget extension target to the Runner Xcode project.
# Idempotent: re-running on an already-configured project is a no-op.

require 'xcodeproj'

PROJECT_PATH = File.expand_path('../Runner.xcodeproj', __dir__)
TARGET_NAME  = 'HonestFernWidget'
APP_TARGET   = 'Runner'
BUNDLE_ID    = 'com.honestfern.currencyConverter'
WIDGET_BUNDLE_ID = "#{BUNDLE_ID}.widget"
APP_GROUP    = 'group.com.honestfern.currencyConverter'
DEPLOYMENT_TARGET = '15.0'
WIDGET_SOURCE = 'ios/Runner/Widgets/HonestFernWidget/HonestFernWidget.swift'
WIDGET_INFO_PLIST = 'ios/Runner/Widgets/HonestFernWidget/Info.plist'
WIDGET_ENTITLEMENTS = 'ios/Runner/Widgets/HonestFernWidget/HonestFernWidget.entitlements'
APP_ENTITLEMENTS = 'ios/Runner/Runner.entitlements'

# App version from pubspec (e.g. "0.1.0+1"). The widget extension MUST carry a
# non-empty version that matches the host app, otherwise the iOS simulator
# rejects the install with "Invalid placeholder attributes". The Flutter
# $(FLUTTER_BUILD_NAME)/$(FLUTTER_BUILD_NUMBER) vars are only defined for the
# Runner target, so we resolve the version here and pin it on the widget target
# via MARKETING_VERSION / CURRENT_PROJECT_VERSION instead.
pubspec = File.read(File.expand_path('../../pubspec.yaml', __dir__))
version_line = pubspec[/^version:\s*(.+)$/, 1].to_s.strip
MARKETING_VERSION = (version_line.split('+').first || '1.0').strip
CURRENT_PROJECT_VERSION = (version_line.split('+')[1] || '1').strip

project = Xcodeproj::Project.open(PROJECT_PATH)

# 1. Skip if already there
existing = project.targets.find { |t| t.name == TARGET_NAME }
if existing
  puts "Target '#{TARGET_NAME}' already exists, skipping creation"
  widget_target = existing
else
  puts "Creating target '#{TARGET_NAME}' (App Extension)"
  widget_target = project.new_target(
    :app_extension,
    TARGET_NAME,
    :ios,
    DEPLOYMENT_TARGET,
    project.products_group,
    :swift,
  )
end

# 2. Make sure deployment target is correct
widget_target.build_configurations.each do |config|
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = WIDGET_BUNDLE_ID
  config.build_settings['PRODUCT_NAME'] = TARGET_NAME
  # Pin a non-empty version matching the host app (Info.plist reads these via
  # $(MARKETING_VERSION)/$(CURRENT_PROJECT_VERSION)). Empty/mismatched versions
  # cause "Invalid placeholder attributes" at simulator install time.
  config.build_settings['MARKETING_VERSION'] = MARKETING_VERSION
  config.build_settings['CURRENT_PROJECT_VERSION'] = CURRENT_PROJECT_VERSION
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Widgets/HonestFernWidget/HonestFernWidget.entitlements'
  config.build_settings['INFOPLIST_FILE'] = 'Runner/Widgets/HonestFernWidget/Info.plist'
  config.build_settings['SKIP_INSTALL'] = 'YES'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  # Match the Runner app's signing
  config.build_settings['DEVELOPMENT_TEAM'] = ''
  # Required for Swift 6 with Xcode 26
  config.build_settings['SWIFT_VERSION'] = '5.0'
  # .appex is a bundle, not an executable
  config.build_settings['WRAPPER_EXTENSION'] = 'appex'
  # Embed without stripping — extensions need their own bundle
  config.build_settings['STRIP_INSTALLED_PRODUCT'] = 'NO'
end

# 3. Add Swift file to the target
runner_group = project.main_group['Runner'] || project.main_group
# Create a "HonestFernWidget" group under the Runner group so paths resolve
# relative to ios/Runner/HonestFernWidget/. Then INFOPLIST_FILE and
# CODE_SIGN_ENTITLEMENTS can use the simple "HonestFernWidget/..." relative
# path that Xcode expects.
widget_group = runner_group['HonestFernWidget'] || runner_group.new_group('HonestFernWidget', 'Widgets/HonestFernWidget')
# Also create a parent "Widgets" group if not present
unless runner_group['Widgets']
  runner_group.new_group('Widgets', 'Widgets')
end

# Keep the existing file reference when the script is rerun. Clearing the
# build phase first and then checking that phase made the old script add a new
# PBXFileReference on every invocation, despite claiming to be idempotent.
swift_ref = widget_target.source_build_phase.files_references.find do |file|
  file.path&.end_with?(File.basename(WIDGET_SOURCE))
end
swift_ref ||= widget_group.children.find do |file|
  file.respond_to?(:path) && file.path&.end_with?(File.basename(WIDGET_SOURCE))
end
swift_ref ||= widget_group.new_file(File.basename(WIDGET_SOURCE))

widget_target.source_build_phase.clear
widget_target.source_build_phase.add_file_reference(swift_ref)

# 4. Add Info.plist and entitlements as file references (the build
# settings point to them by relative path)
existing_paths = widget_group.children.map { |c| c.respond_to?(:path) ? c.path : nil }
unless existing_paths.any? { |p| p&.end_with?(File.basename(WIDGET_INFO_PLIST)) }
  info_plist_ref = widget_group.new_reference(File.basename(WIDGET_INFO_PLIST))
  info_plist_ref.last_known_file_type = 'text.plist.xml'
end
unless existing_paths.any? { |p| p&.end_with?(File.basename(WIDGET_ENTITLEMENTS)) }
  ent_ref = widget_group.new_reference(File.basename(WIDGET_ENTITLEMENTS))
  ent_ref.last_known_file_type = 'text.plist.entitlements'
end

# 5. Add WidgetKit framework
frameworks_build_phase = widget_target.frameworks_build_phase
unless frameworks_build_phase.files_references.any? { |f| f.path&.include?('WidgetKit') }
  framework_search_paths = project.frameworks_group
  widget_kit_ref = framework_search_paths.new_file('System/Library/Frameworks/WidgetKit.framework', :sdk_root)
  widget_kit_ref.source_tree = 'SDKROOT'
  widget_kit_ref.last_known_file_type = 'wrapper.framework'
  frameworks_build_phase.add_file_reference(widget_kit_ref)
  puts "  Added framework: WidgetKit"
end

unless frameworks_build_phase.files_references.any? { |f| f.path&.include?('SwiftUI') }
  swiftui_ref = project.frameworks_group.new_file('System/Library/Frameworks/SwiftUI.framework', :sdk_root)
  swiftui_ref.source_tree = 'SDKROOT'
  swiftui_ref.last_known_file_type = 'wrapper.framework'
  frameworks_build_phase.add_file_reference(swiftui_ref)
  puts "  Added framework: SwiftUI"
end

# 6. Set the main Runner target's CODE_SIGN_ENTITLEMENTS
runner_target = project.targets.find { |t| t.name == APP_TARGET }
raise "Runner target not found" unless runner_target
runner_target.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
  # Disable App Intents metadata extraction — Xcode 14+ auto-generates
  # an ExtractAppIntentsMetadata phase that creates a cycle with our
  # Embed App Extensions copy phase. The widget doesn't use App Intents.
  config.build_settings['ENABLE_APP_INTENTS_DEPLOYMENT_AWARE_PROCESSING'] = 'NO'
end
puts "  Set Runner CODE_SIGN_ENTITLEMENTS"

# 7. Add Embed App Extensions build phase to Runner, pointing at the widget
# IMPORTANT: this phase must run BEFORE the Flutter Thin Binary and
# Embed Pods Frameworks script phases, otherwise Xcode reports a
# cycle ("Embed App Extensions" → "Thin Binary" → "ExtractAppIntentsMetadata"
# → "Embed App Extensions"). We achieve this by inserting the phase
# right after PBXResourcesBuildPhase (so it comes before
# PBXCopyFilesBuildPhase "Embed Frameworks" and the Flutter scripts).
embed_phase = runner_target.copy_files_build_phases.find { |p| p.symbol_dst_subfolder_spec == :plug_ins }
if embed_phase
  # Make sure it has the widget file
  unless embed_phase.files_references.any? { |f| f.path == "HonestFernWidget.appex" }
    widget_product_ref = widget_target.product_reference
    build_file = embed_phase.add_file_reference(widget_product_ref)
    build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
    puts "  Embedded HonestFernWidget.appex in Runner"
  end
else
  # Create the new phase AFTER the existing resources phase. We
  # achieve this by:
  # 1. Creating the phase (xcodeproj appends to the end of build_phases)
  # 2. Removing it from its current slot
  # 3. Re-inserting at the target index
  embed_phase = runner_target.new_copy_files_build_phase('Embed App Extensions')
  embed_phase.symbol_dst_subfolder_spec = :plug_ins
  embed_phase.run_only_for_deployment_postprocessing = '0'
  # Add the widget product file reference first so the phase has its content
  widget_product_ref = widget_target.product_reference
  build_file = embed_phase.add_file_reference(widget_product_ref)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

  # Now move the new phase to right after PBXResourcesBuildPhase.
  # xcodeproj's build_phases is a normal Array, so we can splice it.
  phases = runner_target.build_phases
  new_idx = phases.index(embed_phase)
  resources_idx = phases.index(
    phases.find { |p| p.is_a?(Xcodeproj::Project::Object::PBXResourcesBuildPhase) }
  )
  if new_idx && resources_idx && new_idx > resources_idx + 1
    # Remove from end and insert right after resources
    phases.delete_at(new_idx)
    phases.insert(resources_idx + 1, embed_phase)
    puts "  Created Embed App Extensions phase (placed after resources, before embed-frameworks)"
  else
    puts "  Created Embed App Extensions phase (at end)"
  end
end

# 8. Make Runner depend on the widget so it builds first
# Skipped: the Embed App Extensions copy phase already creates the
# build-order dependency, and adding a target dependency too creates a
# cycle that Xcode complains about ("Cycle inside Runner").
# unless runner_target.dependency_for_target(widget_target)
#   runner_target.add_dependency(widget_target)
#   puts "  Added Runner -> HonestFernWidget dependency"
# end

project.save
puts "Saved project.pbxproj"
