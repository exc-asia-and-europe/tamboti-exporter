xquery version "3.0";

declare namespace vra = "http://www.vraweb.org/vracore4.htm";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "text";
declare option output:media-type "text/plain";

let $nl := "&#10;"

let $records := collection(xs:anyURI(xmldb:encode("/resources/users/matthias.guth@ad.uni-heidelberg.de/GrabungKMHKastellweg/Grabungstagebuch")))/vra:vra[vra:work]

return
    for $record in $records
    let $title := $record//vra:titleSet/vra:title
    let $inscriptions := $record//vra:inscriptionSet/vra:inscription
    order by $title
    
    return (
        $nl || $title || $nl
        ,
        for $inscription in $inscriptions
        
        return (
            $nl || "----------------------------------------" || $nl
            ,
            $inscription/vra:text
        )
        ,
        $nl || "****************************************" || $nl
    )
    