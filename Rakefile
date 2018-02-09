PROJECT_NAME = "Halo"
CONFIGURATION = "Debug"
SPECS_TARGET_NAME = "Specs"
UI_SPECS_TARGET_NAME = "UISpecs"
SDK_DIR = "/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator4.2.sdk"

def build_dir(effective_platform_name)
  File.join(File.dirname(__FILE__), "build", CONFIGURATION + effective_platform_name)
end

def system_or_exit(cmd, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout} 2>&1" if stdout
  system(cmd) or raise "******** Build failed ********"
end

def output_file(target)
  output_dir = ENV['IS_CI_BOX'] ? ENV['CC_BUILD_ARTIFACTS'] : File.join(File.dirname(__FILE__), "build")
  output_file = File.join(output_dir, "build_#{target}.output")
  puts "Output: #{output_file}"
  return output_file
end

task :default => [:specs, :uispecs]
task :cruise do
  Rake::Task['jasmine:ci'].invoke
  Rake::Task[:clean].invoke
  Rake::Task[:specs].invoke
  Rake::Task[:uispecs].invoke
end

task :clean do
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -alltargets -configuration #{CONFIGURATION} clean], output_file("clean"))
end

task :build_specs do
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{SPECS_TARGET_NAME} -configuration #{CONFIGURATION} build], output_file("specs"))
end

task :build_uispecs do
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{UI_SPECS_TARGET_NAME} -configuration #{CONFIGURATION} -sdk iphonesimulator4.2 ARCHS=i386 build], output_file("uispecs"))
end

task :build_all do
  stdout = File.join(ENV['CC_BUILD_ARTIFACTS'], "build_all.output") if (ENV['IS_CI_BOX'])
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -alltargets -configuration #{CONFIGURATION} build], output_file("buildall"))
end

task :specs => :build_specs do
  build_dir = build_dir("")
  ENV["DYLD_FRAMEWORK_PATH"] = build_dir
  system_or_exit("cd #{build_dir} && ./#{SPECS_TARGET_NAME}")
end

require 'tmpdir'
task :uispecs => :build_uispecs do
  ENV["DYLD_ROOT_PATH"] = SDK_DIR
  ENV["IPHONE_SIMULATOR_ROOT"] = SDK_DIR
  ENV["CFFIXED_USER_HOME"] = Dir.tmpdir
  ENV["CEDAR_HEADLESS_SPECS"] = "1"

  system_or_exit(%Q[#{File.join(build_dir("-iphonesimulator"), "#{UI_SPECS_TARGET_NAME}.app", UI_SPECS_TARGET_NAME)} -RegisterForSystemEvents]);
end

namespace :jasmine do
  task :require do
    require 'jasmine'
  end

  desc "Run continuous integration tests"
  task :ci => "jasmine:require" do
    require "spec"
    require 'spec/rake/spectask'

    Spec::Rake::SpecTask.new(:jasmine_continuous_integration_runner) do |t|
      t.spec_opts = ["--color", "--format", "specdoc"]
      t.verbose = true
      t.spec_files = ['Spec/Content/javascript/jasmine_support/jasmine_runner.rb']
    end
    Rake::Task["jasmine_continuous_integration_runner"].invoke
  end

  task :server => "jasmine:require" do
    jasmine_config_overrides = 'Spec/Content/javascript/jasmine_support/jasmine_config.rb'
    require jasmine_config_overrides if File.exists?(jasmine_config_overrides)

    puts "your tests are here:"
    puts "  http://localhost:8888/"

    Jasmine::Config.new.start_server
  end
end

task :spec do
    system_or_exit("script/spec #{Dir.glob("Spec/**/*_spec.rb")}")
end

desc "Run specs via server"
task :jasmine => ['jasmine:server']
