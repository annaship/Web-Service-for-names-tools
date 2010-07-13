def read_config
  neti_neti_tf = YAML.load_file(File.dirname(__FILE__) + "/../config/config.yml")
  @host  = neti_neti_tf["neti_neti_tf"]["host"]
  @port  = neti_neti_tf["neti_neti_tf"]["port"]
end
