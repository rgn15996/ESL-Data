module ESLdata

  require 'rubygems'
  require 'rest_client'

  def ESLdata.classify_server(server)
    server_type = "Unknown"
    # :system_type :os_class :virtualization_role :virtualization_technology classifiaction
    templates = [
      ["server", "*", "Virtual Guest", "VMWare", "VMWare_guest"],
      ["server", "*", "Server for Virtual Guest", "VMWare", "VMWare_host"],
      ["cluster node", "*", "Server for Virtual Guest", "VMWare", "VMWare_host"],
      ["farm", "VMWare", "Farm", "VMWare", "VMWare_cluster"],
      ["server", "AIX", "Secure Resource Partition", "LPAR", "PowerVM_guest"],
      ["cluster node", "AIX", "Secure Resource Partition", "LPAR", "PowerVM_guest"],
      ["server", "AIX", "Server for Secure Resource Partition", "LPAR", "PowerVM_host"],
      ["server", "Other", "Server for Secure Resource Partition", "LPAR", "PowerVM_host"],
      ["server", "AIX", "#UNDEFINED#", "#UNDEFINED#", "AIX_Physical_server"],
      ["server", "Windows", "#UNDEFINED#", "#UNDEFINED#", "Windows_Physical_server"],
      ["server", "Linux", "#UNDEFINED#", "#UNDEFINED#", "Linux_Physical_server"],
      ["server", "HP-UX", "#UNDEFINED#", "#UNDEFINED#", "HPUX_Physical_server"],
      ["server", "Other", "#UNDEFINED#", "#UNDEFINED#", "Unidentified_server"],
      ["cluster", "*", "#UNDEFINED#", "#UNDEFINED#", "Cluster"],
      ["cluster node", "*", "#UNDEFINED#", "#UNDEFINED#", "Cluster_node"],
      ["cluster package", "*", "#UNDEFINED#", "#UNDEFINED#", "Cluster_package"],
      ["cabinet", "*", "#UNDEFINED#", "#UNDEFINED#", "Cabinet"],
      ["storage", "*", "#UNDEFINED#", "#UNDEFINED#", "Storage"],
      ["tape drive", "*", "#UNDEFINED#", "#UNDEFINED#", "Tape_drive"],
      ["tape library", "*", "#UNDEFINED#", "#UNDEFINED#", "Tape_library"],
      ["server", "*", "Virtual Guest", "HP-IVM", "HP_guest"],
      ["server", "*", "Server for Virtual Guest", "HP-IVM", "HP_host"],
      ["server", "*", "Virtual Guest", "Solaris Zones", "Solaris_zone"],
      ["farm", "*", "Farm", "Solaris Zones", "Solaris_host"],
      ["san switch", "*", "#UNDEFINED#", "#UNDEFINED#", "SAN_switch"],
      ["server", "OS/400", "Server for Virtual Guest", "LPAR", "AS400"],
      ["server", "OS/400", "Server for Secure Resource Partition", "LPAR", "AS400"],
      ["mainframe", "*", "Server for Secure Resource Partition", "LPAR", "Mainframe"],
      ["server", "z/OS", "Secure Resource Partition", "LPAR", "Mainframe_LPAR"],
      ["server", "Other", "Secure Resource Partition", "LPAR", "Unknown_IBM_LPAR"],
      ["server", "z/OS", "#UNDEFINED#", "#UNDEFINED#", "Mainframe_LPAR_THING"],
      ["firewall", "*", "#UNDEFINED#", "#UNDEFINED#", "Firewall"]      
    ]

    test_array = [
      server[:system_type],
      server[:os_class],
      server[:virtualization_role],
      server[:virtualization_technology]
      ]
    
    
    templates.each do |template|
      match = true
      test_array.each_with_index do |val, index|
        #str = val.to_s.gsub(/\s+/," ") # remove whitespace
        match = false unless (template[index] == "*" || val == template[index])
      end
      if match then
        server_type = template[4]
        break
      end
    end
    if server_type == "Unknown" then
      puts " "
      puts "#{server[:full_node_name]} ->"
      puts test_array
      puts "#{server[:os_version]}"
      puts "#{server[:customer_classification]}"
    end

    return server_type
  end

  def ESLdata.constructQuery(sys, type, index)

    query_string = "CREATE (n#{index}:#{type} { name : '#{sys[:full_node_name]}' "

    case type
    when "PowerVM_guest", "VMWare_guest", "Windows_Physical_server", 
      "Linux_Physical_server", "AIX_Physical_server"
      query_string += ", os_version : '#{sys[:os_version]}' "
      query_string += ", os_class: '#{sys[:os_class]}' "
      query_string += ", contract_service_level: '#{sys[:contract_service_level]}' "
      query_string += ", system_status: '#{sys[:system_status]}' "
    end

    query_string += "}) "
    return query_string

  end

  BASE_URL = 'http://localhost:7474/db/data'

  def ESLdata.open_transaction
    url = BASE_URL + '/transaction'
    request = ""
    request_headers = {:content_type => :json, :accept => :json}
    response = RestClient.post url, request, request_headers
  end

  def ESLdata.transact_query(url, query)
    result = RestClient.post url, 
    query, 
    {:content_type => :json, :accept => :json}
    return result
  end

  def ESLdata.cypher_query(query)
    url = BASE_URL + '/cypher'
    result = RestClient.post url, 
    query, 
    {:content_type => :json, :accept => :json}
    return result
  end

  def ESLdata.commit_transaction(commit_url)
    result = RestClient.post commit_url, "", 
      {:content_type => :json, :accept => :json}
    return result
  end

  def ESLdata.isVMGuest(server)
    server[:system_type] == "server" && 
    server[:virtualization_role] == "Virtual Guest" && 
    server[:virtualization_technology] == "VMWare"
  end

  def ESLdata.isVMHost(server)
    server[:system_type] == "server" && 
    server[:virtualization_role] == "Server for Virtual Guest" && 
    server[:virtualization_technology] == "VMWare"
  end

  def ESLdata.isPowerVMGuest(server)
    (server[:system_type] == "server" || server[:system_type == "cluster node"]) && 
    server[:virtualization_role] == "Secure Resource Partition" && 
    server[:virtualization_technology] == "LPAR"
  end

  def ESLdata.isPowerVMHost(server)
    server[:system_type] == "server" && 
    server[:virtualization_role] == "Server for Secure Resource Partition" && 
    server[:virtualization_technology] == "LPAR"
  end

  def ESLdata.load_servers(servers)
    count = 0
    source = "data/esl_aviva_1_srv.csv"
    opts = {:headers => true, :header_converters => :symbol, :col_sep => "|"}
    CSV.foreach(source, opts) do |row|
      servers[count] = row
      servers[count].each do |field, value|
        if value.nil? then
          servers[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
  end

  def ESLdata.load_all_vms(vms)
    count = 0
    puts "Loading VM data from CSV file..."
    CSV.foreach("data/all_vms_25042013.csv", {:headers => true, :header_converters => :symbol}) do |row|
      vms[count] = row
      vms[count].each do |field, value|
        if value.nil? then
          vms[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
    puts "Loaded #{count} nodes from vm data"
  end

  def ESLdata.load_relations(rels)
    count = 0
    puts "Loading Relation data"
    CSV.foreach("data/esl_aviva_9_sys_rel.csv", {:headers => true, :header_converters => :symbol, :col_sep => "|"}) do |row|
      rels[count] = row
      rels[count].each do |field, value|
        if value.nil? then
          rels[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
    puts "Loaded #{count} rows from relationship data"
  end

  def ESLdata.load_hsns(hsns)
    count = 0
    puts "Loading HSN data"
    CSV.foreach("data/esl_aviva_3_sol.csv", {:headers => true, :header_converters => :symbol, :col_sep => "|"}) do |row|
      hsns[count] = row
      hsns[count].each do |field, value|
        if value.nil? then
          hsns[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
    puts "Loaded #{count} rows from HSN data"
  end      

  def ESLdata.del_deinstalled(servers)
    servers.delete_if {|server| server[:system_status] == "deinstalled"}
  end

  def ESLdata.find_vmguests(servers)
    vmguests = Array.new
    servers.each do |server|
      if isvmguest(server) then
        vmguests << server
      end
    end
    vmguests
  end

  def ESLdata.find_vmhosts(servers)
    vmhosts = Array.new
    servers.each do |server|
      if isvmhost(server) then
        vmhosts << server
      end
    end
    vmhosts
  end


end