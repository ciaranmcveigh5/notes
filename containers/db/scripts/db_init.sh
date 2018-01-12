mysql  -u root -p$MYSQL_ROOT_PASSWORD <<EOF
create database test;
use test;

CREATE TABLE users
(
id INTEGER AUTO_INCREMENT,
first_name TEXT,
last_name TEXT,
policy_id TEXT,
PRIMARY KEY (id)
);
EOF