#!/bin/bash

db2 connect to zdb_dev;

SMS="managed by system";
STMP_TBSP="temporary tablespace";
UTMP_TBSP="user temporary tablespace";
LARG_TBSP="tablespace";
db2 "create $LARG_TBSP tbs_dat pagesize 32k $SMS  using('/home/db2inst/tbs/dat')  bufferpool bp32k";
db2 "create $LARG_TBSP tbs_idx pagesize 32k $SMS  using('/home/db2inst/tbs/idx')  bufferpool bp32k";
db2 "create $STMP_TBSP tbs_tmp pagesize 32k $SMS  using('/home/db2inst/tbs/tmp')  bufferpool bp32k";
db2 "create $UTMP_TBSP tbs_utmp pagesize 32k $SMS using('/home/db2inst/tbs/utmp') bufferpool bp32k";
