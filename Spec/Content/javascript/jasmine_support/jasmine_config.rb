class Jasmine::Config
  def simple_config_file
    File.join(project_root, 'Spec/Content/javascript/jasmine_support/jasmine.yml')
  end

  def spec_dir
    File.join(project_root, "Spec/Content/javascript")
  end

  def browser
    "googlechrome"
  end
end
