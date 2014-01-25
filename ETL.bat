call loadfile label_solutions.cql
call loadfile create_indices.cql
call loadfile set-labels.cql
ruby gen-relations.rb > rels.cql
call loadfile rels.cql
del rels.cql
ruby gen_sol_relations.rb > sols.cql
call loadfile sols.cql
del sols.cql