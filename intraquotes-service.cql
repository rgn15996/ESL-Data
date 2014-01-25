MERGE (service:avivaService {name: 'intraquotes'});
MERGE (app:avivaApplication {name: 'active directory [prd]'});
MERGE (app:avivaApplication {name: 'capes [prd]'});
MERGE (app:avivaApplication {name: 'capes db [prd]'});
MERGE (app:avivaApplication {name: 'cffe [prd]'});
MERGE (app:avivaApplication {name: 'contract gateway [prd]'});
MERGE (app:avivaApplication {name: 'ifa database [prd]'});
MERGE (app:avivaApplication {name: 'intraquotes [prd]'});
MERGE (app:avivaApplication {name: 'life 24x7 cics (nuc1) [prd]'});
MERGE (app:avivaApplication {name: 'unisure [prd]'});

MATCH srv:avivaService, app:avivaApplication
WHERE srv.name = 'intraquotes' 
AND app.name IN ['active directory [prd]','capes [prd]','capes db [prd]','cffe [prd]','contract gateway [prd]','ifa database [prd]','ifa database [prd]','intraquotes [prd]','life 24x7 cics (nuc1) [prd]','unisure [prd]']
CREATE UNIQUE app-[rel:IS_COMPONENT_OF]->srv
RETURN rel;

MATCH sol:solution, app:avivaApplication
WHERE sol.name =~ 'active directory dc prd hp[bsg]-fmo' AND
app.name = 'active directory [prd]'
CREATE UNIQUE app<-[r:IS_COMPONENT_OF]-sol
RETURN app.name, sol.name;

MATCH sol:solution, app:avivaApplication
WHERE sol.name =~ 'capes prd.*' AND
app.name = 'capes [prd]'
CREATE UNIQUE app<-[r:IS_COMPONENT_OF]-sol
RETURN app.name, sol.name;