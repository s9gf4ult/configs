#! /bin/zsh

for file in ~/.mozilla/**/*;do
    if file $file | grep -e "SQLite\ 3\.x\ database";then
        sqlite3 $file <<EOF
vacuum;
reindex;
.exit
EOF
    fi
done
