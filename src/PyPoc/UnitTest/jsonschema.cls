Class PyPoc.UnitTest.jsonschema Extends %UnitTest.TestCase
{

Property jsonschema As %SYS.Python;

Property json As %SYS.Python;

Method OnBeforeAllTests() As %Status
{
    set ret = $$$OK
    try {
        // import Python modules
        set ..jsonschema = ##class(%SYS.Python).Import("jsonschema")
        set ..json = ##class(%SYS.Python).Import("json")

    } catch ex {
        set ret = ex.AsStatus()
    } 
    quit ret
}

/// Test Valid json
Method TestValidJSON() As %Status
{
    set schema = { 
        "type" : "object", 
        "properties" : {
            "price" : {"type" : "number"},
            "name" : {"type" : "string"}
        }
    }.%ToJSON()

    set json = { "name" : "Eggs", "price" : 34.99 }.%ToJSON()

    // convert input json, schema to dict
    set jsonDict = ..json.loads(json)
    set schemaDict = ..json.loads(schema)

    // validate
    set args = { "instance": (jsonDict) , "schema": (schemaDict) }
    try {
        do ..jsonschema.validate(args...) 
    } catch validationEx {
        do $$$AssertFailure("validation failed while testing valid json")
        Throw validationEx
    }
    do $$$AssertSuccess("validation OK")
}

/// Test Invalid json
Method TestInvalidJSON() As %Status
{
    set schema = { 
        "type" : "object", 
        "properties" : {
            "price" : {"type" : "number"},
            "name" : {"type" : "string"}
        }
    }.%ToJSON()

    set json = { "name" : "Eggs", "price" : "Invalid" }.%ToJSON()

    // convert input json, schema to dict
    set jsonDict = ..json.loads(json)
    set schemaDict = ..json.loads(schema)

    // validate; check exceptions
    set args = { "instance": (jsonDict) , "schema": (schemaDict) }
    try {
        do ..jsonschema.validate(args...) 
    } catch validationEx {
        do $$$AssertTrue(validationEx.Data["'Invalid' is not of type 'number'")
    }
}

}
