xquery version "3.0";

let $chinese-comics-sql-tables-as-xml-collection := "/db/data/chinese-comics/input/chinese-comics-sql-tables-as-xml/"
let $output-collection := "/data/chinese-comics/output/"

let $data-name := "persons"
let $file-name := $data-name || ".xml"
let $raw-data := doc($chinese-comics-sql-tables-as-xml-collection || $file-name)
let $duplicate-data := xmldb:store($output-collection, "processed-" || $file-name, $raw-data)
let $processed-data := doc($output-collection || "processed-" || $file-name)/*/*

let $persons_variants-file := doc($chinese-comics-sql-tables-as-xml-collection || "persons_variants.xml")
let $countries-file := doc($chinese-comics-sql-tables-as-xml-collection || "countries.xml")
let $languages-file := doc($chinese-comics-sql-tables-as-xml-collection || "languages.xml")
let $languages_script-file := doc($chinese-comics-sql-tables-as-xml-collection || "languages_script.xml")
let $languages_transliteration-file := doc($chinese-comics-sql-tables-as-xml-collection || "languages_transliteration.xml")

let $process-stories :=
    for $record in $processed-data
    let $id := $record/id
    let $preferred_variant-id := $record/preferred_variant
    
    let $preferred-variants :=
        <variants>
            {
                for $preferred-variant in $persons_variants-file//record[person_id = $id]
                
                return
                    <variant id="{$preferred-variant/id}">
                        {
                            if ($preferred_variant-id = $preferred-variant/id)
                            then attribute preferred {"true"}
                            else ()
                            ,
                            $preferred-variant/name
                            ,
                            <group>{$preferred-variant/var_group/text()}</group>
                            ,
                            let $language-id := $preferred-variant/language
                            let $language := $languages-file//record[id = $language-id]
                            let $language-label := $language/label || " (" || $language/value || ")"
                            
                            let $script :=
                                if ($preferred-variant/script_scheme != '')
                                then
                                    let $id := $preferred-variant/script_scheme
                                    let $script := $languages_script-file//record[id = $id]
                                    let $label := $script/label || " (" || $script/value || ")"   
                                    
                                    return
                                        map {
                                            "id" := $id,
                                            "classifier" := $language/scriptClassifier,
                                            "label" := $label
                                        }
                                else
                                    let $id := $preferred-variant/transscription_scheme
                                    let $script := $languages_transliteration-file//record[id = $id]
                                    let $label := $script/label || " (" || $script/value || ")"   
                                    
                                    return
                                        map {
                                            "id" := $id,
                                            "classifier" := $language/scriptClassifier,
                                            "label" := $label
                                        }                                    
                            
                            return (
                                <language id="{$language-id}" classifier="{$language/transliterationClassifier}">{$language-label}</language>
                                ,
                                <script id="{$script("id")}" classifier="{$script("classifier")}">
                                    {
                                        $script("label")
                                    }
                                </script>
                            )
                        }
                    </variant>
            }
        </variants>

    let $country_id := $record/country_id
    let $country := <country id="{$country_id}">{$countries-file//record[id = $country_id]/name_en/text()}</country>        
            
    return (
            if (exists($preferred-variants))
            then update replace $record/preferred_variant with $preferred-variants
            else () 
            ,
            if ($country)
            then update replace $record/country_id with $country
            else ()            
        )


return doc($output-collection || "processed-" || $file-name)/*/*[id = '9']