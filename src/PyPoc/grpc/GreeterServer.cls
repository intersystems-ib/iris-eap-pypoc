/// 
/// Sample gRPC Server
/// do ##class(PyPoc.grpc.GreeterServer).Run()  
/// 
Class PyPoc.grpc.GreeterServer Extends %RegisteredObject
{

/// Run actual gRPC server
Method PyServer(port As %String) [ Language = python ]
{
    from concurrent import futures
    
    import grpc
    import helloworld_pb2
    import helloworld_pb2_grpc

    class Greeter(helloworld_pb2_grpc.GreeterServicer):
        """Class with the actual logic of the gRPC Greeter Service"""

        def __init__(self, irisObj):
            """Constructor uses irisObj to access IRIS object context"""

            self.irisObj = irisObj
        
        def SayHello(self, request, context):
            """Implementation of SayHello method defined on protobuf"""

            # process grpc request
            response = self.irisObj.SayHello(request)

            # send response back to caller
            return response

    def serve():
        server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
        helloworld_pb2_grpc.add_GreeterServicer_to_server(Greeter(self), server)
        server.add_insecure_port('[::]:{}'.format(port))
        server.start()
        print('Started server at {}'.format(port))
        
        from signal import signal, SIGINT, SIGTERM
        def handle_signal(*_):
            print("Received shutdown signal")
            all_rpcs_done_event = server.stop(30)
            all_rpcs_done_event.wait(30)
            print("Shut down gracefully")
        
        signal(SIGINT, handle_signal)
        signal(SIGTERM, handle_signal)
        server.wait_for_termination()

    serve()
}

/// Implementation of SayHello operation in IRIS
Method SayHello(input As %SYS.Python) As %SYS.Python
{
	set output = ""
	
    set mod = ##class(%SYS.Python).Import("helloworld_pb2")
    set args = { "message": ("Hi "_input.name_"!") }
    set output = mod.HelloReply(args...)
        
	quit output
}

/// Run the server (blocking)
/// do ##class(PyPoc.grpc.GreeterServer).Run()
ClassMethod Run(port As %Integer = 50052)
{
    set obj = ..%New()
    try {
        write !,"Job: ",$job,! 
        do obj.PyServer(port)
    } catch ex {
        do ex.DisplayString()
    }
}

/// Terminate a gRPC Server process
ClassMethod Terminate(jobNum As %String, Output returnVal) As %Status
{
    set ret = $$$OK
    try {
        // send SIGINT to server process (should shutdown gracefully)
        set os = ##class(%SYS.Python).Import("os")
        set signal = ##class(%SYS.Python).Import("signal")
        do os.kill(jobNum, signal.SIGINT)

        // terminate IRIS job
        set returnVal = ""
        do $system.Process.Terminate(jobNum, .returnVal)

    } catch ex {
        set ret = ex.AsStatus()
    }
    quit ret
}

}
