xquery version "3.1";

declare namespace sql="http://exist-db.org/xquery/sql";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace e = "http://www.asia-europe.uni-heidelberg.de/";

let $input-collection := "/data/chinese-comics/input/books-in-mods-format/"
let $output-collection := "/data/chinese-comics/output/books-in-mods-format/"

let $chinese-comics-sql-tables-as-xml-collection := "/data/chinese-comics/input/chinese-comics-sql-tables-as-xml/"
let $books-file := doc($chinese-comics-sql-tables-as-xml-collection || "books.xml")
let $persons_variants-file := doc($chinese-comics-sql-tables-as-xml-collection || "persons_variants.xml")

let $store-records:=
    for $record in collection($input-collection)//mods:mods
    let $record-name := util:document-name($record)
    let $id := substring-before($record-name, ".xml")
    let $uuid := "uuid-" || $id    
    
    return xmldb:store($output-collection, $uuid || ".xml", $record)

let $output-records := collection($output-collection)//mods:mods
return 
    for $record in $output-records
    let $record-name := util:document-name($record)
    let $id := substring-before($record-name, ".xml")
    let $uuid := "uuid-" || $id
    let $manifest-url := $books-file//record[id = $id]/manifestUrl/text()
    let $related-item := <relatedItem xmlns="http://www.loc.gov/mods/v3" displayLabel="IIIF Manifest URL" type="constituent">{$manifest-url}</relatedItem>
    let $dateIssued := $books-file//record[id = $id]/Original_First_Edition/text()
    let $dateIssued := <dateIssued xmlns="http://www.loc.gov/mods/v3">{$dateIssued}</dateIssued>
    let $Year_of_publication := $books-file//record[id = $id]/Year_of_publication/text()
    let $Year_of_publication := <e:Year_of_publication xmlns:e="http://www.asia-europe.uni-heidelberg.de/">{$Year_of_publication}</e:Year_of_publication>
    
    let $First_Edition := $books-file//record[id = $id]/First_Edition/text()
    let $First_Edition := <e:First_Edition xmlns:e="http://www.asia-europe.uni-heidelberg.de/">{$First_Edition}</e:First_Edition>
    
    let $Other_varying_Editions := <e:Other_varying_Editions xmlns:e="http://www.asia-europe.uni-heidelberg.de/">{$books-file//record[id = $id]/Other_varying_Editions/text()}</e:Other_varying_Editions>
    
    return
        (
            update value $record/mods:mods/@ID with $uuid
            ,
            update insert attribute ID {$id} into $record/mods:mods/mods:physicalDescription/mods:digitalOrigin
            ,
            update insert $related-item preceding $record/mods:mods/*[local-name() = 'extension']
            ,
            for $element in $record//mods:namePart[@lang = 'chi']
            let $person-id := $element/text()
            let $name := $persons_variants-file//record[person_id = $person-id and script_scheme = '42']/name/text()         
            return (
                update insert attribute ID {$person-id} into $element
                ,
                update value $element with $name
            )
            ,
            for $element in $record//mods:nameId
            let $id := $element/text()
            let $name := $persons_variants-file//record[person_id = $id and script_scheme = '42']/name/text()         
            return update value $element/ancestor::mods:publisher with $name
            ,            
            update insert $dateIssued following $record/mods:mods/mods:originInfo/mods:place
            ,
            update insert $Year_of_publication into $record/mods:mods/mods:extension
            ,
            update insert $First_Edition into $record/mods:mods/mods:extension
            ,
            update insert $Other_varying_Editions into $record/mods:mods/mods:extension
        )
    