require 'yaml'

module YAMLConfig  
  def initialize
    super()
  end
  
  def load_config_by_task_name(task_name)
    task_config = "#{task_name}.yml"
    task_config = File.join(Albacore::yaml_config_folder, task_config) unless Albacore::yaml_config_folder.nil?
    configure(task_config) if File.exists?(task_config)
  end
  
  def configure(yml_file)
    config = YAML::load(File.open(yml_file))
    parse_config config
  end  
  
  def parse_config(config)
    config.each do |key, value|
      setter = "#{key}="
      self.class.send(:attr_accessor, key) if !respond_to?(setter)
      send setter, value
    end
  end
end
