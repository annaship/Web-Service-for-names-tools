def read_config
  reconsile = YAML.load_file(File.dirname(__FILE__) + "/../config/config.yml")
  @host     = reconsile["reconsile"]["host"]
  @port     = reconsile["reconsile"]["port"]
end
