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