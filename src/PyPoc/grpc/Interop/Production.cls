Class PyPoc.grpc.Interop.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="PyPoc.grpc.Interop.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="PyPoc.grpc.Interop.Operation" Category="" ClassName="PyPoc.grpc.Interop.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Port">50052</Setting>
  </Item>
  <Item Name="dummy" Category="" ClassName="EnsLib.File.PassthroughOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PyPoc.grpc.Interop.Service" Category="" ClassName="PyPoc.grpc.Interop.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
