KEY=eyJrIjoiQXZKSE9vM043U1RyNFFtd1NjY0NsTHRSOGl3S0FaNlAiLCJuIjoiRGFzaGJvYXJkX0V4cG9ydGVyIiwiaWQiOjF9
HOST="http://192.168.0.20:3000"
GRAFANA_DIR="/etc/grafana/"
UPLOAD_DIR="/etc/grafana/dashboards"
EXPORT_DIR="/tmp/dashboards"

if [[ -d "$EXPORT_DIR" ]] ; then
    rm -rf "$EXPORT_DIR"
fi

mkdir "$EXPORT_DIR"

for dash in $(curl -sSL -k -H "Authorization: Bearer $KEY" $HOST/api/search\?query\=\& | jq '.' |grep -i uri|awk -F '"uri": "' '{ print $2 }'|awk -F '"' '{print $1 }'); do
    curl -sSL -k -H "Authorization: Bearer ${KEY}" "${HOST}/api/dashboards/${dash}" > "$EXPORT_DIR"/$(echo ${dash}|sed 's,db/,,g').json
done

for file in $(ls "$EXPORT_DIR"); do
    cp "${EXPORT_FILE}/${file}" "${UPLOAD_DIR}/$(file)"
done

rm -rf "$EXPORT_DIR"

cd "$GRAFANA_DIR"

git add *

git commit -m "Automatically commited by grafana_dashboard_exporter.sh"

git push grafana master
