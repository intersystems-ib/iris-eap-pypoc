Python Pocs

Simple Pocs developed during embedded Python Evaluation + IRIS.

Samples are written in a UnitTest fashion so you can test them easily in each release.

# Requirements
`IRIS for UNIX (Ubuntu Server LTS for x86-64) 2021.1.0PYTHON (Build 204U) Fri Apr 30 2021 00:24:43 UTC`

# Setup
1. Clone repo
```
cd /tmp
git clone https://github.com/intersystems-ib/iris-eap-pypoc
cd iris-eap-pypoc
```

2. Load source code into IRIS.
```
zn "USER"
write ##class(%EnsembleMgr).EnableNamespace("USER")
do $system.OBJ.LoadDir("/tmp/iris-eap-pypoc/src", "ck")
```

3. Set `^UnitTest` global to the source directory
```
set ^UnitTestRoot = "/tmp/iris-eap-pypoc/src/PyPoc/UnitTest"
```

# PyPocs
## jsonschema 
Validate json using [JSON Schema](https://json-schema.org/).

[ProdLog 161649](http://live.prodlog.iscinternal.com/prodlog/main.csp#item=161649) asked for JSON Schema support.

Use cases:
 * Validate JSON data received before processing.
 * Validate JSON data before sending it to a external API.

[Try it! 📝](src/PyPoc/UnitTest/jsonschema.cls)
```objectscript
do ##class(%UnitTest.Manager).RunTest(":PyPoc.UnitTest.jsonschema", "/noload/norecursive/nodelete")
```

<details>
  <summary>👉 Click to view results</summary>
  
  ```
USER>do ##class(%UnitTest.Manager).RunTest(":PyPoc.UnitTest.jsonschema", "/noload/norecursive/nodelete")

===============================================================================
Directory: /tmp/iris-eap-pypoc/src/PyPoc/UnitTest/
===============================================================================
  (root) begins ...
    PyPoc.UnitTest.jsonschema begins ...
      TestInvalidJSON() begins ...
        AssertTrue:validationEx.Data["'Invalid' is not of type 'number'" (passed)
        LogMessage:Duration of execution: .001105 sec.
      TestInvalidJSON passed
      TestValidJSON() begins ...
        AssertSuccess:validation OK (passed)
        LogMessage:Duration of execution: .000515 sec.
      TestValidJSON passed
    PyPoc.UnitTest.jsonschema passed
  Skipping deleting classes 
  (root) passed

Use the following URL to view the result:
http://127.0.1.1:52773/csp/sys/%25UnitTest.Portal.Indices.cls?Index=211&$NAMESPACE=USER
All PASSED  
  ```
</details>

## FHIR narrative (templates)
Use a [jinja2](https://github.com/pallets/jinja) template engine (including if and for loops) to render documents.

Use cases:
 * Generate documents from data (e.g. emails, html, etc.) in a simple but powerful way.
 * Generate FHIR resource narrative.

FHIR resource narrative:
 * FHIR resources may include a human readable narrative.
 * If narrative is present, it shall be safe to render only the narrative without displaying discrete information.
 * Narrative must contain information about **IsSummary** elements, and extensions marked as **modifierExtension**.
 * Libraries like [HAPI FHIR](https://hapifhir.io/hapi-fhir/) include [narrative generation](https://hapifhir.io/hapi-fhir/docs/model/narrative_generation.html) features based on templates.
* This use case could leverage complex template features (inheritance, for loops, if, etc.) to build a FHIR resource narrative generation engine.

[Try it! 📝](src/PyPoc/UnitTest/narrative.cls)
```
do ##class(%UnitTest.Manager).RunTest(":PyPoc.UnitTest.narrative", "/noload/norecursive/nodelete")
```

<details>
  <summary>👉 Click to view results</summary>
  
  ```
USER>do ##class(%UnitTest.Manager).RunTest(":PyPoc.UnitTest.narrative", "/noload/norecursive/nodelete")

===============================================================================
Directory: /tmp/iris-eap-pypoc/src/PyPoc/UnitTest/
===============================================================================
  (root) begins ...
    PyPoc.UnitTest.narrative begins ...
      TestFHIRNarrative() begins ...
        AssertFilesSame:'/tmp/iris-eap-pypoc/files/narrative/output.html'=='/tmp/iris-eap-pypoc/files/narrative/expected.html' (passed)
        LogMessage:Duration of execution: .009514 sec.
      TestFHIRNarrative passed
      TestSimpleTemplate() begins ...
        AssertEquals:output== "Very Simple template with some data like: foo or 123" (passed)
        LogMessage:Duration of execution: .000976 sec.
      TestSimpleTemplate passed
    PyPoc.UnitTest.narrative passed
  Skipping deleting classes 
  (root) passed

Use the following URL to view the result:
http://127.0.1.1:52773/csp/sys/%25UnitTest.Portal.Indices.cls?Index=210&$NAMESPACE=USER
All PASSED  
  ```
</details>

<br>

You can use templates like this:
```
<div>
    <h1>{{ resourceType }}</h1>

    <h2>Identifiers</h2>
    <ul>
        {% for id in identifier -%}
            {% if id.type is defined -%}
                <li>{{ id.type.text }}: {{ id.value }}</li>
            {% endif %}
        {% endfor %}
    </ul>

    <h2>Name</h2>
    <ul>
        {% for iname in name -%}
            <li>{{ iname.family }} ({% for igiven in iname.given-%} {{ igiven }} {% endfor %})</li>
        {% endfor %}
    </ul>
</div>
```

## gRPC
Use gRPC within an IRIS context.

* gRPC is an open source remote procedure call. It is lightweight and high-performance.
* It uses HTTP/2 for transport, Protocol Buffers as the interface description language.
* It generates cross-platform client and server bindings for many languages (Python included). 
* Most common usage scenarios include connecting services in a microservices style architecture, or connecting mobile device clients to backend services.

Use cases:
 * Leverage gRPC Python generated code from a protobuffer into IRIS.

[Try it! 📝](src/PyPoc/UnitTest/grpc.cls)
```
do ##class(%UnitTest.Manager).RunTest(":PyPoc.UnitTest.grpc", "/noload/norecursive/nodelete")
```

<details>
  <summary>👉 Click to view results</summary>
  
  ```
  USER>do ##class(%UnitTest.Manager).RunTest(":PyPoc.UnitTest.grpc", "/noload/norecursive/nodelete")

===============================================================================
Directory: /tmp/iris-eap-pypoc/src/PyPoc/UnitTest/
===============================================================================
  (root) begins ...
    PyPoc.UnitTest.grpc begins ...
      TestGreeter() begins ...
        LogMessage:creating gRPC server...
        LogMessage:gRPC server running. job=173181 port=50053
        LogMessage:hanging for .5 seconds...
        LogMessage:done
        AssertEquals:gRPC client receives: Hi Yoders,Christine Q.! (passed)
        AssertEquals:gRPC client receives: Hi Nagel,Susan V.! (passed)
        AssertEquals:gRPC client receives: Hi Campos,Alice J.! (passed)
        LogMessage:terminating gRPC server...
        AssertStatusOK:##class(PyPoc.grpc.GreeterServer).Terminate(serverJob, .returnVal) (passed)
        LogMessage:Duration of execution: .563179 sec.
      TestGreeter passed
      TestRecommendation() begins ...
        LogMessage:creating gRPC server...
        LogMessage:gRPC server running. job=173188 port=50054
        LogMessage:hanging for .5 seconds...
        LogMessage:done
        AssertEquals:gRPC client receives: The Maltese Falcon (passed)
        LogMessage:terminating gRPC server...
        AssertStatusOK:##class(PyPoc.grpc.RecommendationServer).Terminate(serverJob, .returnVal) (passed)
        LogMessage:Duration of execution: .524117 sec.
      TestRecommendation passed
    PyPoc.UnitTest.grpc passed
  Skipping deleting classes 
  (root) passed

Use the following URL to view the result:
http://127.0.1.1:52773/csp/sys/%25UnitTest.Portal.Indices.cls?Index=209&$NAMESPACE=USER
All PASSED
  ```
</details>

<br>

gRPC could be implemented as part of Interoperability framework, have a look at:
* [Business Operation](src/PyPoc/grpc/Interop/Operation.cls).
* [Business Service](src/PyPoc/grpc/Interop/Service.cls) using an [Adapter](src/PyPoc/grpc/Interop/Adapter.cls): it works, receives gRPC incoming messages that can be converted to production messages, however it does not stop gracefully at all probably because the server process is blocking. 

In case you want to test the Business Service, you can stop the job using:
```objectscript
do ##class(PyPoc.grpc.Interop.Adapter).Terminate(<jobNumber>)
```

## mocking
Use python mocking and unittest framework.
Mock objects are simulated objects that mimic the behaviour of real objects in controlled ways.

Use cases:
* Take advantage of Python mocking framework: mock object methods and properties, include side effects, etc.
* Allow developers to create more complex & powerful unitests using mocked objects and Python unitest framework.

[Try it! 📝](src/PyPoc/UnitTest/mocking.cls)
```
do ##class(PyPoc.UnitTest.mocking).PyTestGreeter()
```

You can mock IRIS Objectscript defined objects using Python mock object library. 

```python
   class TestGreeter(unittest.TestCase):
        """UnitTest for PyPoc.mocking.Greeter"""

        def setUp(self):
            """Setup test (instantiate objects)"""

            self.greeter = iris.cls("PyPoc.mocking.Greeter")._New()

            # create a mock TimeService that will be used by Greeter
            self.timeService = iris.cls("PyPoc.mocking.TimeService")._New()
            self.timeService = Mock(spec=['IsMorning', 'IsAfternoon', 'IsEvening'])
            self.greeter.timeService = self.timeService 
            
        def test_good_morning(self):
            """Mocked TimeService: IsMorning()=1"""

            self.timeService.IsMorning.return_value = 1
            self.assertEquals(self.greeter.GetSomeGreet("foo"), "Good morning foo!, have a nice day")
            self.assertEquals(self.timeService.IsMorning.call_count, 1, "Is Morning call count")
```