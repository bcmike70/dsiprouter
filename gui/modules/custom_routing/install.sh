#!/usr/bin/env bash

# Debug this script if in debug mode
(( $DEBUG == 1 )) && set -x

# ENABLED=1 --> install, ENABLED=0 --> do nothing, ENABLED=-1 uninstall
ENABLED=1

# Import dsip_lib utility / shared functions if not already
if [[ "$DSIP_LIB_IMPORTED" != "1" ]]; then
    . ${DSIP_PROJECT_DIR}/dsiprouter/dsip_lib.sh
fi

function installSQL {
    local TABLES=(dr_custom_rules locale_lookup)

    printwarn "Adding/Replacing the tables needed for Custom Routing  within dSIPRouter..."

    # Check to see if table exists
    mysql -s -N --user="$MYSQL_ROOT_USERNAME" --password="$MYSQL_ROOT_PASSWORD" --host="${KAM_DB_HOST}" --port="${KAM_DB_PORT}" $KAM_DB_NAME \
        -e "select count(*) from ${TABLES[0]} limit 1" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        printwarn "The dSIPRouter tables ${TABLES[@]} already exists. Merging table data"
        (cat ${DSIP_PROJECT_DIR}/gui/modules/custom_routing/custom_routing.sql;
            mysqldump --single-transaction --skip-triggers --skip-add-drop-table --no-create-info --insert-ignore \
                --user="$MYSQL_ROOT_USERNAME" --password="$MYSQL_ROOT_PASSWORD" --host="${KAM_DB_HOST}" --port="${KAM_DB_PORT}" ${KAM_DB_NAME} ${TABLES[@]};
        ) | mysql --user="$MYSQL_ROOT_USERNAME" --password="$MYSQL_ROOT_PASSWORD" --host="${KAM_DB_HOST}" --port="${KAM_DB_PORT}" $KAM_DB_NAME
    else
        echo -e "Installing schema for custom routing"
        mysql -sN --user="$MYSQL_ROOT_USERNAME" --password="$MYSQL_ROOT_PASSWORD" --host="${KAM_DB_HOST}" --port="${KAM_DB_PORT}" $KAM_DB_NAME \
            < ${DSIP_PROJECT_DIR}/gui/modules/custom_routing/custom_routing.sql
    fi
}

function install {
    installSQL
    printdbg "Custom Routing module installed"
}

function uninstall {
    printdbg "Custom Routing module uninstalled"
}

function main {
    if [[ ${ENABLED} -eq 1 ]]; then
        install
    elif [[ ${ENABLED} -eq -1 ]]; then
        uninstall
    else
        exit 0
    fi
}

main
