match (s:solution)--(x)
return s.name as Solution, count(x) as Number_of_servers, collect(distinct(x.os_class)) as OS_Types;