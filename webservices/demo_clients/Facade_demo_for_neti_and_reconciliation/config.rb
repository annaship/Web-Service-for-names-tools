def set_address
  @host_name = "http://"+@host
  
  @neti_taxon_finder_web_service_url = @host_name+":4567"
  @reconciliation_web_service_url    = @host_name+":3000"
  @tmp_dir_host                      = @host_name+"/public/upload/"
  @master_lists_dir                  = @host_name+"/public/texts/master_lists/"

end
