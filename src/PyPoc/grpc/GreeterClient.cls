Class PyPoc.grpc.GreeterClient Extends %RegisteredObject
{

Method PyClient(clientName As %String) As %Status [ Language = python ]
{
    import grpc
    import helloworld_pb2
    import helloworld_pb2_grpc

    with grpc.insecure_channel('localhost:50052') as channel:
        stub = helloworld_pb2_grpc.GreeterStub(channel)
        response = stub.SayHello(helloworld_pb2.HelloRequest(name=clientName))
    return "Received: " + response.message
}

ClassMethod Run(clientName As %String = "foo") As %String
{
    set obj = ..%New()
    quit obj.PyClient(clientName)
}

}
