def set_address
  @neti_neti_host = "http://localhost"
  local_server = "http://localhost"
  ####FIX THIS WITH CORRECT SINATRA METHOD
  @neti_taxon_finder_web_service_url = @neti_neti_host+":4567"
  # @reconciliation_web_service_url = @neti_neti_host+":3000"
  @tmp_dir_host = local_server + "/upload/"
  #@master_lists_dir = @neti_neti_host+"/sinatra/master_lists/"
end
