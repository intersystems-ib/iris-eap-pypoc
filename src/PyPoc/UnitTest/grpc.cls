Class PyPoc.UnitTest.grpc Extends %UnitTest.TestCase
{

Property FilePath As %String(MAXLEN = "");

Method OnBeforeAllTests() As %Status
{
    set ret = $$$OK
    try {
        // set file path to retrieve gRPC proto files
        set filePath = ##class(%File).NormalizeDirectory("", $get(^UnitTestRoot))
        set filePath = ##class(%File).SubDirectoryName(filePath, "../../../files/grpc")
        set ..FilePath = ##class(%File).NormalizeDirectory("", filePath)
        if ..FilePath="" $$$ThrowStatus($$$ERROR($$$GeneralError, "FilePath is not correct"))

        // build python stubs into <install>/mgr/python directory
        set grpcPath = ..FilePath
        set outputPath =  $zu(12)_"python"
        do $$$LogMessage("building gRPC python stubs from protos in: "_outputPath)
        set helper = ##class(PyPoc.grpc.Helper).%New()
        do helper.PyBuildPackageProtos(grpcPath, outputPath)

    } catch ex {
        set ret = ex.AsStatus()
    } 
    quit ret
}

/// based on:
/// gRPC quickstart https://grpc.io/docs/languages/python/quickstart/
Method TestGreeter() As %Status
{
    // create grpc server using other process
    set port = 50053
    do $$$LogMessage("creating gRPC server...")
    job ##class(PyPoc.grpc.GreeterServer).Run(port)
    set serverJob = $ZCHILD
    do $$$LogMessage("gRPC server running. job="_$ZCHILD_ " port="_port)

    // wait some time
    set hangTime=.5
    do $$$LogMessage("hanging for "_hangTime_" seconds...")
    hang hangTime
    do $$$LogMessage("done")

    // run some grpc client calls
    for i=1:1:3 {
        set client = ##class(PyPoc.grpc.GreeterClient).%New("localhost", port)
        set name = ##class(%PopulateUtils).Name()
        do client.BuildMessage(name)
        set received = client.SendMessage()
        set expected = "Hi "_name_"!"
        do $$$AssertEquals(received.message, expected, "gRPC client receives: "_received.message)
    }

    // terminate grpc server process
    do $$$LogMessage("terminating gRPC server...")
    do $$$AssertStatusOK(##class(PyPoc.grpc.GreeterServer).Terminate(serverJob, .returnVal))
}

/// based on:
/// https://realpython.com/python-microservices-grpc/
Method TestRecommendation() As %Status
{
    // create grpc server using other process
    set port = 50054
    do $$$LogMessage("creating gRPC server...")
    job ##class(PyPoc.grpc.RecommendationServer).Run(port)
    set serverJob = $ZCHILD
    do $$$LogMessage("gRPC server running. job="_$ZCHILD_ " port="_port)

    // wait some time
    set hangTime=.5
    do $$$LogMessage("hanging for "_hangTime_" seconds...")
    hang hangTime
    do $$$LogMessage("done")

    // run some grpc client calls
    set client = ##class(PyPoc.grpc.RecommendationClient).%New("localhost", port)
    do client.BuildMessage(22, "", 3)
    set received = client.SendMessage()
    set expected = "The Maltese Falcon"
    do $$$AssertEquals(received.recommendations."__getitem__"(0).title, expected, "gRPC client receives: "_expected)

    // terminate grpc server process
    do $$$LogMessage("terminating gRPC server...")
    do $$$AssertStatusOK(##class(PyPoc.grpc.RecommendationServer).Terminate(serverJob, .returnVal))
}

}
