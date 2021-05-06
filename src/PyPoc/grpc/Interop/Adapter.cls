/// gRPC server run as Interoperability Adapter
/// TODO: 
///  * Errors while stopping production probably because server job is blocking
Class PyPoc.grpc.Interop.Adapter Extends Ens.InboundAdapter
{

/// Port
Property Port As %Integer [ InitialExpression = "50052" ];

Parameter SETTINGS = "Port:gRPC";

/// Run grpc server
Method RunServer() [ Language = python ]
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
            response = self.irisObj.BusinessHost.GRPCOnProcessInput(request)

            # send response back to caller
            return response

    def serve():
        """gRPC Server"""
        
        server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
        helloworld_pb2_grpc.add_GreeterServicer_to_server(Greeter(self), server)

        # listen connections on specified port
        server.add_insecure_port('[::]:{}'.format(self.Port))
        server.start()

        print('Started server at {}'.format(self.Port))
        
        # handle termination signals
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

/// This user callback method is called just after %OnNew()
Method OnInit() As %Status
{
    quit ..RunServer()
}

/// This user callback method is called just before %OnClose()
Method OnTearDown() As %Status
{
    do ..Terminate($job)
}

/// Terminate gRPC Server process
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
