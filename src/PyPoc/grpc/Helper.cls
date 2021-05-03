Class PyPoc.grpc.Helper Extends %RegisteredObject
{

/// Build python stubs from protos
/// See: https://github.com/grpc/grpc/blob/5253c8f9a899450397a5e46e4923d01ac9a66a27/tools/distrib/python/grpcio_tools/grpc_tools/command.py#L35
Method PyBuildPackageProtos(packageRoot As %String, outputPath As %String) As %Status [ Language = python ]
{
    import os
    import pkg_resources
    from grpc_tools import protoc

    proto_files = []
    inclusion_root = os.path.abspath(packageRoot)
    for root, _, files in os.walk(inclusion_root):
        for filename in files:
            if filename.endswith('.proto'):
                proto_files.append(os.path.abspath(os.path.join(root, filename)))

    well_known_protos_include = pkg_resources.resource_filename('grpc_tools', '_proto')
   
    for proto_file in proto_files:
        command = [
            'grpc_tools.protoc',
            '--proto_path={}'.format(inclusion_root),
            '--proto_path={}'.format(well_known_protos_include),
            '--python_out={}'.format(outputPath),
            '--grpc_python_out={}'.format(outputPath),
        ] + [proto_file]
        if protoc.main(command) != 0:
            sys.stderr.write('warning: {} failed'.format(command))
}

}
