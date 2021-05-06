Class PyPoc.grpc.Interop.Service Extends Ens.BusinessService
{

Parameter ADAPTER = "PyPoc.grpc.Interop.Adapter";

Property TargetConfigNames As %String(MAXLEN = 1000);

Property Port As %Integer [ InitialExpression = "50052" ];

Parameter SETTINGS = "Port:gRPC,TargetConfigNames:Basic:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

/// Use GRPCOnProcessInput instead because pOutput object does not get modified back to Python context
Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	quit $$$OK
}

/// Actual process input
/// pInput: incoming gRPC request (Python)
/// pOutput: outgoing gRPC response (Python)
Method GRPCOnProcessInput(pInput As %SYS.Python) As %SYS.Python
{
	set output = ""
	
    // build a production message from incoming gRPC request
	set req = ##class(Ens.StringContainer).%New()
    set req.StringValue = pInput.name

    // send message to a production element
    $$$ThrowOnError(..SendRequestAsync("dummy", req))

    // build gRPC response that will be sent back
    set mod = ##class(%SYS.Python).Import("helloworld_pb2")
    set args = { "message": ("your message has been received") }
    set output = mod.HelloReply(args...)
        
	quit output
}

/// This user callback method is called just after %OnNew()
Method OnInit() As %Status
{
    quit $$$OK
}

/// This user callback method is called just before %OnClose()
Method OnTearDown() As %Status
{
	quit $$$OK
}

}
