xquery version "3.0";

declare namespace sql="http://exist-db.org/xquery/sql";

let $connection := sql:get-connection("com.mysql.jdbc.Driver", "jdbc:mysql://localhost:3306", "root", "H3ts-SQL-HRA")

let $db := sql:execute($connection, "use chinese_comics;", fn:true())

let $table-name := "texts"

let $rows := sql:execute($connection, "select * from " || $table-name || ";", fn:true())//sql:row[data(.) != '']

return
    xmldb:store("/data/chinese-comics", $table-name || ".xml",
        element {$table-name} {
            for $row in $rows
            
            return element record {
                for $field in $row/*
                
                return element {$field/local-name()} {$field/text()}
            }
        }
    )
    