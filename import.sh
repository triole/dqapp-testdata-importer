#!/bin/bash
# scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IFS=$'\n'
fol="${pwd}"
if [[ -n "${1}" ]]; then
    fol="${1}"
fi

conf="${fol}/_conf.toml"

psql="psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}"
conf_delimiter=$(stoml ${conf} "delimiter")
conf_schema=$(stoml ${conf} "schema")
inject_settings="DELIMITER '${conf_delimiter}' CSV HEADER;"

function run_cmd() {
    cmd="${1}"
    echo -e "\033[0;93m${cmd}\033[0m"
    eval "${1}"
}

function table_name() {
    echo "${1}" | grep -Po "[^/]+$" | grep -Po ".*(?=\.)"
}

# CREATE TABLE applause_dr3.archive
function add_headers() {
    fil="${1}"
    echo -e "\n$fil"
    headers=($(cat "${fil}" | head -n 1 | tr "${conf_delimiter}" "\n"))
    for el in "${headers[@]}"; do
        datatype=$(stoml "${conf}" "datatypes.${el}")
        if [[ -z "${datatype}" ]]; then
            datatype="varchar NULL"
        fi
        cmd+="${el} ${datatype},"
    done
}

function create_table() {
    fil="${1}"
    cmd="${psql} -c 'CREATE TABLE ${conf_schema}.$(table_name ${fil}) ("
    add_headers "${fil}"
    cmd=$(echo ${cmd%?})
    cmd+=");'"
    run_cmd "${cmd}"
}

function inject_data() {
    file="$(pwd)/${1}"
    tn="${conf_schema}.$(table_name ${fil})"
    run_cmd "${psql} -c \"COPY ${tn} FROM '${file}' ${inject_settings}\" "
}

# main
# add schema
run_cmd "${psql} -c \"CREATE SCHEMA ${conf_schema};\""

# create table
arr=($(find "${fol}" -mindepth 1 -maxdepth 1 -type f -regex ".*\.csv$" | sort))
for file in "${arr[@]}"; do
    create_table "${file}"
    inject_data "${file}"
done
