Class PyPoc.UnitTest.narrative Extends %UnitTest.TestCase
{

Property jinja2 As %SYS.Python;

Property json As %SYS.Python;

Property FilePath As %String(MAXLEN = "");

Method OnBeforeAllTests() As %Status
{
    set ret = $$$OK
    try {
        // import Python modules
        $$$ThrowOnError(##class(PyPoc.UnitTest.Helper).ImportOrInstall("json", .json))
        $$$ThrowOnError(##class(PyPoc.UnitTest.Helper).ImportOrInstall("jinja2", .jinja2))
        set ..json = json
        set ..jinja2 = jinja2

        // set file path to access external files
        set filePath = ##class(%File).NormalizeDirectory("", $get(^UnitTestRoot))
        set filePath = ##class(%File).SubDirectoryName(filePath, "../../../files/narrative")
        set ..FilePath = ##class(%File).NormalizeDirectory("", filePath)
        if ..FilePath="" $$$ThrowStatus($$$ERROR($$$GeneralError, "FilePath is not correct"))

    } catch ex {
        set ret = ex.AsStatus()
    } 
    quit ret
}

/// Test a very simple template
Method TestSimpleTemplate() As %Status
{
    set template = ..jinja2.Template("Very Simple template with some data like: {{ name }} or {{ value }}")
    set data = {
        "name": "foo",
        "value": "123"
    }
    set output = template.render(data...)

    do $$$AssertEquals(output, "Very Simple template with some data like: foo or 123")
}

/// Test a more complex template (if, for loops, etc.) for generatign a FHIR narrative (text)
Method TestFHIRNarrative() As %Status
{
    // load fhir json
    set fhirStream = ##class(%Stream.FileCharacter).%New()
    set fhirStream.Filename = ..FilePath_"patient.json"
    set fhirDict = ..json.loads(fhirStream.Read())
    
    // load template
    set templateStream = ##class(%Stream.FileCharacter).%New()
    set templateStream.Filename = ..FilePath_"template.html"
    set template = ..jinja2.Template(templateStream.Read())
    
    // generate output
    set output = template.render(fhirDict)
    set outputStream = ##class(%Stream.FileCharacter).%New()
    set outputStream.Filename = ..FilePath_"output.html"
    do outputStream.Write(output)
    do outputStream.%Save()
    do outputStream.%Close()

    // compare output vs. expected
    do $$$AssertFilesSame(..FilePath_"output.html", ..FilePath_"expected.html")
}

}
