xquery version "3.1";

declare namespace sql="http://exist-db.org/xquery/sql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";

let $output-collection := "/data/chinese-comics/json"

let $connection := sql:get-connection("com.mysql.jdbc.Driver", "jdbc:mysql://localhost:3306", "root", "H3ts-SQL-HRA")

let $db := sql:execute($connection, "use chinese_comics;", fn:true())

let $roles := (" Original_Author_Chinese", "Original_Author_Transcription", "Original_Author_English", "Editor_Chinese", "Editor_Transcription", "Text_Chinese", "Text_English", "Script_Editing_Chinese", "Script_Editing_English", "Art_editor_Chinese", "Art_editor_English", "Abridgement_Editor_Chinese", "Abridgement_Editor_English", "Translator_Chinese", "Translator_English", "Drawings_Chinese", "Drawings_English", "Drawing_Copy_Chinese", "Drawing_Copy_English", "Image_Editing_Chinese", "Image_Editing_English", "Photographer_Chinese", "Photographer_English", "Responsible_Editor_Chinese", "Responsible_Editor_English", "Responsible_Proofreaders_Chinese", "Responsible_Proofreaders_English", "Technical_Editor_Chinese", "Technical_Editor_English", "Technical_Planning_Chinese", "Technical_Planning_English", "Distributer_Chinese", "Distributer_English", "Writer_Chinese", "Writer_English", "Graphic_Design_Chinese", "Graphic_Design_English", "Cover_Artist_Chinese", "Cover_Artist_English", "Cover_Design_Chinese", "Cover_Design_English", "Cover_Production_Chinese", "Cover_Production_English", "Cover_Calligraphy_Chinese", "Cover_Calligraphy_English", "Title_Illustration_Chinese", "Title_Illustration_English")

return
    for $role in $roles
    
    return
        let $entities := string-join(sql:execute($connection, "select distinct "|| $role || " from books;", true())/*/*[data(.) != '']/text(), ",")
        let $entities := tokenize($entities, ",")
        let $entities :=
            for $name in $entities
            
            return normalize-space($name)
        let $entities := distinct-values($entities)
        let $entities := 
            for $entity in $entities
            let $id := sql:execute($connection, "select person_id from persons_variants where name = &quot;" || replace($entity, "&quot;", "\\&quot;") || "&quot;;", true())/data(.)
            
            return
                if ($id != '')
                then "{id: " || $id || ", &apos;" || $entity || "&apos;}"
                else ()
                
        return
            if ($entities != '')
            then
                xmldb:store($output-collection, $role || ".json", "[" || string-join($entities, ", ") || "]")
            else ()
