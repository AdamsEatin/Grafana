KEY=
HOST="http://192.168.0.20:3000"
GRAFANA_DIR="/etc/grafana/"
UPLOAD_DIR="/etc/grafana/dashboards"
EXPORT_DIR="/tmp/dashboards"

if [[ -d "$EXPORT_DIR" ]] ; then
    rm -rf "$EXPORT_DIR"
fi

mkdir "$EXPORT_DIR"

for dash in $(curl -sSL -k -H "Authorization: Bearer $KEY" $HOST/api/search\?query\=\& | jq '.' |grep -i uri|awk -F '"uri": "' '{ print $2 }'|awk -F '"' '{print $1 }'); do
    curl -sSL -k -H "Authorization: Bearer ${KEY}" "${HOST}/api/dashboards/${dash}" | jq '.dashboard.id = null' | jq '.dashboard' > "$EXPORT_DIR"/$(echo ${dash}|sed 's,db/,,g').json
done

mv -f "${EXPORT_DIR}"/* "${UPLOAD_DIR}"

rm -rf "$EXPORT_DIR"

cd "$GRAFANA_DIR"

git add *

git commit -m "Automatically commited by grafana_dashboard_exporter.sh"

git push grafana master
