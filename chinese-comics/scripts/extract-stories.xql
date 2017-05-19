xquery version "3.0";

let $path := "/data/chinese-comics/"

let $raw-stories := doc($path || "stories.xml")
let $duplicate-stories := xmldb:store($path || "temp/", "processed-stories.xml", $raw-stories)
let $processed-stories := doc($path || "temp/processed-stories.xml")/*/*

let $story_notes-file := doc($path || "story_notes.xml")
let $story_keywords-file := doc($path || "story_keywords.xml")
let $keywords-file := doc($path || "keywords.xml")
let $texts-file := doc($path || "texts.xml")
let $genders-file := doc($path || "genders.xml")
let $story_roles-file := doc($path || "story_roles.xml")
let $persons_roles-file := doc($path || "persons_roles.xml")
let $persons-file := doc($path || "persons.xml")
let $persons_variants-file := doc($path || "persons_variants.xml")
let $story_parts-file := doc($path || "story_parts.xml")
let $books-file := doc($path || "books.xml")
let $book_parts-file := doc($path || "book_parts.xml")

let $process-stories :=
    for $story in $processed-stories
    let $id := $story/id
    let $notes := $story_notes-file//record[story_id = $id]/note
    let $keyword_id := $story_keywords-file//record[story_id = $id]/keyword_id
    let $keywords := $keywords-file//record[id = $keyword_id]/text/text()
    let $texts := $texts-file//record[story_id = $id]/(text_chinese | text_english)
    let $gender_of_main_char := $genders-file//record[id = $story/gender_of_main_char]/gender/text()
    let $roles :=
        <roles>
            {
                for $story-role in $story_roles-file//record[story_id = $id]
                let $role-id := $story-role/role_id
                let $role := $persons_roles-file//record[id = $role-id]/*[not(local-name() = ('id', 'story_role', 'orig_field', 'book_role'))]
                let $person := $persons-file//record[id = $story-role/person_id]
                let $person-name := $persons_variants-file//record[id = $person//preferred_variant]/name
        
                return
                    <role id="{$role-id}">
                        <description>{$role}</description>
                        <person id="{$story-role/person_id}">{$person-name}</person>
                    </role>
            }
        </roles>
    let $parts :=
        <books>
            {
                for $part in ($story_parts-file | $book_parts-file)//record[story_id = $id]
                let $book_id := $part/book_id
                let $book := $books-file//record[id = $book_id]
                let $book-number := $book/Number
                let $book-title-chinese := $book/Titel_Chinese
                let $book-title-transcription := $book/Title_Transcription
                let $book-title-english := $book/Title_English
                let $part-number := $part/part_number
                let $pages := $part/pages
                
                return
                    <book id="{$book_id}">
                        {
                            $book-number
                            ,
                            $book-title-chinese
                            ,
                            $book-title-transcription
                            ,
                            $book-title-english
                            ,
                            $part-number
                            ,
                            $pages
                         }
                     </book>
            }
        </books>
            
    return
        (
            if (exists($notes))
            then update insert $notes into $story
            else ()            
            ,
            if (exists($keywords))
            then update insert <keywords>{$keywords}</keywords> into $story
            else ()
            ,
            if (exists($texts))
            then update insert $texts into $story
            else ()
            ,
            if (exists($gender_of_main_char))
            then update value $story/gender_of_main_char with $gender_of_main_char
            else ()
            ,
            if (exists($roles))
            then update insert $roles into $story
            else ()
            ,
            if (exists($parts))
            then update insert $parts into $story
            else ()            
        )


return doc($path || "temp/processed-stories.xml")/*/*[id = '2']