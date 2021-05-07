/// Sample gRPC client
/// 
/// set client = ##class(PyPoc.grpc.RecommendationClient).%New("localhost", 50052)
/// do client.BuildMessage(22, "", 3)
/// set rsp = client.SendMessage()
/// zwrite rsp
/// 
Class PyPoc.grpc.RecommendationClient Extends %RegisteredObject
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
Method BuildMessage(userId As %String, category As %String, maxResults As %Integer) As %SYS.Python
{
    set mod = ##class(%SYS.Python).Import("recommendations_pb2")
    set scienceFiction = mod.BookCategory."SCIENCE_FICTION"

    set args = { "user_id": (userId), "category": (scienceFiction), "max_results": 3 }
    set ..req = mod.RecommendationRequest(args...)
}

/// Send message using gRPC generated stub
Method SendMessage() As %SYS.Python [ Language = python ]
{
    import grpc
    import recommendations_pb2
    import recommendations_pb2_grpc

    # create grpc channel
    self.channel = grpc.insecure_channel('{}:{}'.format(self.IPAddress, self.Port))

    # create stub
    stub = recommendations_pb2_grpc.RecommendationsStub(self.channel)
    
    # send message
    self.rsp = stub.Recommend(self.req)
    return self.rsp
}

}
