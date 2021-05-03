Class PyPoc.grpc.GreeterServer Extends %RegisteredObject
{

Method PyServer() [ Language = python ]
{
    from concurrent import futures
    
    import grpc
    import helloworld_pb2
    import helloworld_pb2_grpc

    class Greeter(helloworld_pb2_grpc.GreeterServicer):
        def __init__(self, irisObj):
            self.irisObj = irisObj
        
        def SayHello(self, request, context):
            return helloworld_pb2.HelloReply(message=self.irisObj.SomeFancyGreeting(request.name))

    def serve():
        server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
        helloworld_pb2_grpc.add_GreeterServicer_to_server(Greeter(self), server)
        port = 50052
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

Method SomeFancyGreeting(name As %String) As %String
{
    quit "Hi "_name_"!"
}

ClassMethod Run()
{
    set obj = ..%New()
    set oldstate = $system.Python.ChangeSignalState(0)
    try { 
        do obj.PyServer()
    } catch ex {
        do ex.DisplayString()
    }
    do $system.Python.ChangeSignalState(oldstate)
}

}