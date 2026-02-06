#!/bin/bash

INPUT=""
OUTPUT=""
FILTER_ARG=""

while getopts "i:o:f:" opt; do
  case $opt in
    i) INPUT="$OPTARG" ;;
    o) OUTPUT="$OPTARG" ;;
    f) FILTER_ARG="$OPTARG" ;;
    *) echo "Usage: $0 -i log -o csv [-f key=val]"; exit 1 ;;
  esac
done

if [[ -z "$INPUT" || -z "$OUTPUT" ]]; then
    echo "Error: Need input/output."
    exit 1
fi

DIR=$(dirname "$OUTPUT")
FILE=$(basename "$OUTPUT")
REPO_AUTH_URL="https://${GIT_USERNAME}:${GIT_TOKEN}@${GIT_REPO_URL}.git"

if [ ! -d "$DIR/.git" ]; then
    echo "Cloning repo..."
    mkdir -p "$DIR"
    git clone "$REPO_AUTH_URL" "$DIR" || exit 1
fi

echo "Parsing $INPUT (Filter: ${FILTER_ARG:-None})..."

gawk -v OFS=';' -v filter_str="$FILTER_ARG" '
BEGIN {
    FPAT = "(\"[^\"]+\")|(\\[[^\\]]+\\])|([^ ]+)"
    print "ip;time;method;url;status;bytes;referer;user_agent;request_time;upstream;upstream_time"
    
    if (filter_str != "") {
        split(filter_str, f, "=")
        f_key = f[1]
        f_val = f[2]
    }
}
{
    ip = $1; time = $4; request = $5; status = $6; bytes = $7
    referer = $8; ua = $9; req_time = $11; upstream = $12; ups_time = $16

    gsub(/^\[|\]$/, "", time)
    gsub(/^"|"$/, "", referer); gsub(/^"|"$/, "", ua); gsub(/^"|"$/, "", request)
    split(request, parts, " "); method = parts[1]; url = parts[2]
    gsub(/"/, "\"\"", ua); gsub(/"/, "\"\"", referer); gsub(/"/, "\"\"", url)

    skip = 0
    if (f_key != "") {
        if (f_key == "ip" && ip != f_val) skip=1
        else if (f_key == "time" && index(time, f_val) == 0) skip=1
        else if (f_key == "method" && method != f_val) skip=1
        else if (f_key == "url" && index(url, f_val) == 0) skip=1
        else if (f_key == "status" && status != f_val) skip=1
        else if (f_key == "bytes" && bytes != f_val) skip=1
        else if (f_key == "referer" && index(referer, f_val) == 0) skip=1
        else if (f_key == "user_agent" && index(ua, f_val) == 0) skip=1
        else if (f_key == "request_time" && req_time != f_val) skip=1
        else if (f_key == "upstream" && index(upstream, f_val) == 0) skip=1
        else if (f_key == "upstream_time" && ups_time != f_val) skip=1
    }

    if (skip == 0) {
        print ip, time, method, "\"" url "\"", status, bytes, "\"" referer "\"", "\"" ua "\"", req_time, upstream, ups_time
    }
}' "$INPUT" > "$OUTPUT"

echo "Parsed."

cd "$DIR" || exit
git config user.name "${GIT_USER_NAME}"
git config user.email "${GIT_USER_EMAIL}"
git add "$FILE"

if ! git diff --cached --quiet; then
    git commit -m "Auto: $FILE (Filter: ${FILTER_ARG:-All})" -q
    git push origin "${GIT_BRANCH}"
    echo "Pushed."
else
    echo "No changes."
fi
