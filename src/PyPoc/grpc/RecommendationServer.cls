/// 
/// Sample gRPC Server
/// do ##class(PyPoc.grpc.RecommendationServer).Run()  
/// 
Class PyPoc.grpc.RecommendationServer Extends %RegisteredObject
{

/// Run actual gRPC server
Method PyServer(port As %String) [ Language = python ]
{
    from concurrent import futures
    
    import grpc
    import recommendations_pb2
    import recommendations_pb2_grpc

    class RecomendationService(recommendations_pb2_grpc.RecommendationsServicer):
        """Class with the actual logic of the gRPC Recommendation Service"""

        def __init__(self, irisObj):
            """Constructor uses irisObj to access IRIS object context"""

            self.irisObj = irisObj
        
        def Recommend(self, request, context):
            """Implementation of Recommend method defined on protobuf"""

            # process grpc request
            response = self.irisObj.Recommend(request)

            # send response back to caller
            return response

    def serve():
        server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
        recommendations_pb2_grpc.add_RecommendationsServicer_to_server(RecomendationService(self), server)
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

/// Implementation of Recommend operation in IRIS
Method Recommend(input As %SYS.Python) As %SYS.Python
{
	set output = ""
	
    set mod = ##class(%SYS.Python).Import("recommendations_pb2")

    // build a list of BookRecommendations, this could use SQL queries
    set builtins = ##class(%SYS.Python).Import("builtins")
    set bookList = builtins.list()
    set bookArgs = { "id": 6, "title": "The Maltese Falcon" } 
    set book = mod.BookRecommendation(bookArgs...)
    do bookList.append(book)

    set args = { "recommendations": (bookList) }
    set output = mod.RecommendationResponse(args...)
        
	quit output
}

/// Run the server (blocking)
/// do ##class(PyPoc.grpc.RecommendationServer).Run()
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
