/// gRPC client as an Interoperability Business Operation
Class PyPoc.grpc.Interop.Operation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

/// Server IP Address
Property IPAddress As %String [ InitialExpression = "localhost" ];

/// Port
Property Port As %Integer [ InitialExpression = "50051" ];

/// gRPC Channel (could be re-used)
Property channel As %SYS.Python;

/// gRPC Request
Property req As %SYS.Python;

/// gRPC Response
Property rsp As %SYS.Python;

Parameter SETTINGS = "IPAddress:gRPC,Port:gRPC";

/// Make the grpc call
Method PySendMessage() As %Status [ Language = python ]
{
    import grpc
    import helloworld_pb2
    import helloworld_pb2_grpc

    # open grpc channel
    self.channel = grpc.insecure_channel('{}:{}'.format(self.IPAddress, self.Port))

    # create stub
    stub = helloworld_pb2_grpc.GreeterStub(self.channel)

    # send msg
    self.rsp = stub.SayHello(self.req)
}

/// Handle incoming production message and make de the grpc call
Method SendMessage(pRequest As Ens.StringContainer, pResponse As Ens.Response) As %Status
{
    set ret = $$$OK
    try {
        // create grpc request from incoming message
        set mod = ##class(%SYS.Python).Import("helloworld_pb2")
        set args = { "name": (pRequest.StringValue) }
        set ..req = mod.HelloRequest(args...)
        
        // send
        do ..PySendMessage()

        // create outgoing response from grpc call
        set pResponse = ##class(Ens.StringContainer).%New()
        set pResponse.StringValue = ..rsp.message

    } catch ex {
        set ret = ex.AsStatus()
    }
    quit ret
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringContainer"> 
		<Method>SendMessage</Method>
	</MapItem>
</MapItems>
}

}
