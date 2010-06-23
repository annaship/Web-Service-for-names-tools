def set_address
  @host_name = "http://localhost"
  
  @neti_taxon_finder_web_service_url = @host_name+":4567"
  @reconciliation_web_service_url = @host_name+":3000"
  @tmp_dir_host = @host_name+"/sinatra/tmp/"
  @master_lists_dir = @host_name+"/sinatra/master_lists/"
end
