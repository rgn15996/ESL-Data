MATCH n
WHERE n.system_type = 'server'
SET n:server
RETURN "Labeled ", count(n), " servers";

MATCH n
WHERE n.system_type = 'farm'
SET n:farm
RETURN "Labeled ", count(n), " farms";

MATCH n
WHERE n.system_type = 'mainframe'
SET n:mainframe
RETURN "Labeled ", count(n), " mainframes";

MATCH n
WHERE n.system_type = 'cluster'
SET n:cluster
RETURN "Labeled ", count(n), " clusters";

MATCH n
WHERE n.system_type = 'cluster node'
SET n:clusterNode
RETURN "Labeled ", count(n), " cluster nodes";

MATCH n
WHERE n.system_type = 'cluster package'
SET n:clusterPackage
RETURN "Labeled ", count(n), " cluster packages";

MATCH n
WHERE n.system_type = 'cabinet'
SET n:cabinet
RETURN "Labeled ", count(n), " cabinets";

MATCH n
WHERE n.system_type = 'storage'
SET n:storage
RETURN "Labeled ", count(n), " storage";

MATCH n
WHERE n.system_type = 'tape drive'
SET n:tapeDrive
RETURN "Labeled ", count(n), " tape drive";

MATCH n
WHERE n.system_type = 'tape library'
SET n:tapeLibrary
RETURN "Labeled ", count(n), " tape libraries";

MATCH n
WHERE n.system_type = 'san switch'
SET n:sanSwitch
RETURN "Labeled ", count(n), " SAN Switches";

MATCH (n:server) 
WHERE n.virtualization_role = 'Virtual Guest' 
AND n.virtualization_technology = 'VMWare'
SET n:vmwareGuest
RETURN n.full_node_name;

MATCH (n:ci) 
WHERE n.virtualization_role = 'Server for Virtual Guest' 
AND n.virtualization_technology = 'VMWare'
SET n:vmwareHost
RETURN n.full_node_name;

MATCH (n:farm)
WHERE n.os_class = 'VMWare' 
AND n.virtualization_role = 'Farm' 
AND n.virtualization_technology = 'VMWare'
SET n:vmwareCluster
RETURN n.full_node_name;


MATCH (n)
WHERE n.os_class = 'AIX' 
AND n.virtualization_role = 'Secure Resource Partition'
AND n.virtualization_technology = 'LPAR'
SET n:powervmGuest
RETURN n.full_node_name, n.system_type;


MATCH (n:server)
WHERE (n.os_class = 'Other' OR n.os_class = 'AIX') 
AND n.virtualization_role = 'Server for Secure Resource Partition'
AND n.virtualization_technology = 'LPAR'
AND n.customer_classification <> 'HP SUPERDOME'
SET n:powervmHost
RETURN n.full_node_name, n.system_type;

MATCH (n:server)
WHERE n.os_class = 'AIX'
AND n.virtualization_role = '#UNDEFINED#'
AND n.virtualization_technology = '#UNDEFINED#'
SET n:aixPhysicalServer
RETURN n.full_node_name, n.system_type, labels(n);

MATCH (n:clusterNode)
WHERE n.os_class = 'AIX'
AND n.virtualization_role = '#UNDEFINED#'
AND n.virtualization_technology = '#UNDEFINED#'
SET n:aixPhysicalServer
RETURN n.full_node_name, n.system_type, labels(n);

MATCH (n:server)
WHERE n.os_class = 'Windows' 
AND n.virtualization_role = '#UNDEFINED#'
AND n.virtualization_technology = '#UNDEFINED#'
SET n:windowsPhysicalServer
RETURN n.full_node_name, n.system_type;


MATCH (n:server)
WHERE n.os_class = 'Linux' 
AND n.virtualization_role = '#UNDEFINED#'
AND n.virtualization_technology = '#UNDEFINED#'
SET n:linuxPhysicalServer
RETURN n.full_node_name, n.system_type;


MATCH (n:server)
WHERE n.os_class = 'HP-UX' 
AND n.virtualization_role = '#UNDEFINED#'
AND n.virtualization_technology = '#UNDEFINED#'
SET n:hpuxPhysicalServer
RETURN n.full_node_name, n.system_type;


MATCH (n:server)
WHERE n.os_class = 'Other' 
AND n.virtualization_role = 'Secure Resource Partition'
AND n.virtualization_technology = 'LPAR'
AND n.sub_business_name = 'Midrange'
SET n:powervmGuest
SET n:strange
RETURN n.full_node_name, n.system_type, n.sub_business_name;

MATCH (n:server)
WHERE n.os_class = 'Other' 
AND n.virtualization_role = 'Secure Resource Partition'
AND n.virtualization_technology = 'LPAR'
AND n.sub_business_name = 'Mainframe'
SET n:mainframeLpar
SET n:strange
RETURN n.full_node_name, n.system_type, n.sub_business_name;

MATCH n
WHERE n.os_class = 'z/OS'
AND n.virtualization_role = 'Server for Secure Resource Partition'
AND n.virtualization_technology = 'LPAR' 
AND n.sub_business_name = 'Mainframe'
SET n:mainframe
RETURN n.full_node_name, n.system_type;

MATCH n
WHERE n.os_class = 'z/OS'
AND n.virtualization_role = 'Secure Resource Partition'
AND n.virtualization_technology = 'LPAR' 
AND n.sub_business_name='Mainframe'
SET n:mainframeLpar
RETURN n.full_node_name, n.system_type;