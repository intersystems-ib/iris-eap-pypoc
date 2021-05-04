Class PyPoc.UnitTest.grpc Extends %UnitTest.TestCase
{

Property FilePath As %String(MAXLEN = "");

Method OnBeforeAllTests() As %Status
{
    set ret = $$$OK
    try {
        // set file path to access gRPC proto files
        set filePath = ##class(%File).NormalizeDirectory("", $get(^UnitTestRoot))
        set filePath = ##class(%File).SubDirectoryName(filePath, "../../../files/grpc")
        set ..FilePath = ##class(%File).NormalizeDirectory("", filePath)
        if ..FilePath="" $$$ThrowStatus($$$ERROR($$$GeneralError, "FilePath is not correct"))

    } catch ex {
        set ret = ex.AsStatus()
    } 
    quit ret
}

Method TestGreeter() As %Status
{
    set grpcPath = ..FilePath
    set outputPath =  $zu(12)_"python"

    do $$$LogMessage("building gRPC python stubs from protos in: "_outputPath)
    set helper = ##class(PyPoc.grpc.Helper).%New()
    do helper.PyBuildPackageProtos(grpcPath, outputPath)

    do $$$LogMessage("creating gRPC server...")
    job ##class(PyPoc.grpc.GreeterServer).Run()
    set serverJob = $ZCHILD
    do $$$LogMessage("gRPC server running on job "_$ZCHILD)

    set hangTime=.5
    do $$$LogMessage("hanging for "_hangTime_" seconds...")
    hang hangTime
    do $$$LogMessage("done")

    for i=1:1:3 {
        set clientName = "client"_i
        do $$$LogMessage("calling gRPC clientName="_clientName)
        set received = ##class(PyPoc.grpc.GreeterClient).Run("client"_i)
        set expected = "Received: Hi "_clientName_"!"
        do $$$AssertEquals(received, expected, "gRPC client receives: "_expected)
    }

    do $$$LogMessage("terminating gRPC server...")
    do $$$AssertStatusOK(##class(PyPoc.grpc.GreeterServer).Terminate(serverJob, .returnVal))
}

}
