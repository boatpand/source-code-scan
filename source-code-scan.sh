#!/bin/bash

filename="list.txt"

timestamp=$(date +%d%m%Y-%H%M%S)
mkdir ~/Desktop/result-code-scan-$timestamp
cd ~/Desktop/result-code-scan-$timestamp && touch report-code-$timestamp.csv
echo "name,cri,high,medium,low" > report-code-$timestamp.csv
cd -

# for loop list file
while IFS= read -r repo || [ -n "$repo" ]
do
    cd ~/Desktop/source-code-scan/$repo
    # snyk code test --json > $repo.json
    # snyk-to-html -i $repo.json -o results-code-scan-$repo-$timestamp.html
    snyk code test --json | snyk-to-html -o results-code-scan-$repo-$timestamp.html

    mv *$timestamp.html ~/Desktop/result-code-scan-$timestamp
    cd ~/Desktop/result-code-scan-$timestamp

    critical=$(cat results-code-scan-$repo-$timestamp.html | grep "critical issues" | sed -e 's/.*<strong>\(.*\)<\/strong>.*/\1/')
    if [ -z "$critical" ]; then critical=0 ; fi

    high=$(cat results-code-scan-$repo-$timestamp.html | grep "high issues" | sed -e 's/.*<strong>\(.*\)<\/strong>.*/\1/')
    if [ -z "$high" ]; then high=0 ; fi

    medium=$(cat results-code-scan-$repo-$timestamp.html | grep "medium issues" | sed -e 's/.*<strong>\(.*\)<\/strong>.*/\1/')
    if [ -z "$medium" ]; then medium=0 ; fi

    low=$(cat results-code-scan-$repo-$timestamp.html | grep "low issues" | sed -e 's/.*<strong>\(.*\)<\/strong>.*/\1/')
    if [ -z "$low" ]; then low=0 ; fi

    echo "$repo,$critical,$high,$medium,$low" >> report-code-$timestamp.csv

    cd ~/Desktop/source-code-scan

done < "$filename"
