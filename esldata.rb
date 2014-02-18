module ESLdata

  require 'rubygems'
  require 'rest_client'

  def ESLdata.classify_server(server)
    server_type = "Unknown"
    # :system_type :os_class :virtualization_role :virtualization_technology classifiaction
    # classication is camel cased with initial lower case
    templates = [
      ["server", "*", "Virtual Guest", "VMWare", "vmwareGuest"],
      ["server", "*", "Server for Virtual Guest", "VMWare", "vmwareHost"],
      ["cluster node", "*", "Server for Virtual Guest", "VMWare", "vmwareHost"],
      ["farm", "VMWare", "Farm", "VMWare", "vmwareCluster"],
      ["server", "AIX", "Secure Resource Partition", "LPAR", "powervmGuest"],
      ["cluster node", "AIX", "Secure Resource Partition", "LPAR", "powervmGuest"],
      ["server", "AIX", "Server for Secure Resource Partition", "LPAR", "powervmHost"],
      ["server", "Other", "Server for Secure Resource Partition", "LPAR", "powervmHost"],
      ["server", "AIX", "#UNDEFINED#", "#UNDEFINED#", "aixPhysicalServer"],
      ["server", "Windows", "#UNDEFINED#", "#UNDEFINED#", "windowsPhysicalServer"],
      ["server", "Linux", "#UNDEFINED#", "#UNDEFINED#", "linuxPhysicalServer"],
      ["server", "HP-UX", "#UNDEFINED#", "#UNDEFINED#", "hpuxPhysicalServer"],
      ["server", "Other", "#UNDEFINED#", "#UNDEFINED#", "unidentifiedServer"],
      ["cluster", "*", "#UNDEFINED#", "#UNDEFINED#", "cluster"],
      ["cluster node", "*", "#UNDEFINED#", "#UNDEFINED#", "clusterNode"],
      ["cluster package", "*", "#UNDEFINED#", "#UNDEFINED#", "clusterPackage"],
      ["cabinet", "*", "#UNDEFINED#", "#UNDEFINED#", "cabinet"],
      ["storage", "*", "#UNDEFINED#", "#UNDEFINED#", "storage"],
      ["tape drive", "*", "#UNDEFINED#", "#UNDEFINED#", "tapeDrive"],
      ["tape library", "*", "#UNDEFINED#", "#UNDEFINED#", "tapeLibrary"],
      ["server", "*", "Virtual Guest", "HP-IVM", "hpGuest"],
      ["server", "*", "Server for Virtual Guest", "HP-IVM", "hpHost"],
      ["server", "*", "Virtual Guest", "Solaris Zones", "solarisZone"],
      ["farm", "*", "Farm", "Solaris Zones", "solarisHost"],
      ["san switch", "*", "#UNDEFINED#", "#UNDEFINED#", "sanSwitch"],
      ["server", "OS/400", "Server for Virtual Guest", "LPAR", "as400"],
      ["server", "OS/400", "Server for Secure Resource Partition", "LPAR", "as400"],
      ["mainframe", "*", "Server for Secure Resource Partition", "LPAR", "mainframe"],
      ["server", "z/OS", "Secure Resource Partition", "LPAR", "mainframeLpar"],
      ["server", "Other", "Secure Resource Partition", "LPAR", "unknownIbmLpar"],
      ["server", "z/OS", "#UNDEFINED#", "#UNDEFINED#", "mainframeLpar"],
      ["firewall", "*", "#UNDEFINED#", "#UNDEFINED#", "firewall"]      
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
  
  def ESLdata.CQLCreate(sys, index)
    query_string = "CREATE (n#{index} { "
    sys.each do |key,value|
      query_string += "#{key} : '#{value}', "
    end
    query_string.chomp!(', ')
    query_string += "})"
  end

  def ESLdata.CQLcreateNodes(sys,index)
    fields = [
      "full_node_name",
      #"arpa_domain",
      "availability",
      #"cluster_architecture",
      "cluster_technology",
      #"contract_server_size",
      "contract_service_level",
      "coverage",
      "domain",
      "environment",
      "impact",
      #{}"ir_rules",
      #{}"management_region",
      "number_of_cores_per_cpu",
      "number_of_logical_cpus",
      "number_of_physical_cpus",
      "os_class",
      "os_language",
      "os_version",
      "system_status",
      "system_type",
      "virtualization_role",
      "virtualization_technology",
      #{}"business_area",
      #{}"business_name",
      "sub_business_name",
      "floor_spceslot",
      #{}"dc_name",
      "is_virtual",
      "billable_yn",
      "customer_classification",
      #{}"category",
      #{}"security_class",
      #{}"time_zone",
      "technical_owner",
      "contract_system_status",
      #{}"billing_start",
      #{}"billing_end",
      "service_level",
      "assyst_queue_name",
      "installed_memory"
      #"transformation_status",
      #"create_date",
      #"decommission_date",
      #"project_number",
      #"oa1_change_number",
      #"oa1_change_date",
      #"oa2_change_number",
      #"dual_running"
    ]
    query_string = "CREATE (n#{index} { "
    fields.each do |field|
      query_string += "#{field.to_sym}: '#{sys[field.to_sym]}', "
    end
    query_string.chomp!(', ')
    query_string += " })"
  end

  def ESLdata.CQLsetProperties(sys, index)
    query_string = "MATCH n#{index} " +
                   "WHERE HAS (n#{index}.full_node_name) " +
                   "AND n#{index}.full_node_name='#{sys[:full_node_name]}' "

    sys.each do |key,value|
      if value != "#UNDEFINED#" then 
        query_string += "SET n#{index}.#{key} = '#{value}' "
      end
    end
    query_string += "RETURN n#{index};"
  end

  def ESLdata.CQLCreateSimple(sys, index)
    query_string = "CREATE (n#{index} { full_node_name: '#{sys[:full_node_name]}' })"
  end

  def ESLdata.constructQuery(sys, type, index)

    query_string = "CREATE (n#{index}:#{type} { name : '#{sys[:full_node_name]}' "

    case type
    when "powervmGuest", "vmwareGuest", "windowsPhysicalServer", 
      "linuxPhysicalServer", "aixPhysicalServer"
      query_string += ", os_version : '#{sys[:os_version]}' "
      query_string += ", os_class: '#{sys[:os_class]}' "
      query_string += ", contract_service_level: '#{sys[:contract_service_level]}' "
      query_string += ", system_status: '#{sys[:system_status]}' "
    end

    query_string += "}) "
    if sys[:system_type] != "#UNDEFINED#"
      query_string += "SET n#{index} :#{sys[:system_type]};"
    end
    #puts query_string
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
    if ESLdata.classify_server(server) == "VMWare_guest" then
      return true
    else
      return false
    end
  end

  def ESLdata.isVMHost(server)
    if ESLdata.classify_server(server) == "VMWare_host" then
      return true
    else
      return false
    end
  end

  def ESLdata.isPowerVMGuest(server)
    if ESLdata.classify_server(server) == "PowerVM_guest" then
      return true
    else
      return false
    end
  end

  def ESLdata.isPowerVMHost(server)
    if ESLdata.classify_server(server) == "PowerVM_host" then
      return true
    else
      return false
    end
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
    # puts "Loading Relation data"
    CSV.foreach("data/esl_aviva_9_sys_rel.csv", {:headers => true, :header_converters => :symbol, :col_sep => "|"}) do |row|
      rels[count] = row
      rels[count].each do |field, value|
        if value.nil? then
          rels[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
    # puts "Loaded #{count} rows from relationship data"
  end

  def ESLdata.load_solutions(sols)
    count = 0
    #puts "Loading SOlution data"
    CSV.foreach("data/esl_aviva_3_sol.csv", {:headers => true, :header_converters => :symbol, :col_sep => "|"}) do |row|
      sols[count] = row
      sols[count].each do |field, value|
        if value.nil? then
          sols[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
    #puts "Loaded #{count} rows from Solution data"
  end  
  def ESLdata.load_business_solutions(sols)
    count = 0
    #puts "Loading SOlution data"
    CSV.foreach("data/esl_aviva_11_bus_sol.csv", {:headers => true, :header_converters => :symbol, :col_sep => "|"}) do |row|
      sols[count] = row
      sols[count].each do |field, value|
        if value.nil? then
          sols[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
    #puts "Loaded #{count} rows from Solution data"
  end  

  def ESLdata.load_instances(instances)
    count = 0
    #puts "Loading Instance data"
    CSV.foreach("data/esl_aviva_10_inst_sol.csv", {:headers => true, :header_converters => :symbol, :col_sep => "|"}) do |row|
      instances[count] = row
      instances[count].each do |field, value|
        if value.nil? then
          instances[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
    #puts "Loaded #{count} rows from Instance data"
  end   

  def ESLdata.load_assets(assets)
    count = 0
    source = "data/esl_aviva_8_asset.csv"
    opts = {:headers => true, :header_converters => :symbol, :col_sep => "|"}
    CSV.foreach(source, opts) do |row|
      assets[count] = row
      assets[count].each do |field, value|
        if value.nil? then
          assets[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
  end

  def ESLdata.load_doms(items, fileName)
    count = 0
    source = "data/" + fileName
    puts "opening #{source}"
    opts = {:headers => true, :header_converters => :symbol}
    CSV.foreach(source, opts) do |row|
      items[count] = row
      items[count].each do |field, value|
        if value.nil? then
          items[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
  end

  def ESLdata.del_deinstalled(servers)
    servers.delete_if {|server| server[:system_status] == "deinstalled"}
  end

  def ESLdata.find_vmguests(servers)
    vmguests = Array.new
    servers.each do |server|
      if ESLdata.isVMGuest(server) then
        vmguests << server
      end
    end
    vmguests
  end

  def ESLdata.find_vmhosts(servers)
    vmhosts = Array.new
    servers.each do |server|
      if ESLdata.isVMhost(server) then
        vmhosts << server
      end
    end
    vmhosts
  end
  

  def ESLdata.load_BPOS_exclusions(items)
    count = 0
    source = "data/BPOS-exclusions-oct-2013.csv"
    opts = {:headers => true, :header_converters => :symbol}
    CSV.foreach(source, opts) do |row|
      items[count] = row
      items[count].each do |field, value|
        if value.nil? then
          items[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
  end

  def ESLdata.load_DIST(items)
    count = 0
    source = "data/DIST-corrected-oct-2013.csv"
    opts = {:headers => true, :header_converters => :symbol}
    CSV.foreach(source, opts) do |row|
      items[count] = row
      items[count].each do |field, value|
        if value.nil? then
          items[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
  end

  def ESLdata.load_MID_exclusions(items)
    count = 0
    source = "data/MID-exclusions-oct-2013.csv"
    opts = {:headers => true, :header_converters => :symbol}
    CSV.foreach(source, opts) do |row|
      items[count] = row
      items[count].each do |field, value|
        if value.nil? then
          items[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
  end

  def ESLdata.load_LINUX_inclusions(items)
    count = 0
    source = "data/LINUX-inclusions-oct-2013.csv"
    opts = {:headers => true, :header_converters => :symbol}
    CSV.foreach(source, opts) do |row|
      items[count] = row
      items[count].each do |field, value|
        if value.nil? then
          items[count][field] = "#UNDEFINED#"
        end
      end
      count += 1
    end
  end

end