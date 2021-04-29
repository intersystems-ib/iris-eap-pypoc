Python Pocs

Simple Pocs developed during embedded Python Evaluation + IRIS.

Some Pocs are written in a UnitTest fashion so you can test them easily in each release.

# Setup
Clone repo
```
cd /tmp
git clone https://intersystems-ib/iris-eap-pypoc
cd iris-eap-pypoc
```
Load source code into IRIS.
```
sh loader.sh
```

# Run
1. Set `^UnitTest` global to the source directory
```
set ^UnitTestRoot = "/tmp/iris-eap-pypoc/UnitTest"
```

2. Run all tests:
```objectscript
do ##class(%UnitTest.Manager).RunTest("", "/noload/norecursive/nodelete")
```

3. Run some specific test:
```objectscript
do ##class(%UnitTest.Manager).RunTest("", "/noload/norecursive/nodelete")
```

# PyPocs
## jsonschema
* Validate json using [JSON Schema](https://json-schema.org/).
* See https://github.com/Julian/jsonschema
* [ProdLog 161649](http://live.prodlog.iscinternal.com/prodlog/main.csp#item=161649) asked for JSON Schema support.
