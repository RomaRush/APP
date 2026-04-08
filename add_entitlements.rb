require 'xcodeproj'

# Path to the Xcode project
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Ensure the Runner target exists
target = project.targets.find { |t| t.name == 'Runner' }
if target.nil?
  puts 'Runner target not found'
  exit 1
end

# The path to the entitlements file relative to the project directory
entitlements_path = 'Runner/Runner.entitlements'

# Add the file to the project's file references if it doesn't exist
file_ref = project.main_group.find_file_by_path(entitlements_path)
unless file_ref
  runner_group = project.main_group.children.find { |g| g.display_name == 'Runner' || g.path == 'Runner' }
  file_ref = runner_group.new_file('Runner.entitlements')
end

# Update build settings to use the entitlements file
target.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = entitlements_path
end

project.save
puts 'Entitlements successfully added to the project'
