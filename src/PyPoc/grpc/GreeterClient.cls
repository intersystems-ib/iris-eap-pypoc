/// Sample gRPC client
/// 
/// set client = ##class(PyPoc.grpc.GreeterClient).%New("localhost", 50052)
/// do client.BuildMessage("Foo")
/// set rsp = client.SendMessage()
/// write rsp.message
/// 
Class PyPoc.grpc.GreeterClient Extends %RegisteredObject
{

/// IP Address
Property IPAddress As %String;

/// Port
Property Port As %Integer;

/// gRPC channel. This could be re-used
Property channel As %SYS.Python;

/// gRPC request
Property req As %SYS.Python;

/// gRPC response
Property rsp As %SYS.Python;

/// Constructor
Method %OnNew(ipAddress As %String = "localhost", port As %Integer = "50052") As %Status [ Private, ServerOnly = 1 ]
{
    set ret = $$$OK
    try {
        set ..IPAddress = ipAddress
        set ..Port = port

    } catch ex {
        set ret = ex.AsStatus()
    }
    quit ret
}

/// Build gRPC request from incoming attributes
Method BuildMessage(clientName As %String) As %SYS.Python
{
    set mod = ##class(%SYS.Python).Import("helloworld_pb2")
    set args = { "name": (clientName) }
    set ..req = mod.HelloRequest(args...)
}

/// Send message using gRPC generated stub
Method SendMessage() As %SYS.Python [ Language = python ]
{
    import grpc
    import helloworld_pb2
    import helloworld_pb2_grpc

    # create grpc channel
    self.channel = grpc.insecure_channel('{}:{}'.format(self.IPAddress, self.Port))

    # create stub
    stub = helloworld_pb2_grpc.GreeterStub(self.channel)
    
    # send message
    self.rsp = stub.SayHello(self.req)
    return self.rsp
}

}
