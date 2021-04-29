Class PyPoc.UnitTest.Helper Extends %RegisteredObject
{

/// Import or install a Python module
ClassMethod ImportOrInstall(moduleName As %String, Output pyObj As %SYS.Python) As %Status
{
        set ret = $$$OK
        try {
            set pyObj = ""
            try {
                set pyObj = ##class(%SYS.Python).Import(moduleName)
            } catch importEx {
                do $system.OBJ.Dump(importEx)
                $$$ThrowOnError(##class(%SYS.Python).Install(moduleName))
                set pyObj = ##class(%SYS.Python).Import(moduleName)
            }

        }  catch ex {
            set ret = ex.AsStatus()
        } 
        quit ret
}

}
