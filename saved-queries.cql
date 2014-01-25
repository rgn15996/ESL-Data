//How many VMs on IBM Power Series Hosts
match (a:powervmHost)-[:IS_HOSTED_ON]-(b) return a.full_node_name, count(b) order by count(b) descending;

//Which VMs are hosted on burns1
match (a)-[:IS_HOSTED_ON]-(b) where b.full_node_name =~ "burns1.via.novonet" return a.full_node_name order by a.full_node_name;

match (a:powervmHost)-[]-(b:powervmGuest) return a.full_node_name, count(b) order by count(b) descending;

//How many AIX LPARs for each HSN
MATCH (a:powervmGuest)-[r]-(b:solution) RETURN distinct b.name as Name, count(a) as Count order by count(a) descending;

//Number of Components per HSN
MATCH (a)-[:IS_COMPONENT_OF]-(b:solution) RETURN distinct b.name as Name, count(a) as Count order by count(a) descending LIMIT 100;

//Locations and CI counts
MATCH (a) RETURN distinct a.dc_name as Location, count(a) as Count order by count(a) descending;

//Physical Linux by OS Version
MATCH (n)
WHERE n.os_class = 'Linux' 
AND n.virtualization_role = '#UNDEFINED#'
AND n.virtualization_technology = '#UNDEFINED#'
RETURN distinct n.os_version, n.system_type, count (n.os_version);

//OS Version Count sort descending
match (a:server) return distinct a.os_version, count(a.os_version) order by count(a.os_version) descending;

match (x)-[*1..2]-(s:solution) where s.name = "aviva uk:ukdi motor call centre web q&b prd hps" return x,s;

//How many servers for each HSN
MATCH (a)-[r]-(b:solution) RETURN distinct b.name as Name, count(a) as Count order by count(a) descending LIMIT 100;

// OS Class breakdown by mumber
match (x:server)
RETURN DISTINCT x.os_class as OS, count(x.os_class) as Count;

// What makes up Unisure by OS
match (x)-[:IS_COMPONENT_OF]->(sol:solution)
WHERE sol.name =~ ".*unisure.*"
RETURN DISTINCT x.os_class as OS, count(x.os_class) as Count;

// What makes up Unisure by OS Version
match (x)-[:IS_COMPONENT_OF]->(sol:solution)
WHERE sol.name =~ ".*unisure.*"
RETURN DISTINCT x.os_version as OS, count(x.os_version) as Count;

//Which HSNs do Linux systems belong to?
MATCH (a)-[r]-(b:solution) WHERE a.os_class =~ ".*inux.*" 
RETURN DISTINCT a.full_node_name as Name, a.os_version as Version, LABELS(a)as Type, COLLECT(b.name)as HSN ORDER BY a.full_node_name ;

// Get OS Types in a Solution
match (s:solution)--(x) where s.name =~ ".*image.*" return s.name as Solution, count(x) as Number_of_servers, collect(distinct(x.os_class)) as OS_Types;

// Get OS Types in a Solutions containing pattern
match (s:solution)--(x) where s.name =~ ".*image.*" return Collect(distinct(s.name)) as Solution, count(x) as Number_of_servers, collect(distinct(x.os_class)) as OS_Types;

// Non billed AIX Physical
MATCH (x:aixPhysicalServer)-[:IS_COMPONENT_OF]->(s:solution)
WHERE NOT (x:mrLoS) AND x.system_status = "in production"
RETURN x.full_node_name, labels(x), COLLECT(s.name);

// Non billed AIX Virtual
MATCH (x:powervmGuest)-[:IS_COMPONENT_OF]->(s:solution)
WHERE NOT (x:mrLoS) AND x.system_status = "in production"
RETURN x.full_node_name, labels(x), COLLECT(s.name);