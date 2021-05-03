Class PyPoc.UnitTest.basics Extends %UnitTest.TestCase
{

Property MyIRISProperty As %String;

Method OnBeforeAllTests() As %Status
{
    quit $$$OK
}

/// Python: set IRIS object property
Method PyTestProperty(val As %String) As %String [ Language = python ]
{
    self.MyIRISProperty = val
    return self.MyIRISProperty
}

/// Python: read global
Method PyTestReadGlobal(globalName) As %String [ Language = python ]
{
    import iris
    glo = iris.gref(globalName)
    return glo.get()
}

/// Test property access
Method TestProperty() As %Status
{
    set val = "python set property"
    set output = ..PyTestProperty(val)
    do $$$AssertEquals(..MyIRISProperty, val, "python: set property")
    do $$$AssertEquals(output, val, "python: method return value after setting")
}

/// Test global access
Method TestGlobal() As %Status
{
    set val = "init global value" 
    set ^zpypoc = val
    set pyGlbVal = ..PyTestReadGlobal("^zpypoc")
    do $$$AssertEquals(pyGlbVal, val, "python: read global")
}

}
