export ZETA_HOME=$HOME/opt/zeta
export ZARK_HOME=$HOME/opt/zark
export ZIXAPP_HOME=$HOME/workspace/zixapp
export PERL5LIB=$ZETA_HOME/lib:$ZARK_HOME/lib:$ZIXAPP_HOME/lib
export PLUGIN_PATH=$ZIXAPP_HOME/plugin
export PATH=$ZIXAPP_HOME/bin:$ZIXAPP_HOME/sbin:$ZETA_HOME/bin:$PATH
export ZAPP_DEBUG=1;

export DB_NAME=zdb_dev
export DB_USER=db2inst
export DB_PASS=db2inst
export DB_SCHEMA=db2inst
alias dbc='db2 connect to $DB_NAME user $DB_USER using $DB_PASS'

alias cdl='cd $ZIXAPP_HOME/log';
alias cdd='cd $ZIXAPP_HOME/data';
alias cdlb='cd $ZIXAPP_HOME/lib/ZAPP';
alias cdle='cd $ZIXAPP_HOME/libexec';
alias cdb='cd $ZIXAPP_HOME/bin';
alias cdsb='cd $ZIXAPP_HOME/sbin';
alias cdc='cd $ZIXAPP_HOME/conf';
alias cde='cd $ZIXAPP_HOME/etc';
alias cdt='cd $ZIXAPP_HOME/t';
alias cdh='cd $ZIXAPP_HOME';
alias cdtb='cd $ZIXAPP_HOME/sql/table';



