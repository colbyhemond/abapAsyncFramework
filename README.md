# abapAsyncFramework


## Overview
Use Cases:

*   Updating Data
*   Asynchronous Communication (when you don't need or expect a response - at least immediately)
*   Performance of SQL statements

The asynchronous framework utilizes the [Template Method design pattern](https://sourcemaking.com/design_patterns/template_method). This allows you to define the implementation of what you need to be processed asynchronously and pass that object into the framework, and the framework handles the calling of those specific methods. This allows the framework to "just work" and all you have to worry about is your implementation.

## Setup

### Definition

In order to create an object that can utilize asynchronous processing, you must create a new class that implements the `zif_async` interface.
```abap
CLASS lcl_update_table_async DEFINITION.
	PUBLIC SECTION.

		INTERFACES:
			zif_async.

	PROTECTED SECTION.
	PRIVATE SECTION.
ENDCLASS.
```

### Implementation

The `zif_async` interface, gives our new async object access to two methods:

1. `process_async`
2.  `callback`

The `process_async` method is where you define what needs to be processed asynchronously.

The `callback` method is where you can optionally define any processing that would need to be completed after the asynchronous processing happens in `process_async`.

For more information on using the callback method, see the Callback section below.
```abap
CLASS lcl_update_table_async IMPLEMENTATION.

	METHOD zif_async~process_async.
		"add your logic to be processed asynchronously here
	ENDMETHOD

	METHOD zif_async~callback.
		"add the data to be returned to the calling program here
		"collect any data into the static attributes
	ENDMETHOD

ENDCLASS.
```

## Utilization

### Simple asynchronous request

In order to implement our new async object in our code, all you need to do is create an instance of your new class and pass that object instance into the async framework `zcl_async_framework`.

To start an asynchronous process without dealing with a callback is as simple as calling a single method:

`zcl_async_framework=>async( lo_your_async_object ).`

DATA(lo\_update\_table\_async) = NEW lcl\_update\_table\_async( ).

zcl\_async\_framework=>async( lo\_update\_table\_async ).

### Using Objects within the Asynchronous Framework

If your implementation of the `process_async` method utilizes additional objects, you will need to make sure that these objects are serializable so that they can retain their data for during the asynchronous processing.

You can enable any object to be serializable for the async framework by simply adding the interface `zif_async_serializable`.
```abap
CLASS lcl_object_used_in_async DEFINITION.
	PUBLIC SECTION.

		INTERFACES:    
			zif_async_serializable.

	PROTECTED SECTION.
	PRIVATE SECTION.
ENDCLASS.
```

## Callback

### Definition

If your use case requires you to utilize the data that is returned from the asynchronous process, it is important to collect that data in an attribute that will retain any values returned from all of the different asynchronous threads that were processed. In order to retain the values, you should use a static attribute by defining it with `CLASS-DATA`.
```abap
CLASS lcl_update_table_async DEFINITION.
	PUBLIC SECTION.

		INTERFACES:
			zif_async.

	PROTECTED SECTION.
	PRIVATE SECTION.
		CLASS-DATA:
			lt\_totals TYPE STANDARD TABLE OF ty\_structure.
ENDCLASS.
```

### Implementation

The `callback` method is where you can optionally define any processing that would need to be completed after the asynchronous processing happens in `process_async`. Examples could be: setting an indicator to let the calling program know that an asynchronous process has been completed, aggregating results from multiple asynchronous requests, and other things that you can think of.

**One thing that should try to be avoided, is calling another asynchronous call within the callback. This could lead to confusion and performance implications. Additionally, SAP is not designed to be an asynchronous heavy language and therefore we should not push the boundaries too far as this could unnecessarily complicate our jobs with hard to find side effects.**
```abap
CLASS lcl_update_table_async IMPLEMENTATION.

	METHOD zif_async~process_async.
		"add your logic to be processed asynchronously here
	ENDMETHOD

	METHOD zif_async~callback.
		"add the data to be returned to the calling program here
		"collect any data into the static attributes
	ENDMETHOD

ENDCLASS.
```

### Utilization

If you need to utilize the callback functionality, you will need to call an additional method to trigger the callback and receive the response.

Calling the `await` method will pause further processing in your calling program to wait for the asynchronous request to complete and return a response before continuing on with processing.

The await method forces a `WAIT` statement, which is SAP's trigger to pause the current thread and looks at the other threads to see if an asynchronous call can be received. If you add a WAIT statement in your code, this will trigger a callback to be executed if available.
```abap
DATA(lo_update_table_async) = NEW lcl_update_table_async( ).

lo_update_table_async ?= zcl_async_framework=>async( lo\_update\_table\_async
										   )->await( ).

DATA(lt_data_from_callback) = lo_update_table_async->get_data( ).
```

### Error Handling

## Exception Class `zcx_async_error`

Error handling with the asynchronous framework works just like normal class based exceptions.

All exceptions raised from the asynchronous framework are placed into a `zcx_async_error` exception object, therefore you only have to worry about catching one singular exception.

Since all exceptions are contained within a `zcx_async_error` exception, in order to evaluate the specific error that happened you just need to use the `previous` attribute on the exception. This gives you access to the initial exception that was raised giving you insight into what exactly went wrong. 
```abap
TRY.

	. . .

CATCH zcx_async_error INTO DATA(lx_async_error).
	MESSAGE: lx_async_error->previous TYPE 'E'.
ENDTRY.
```

## Error Helpers

In addition to the standard functionality that class based exceptions give you, the `zcx_async_error` exception provides you with a `get_task( )` method. In cases of starting multiple asynchronous tasks at once, this method provides you with the extra information to help specify which parallel process the error occurred 
```abap
TRY.

	. . .

CATCH zcx_async_error INTO DATA(lx_async_error).
	WRITE: / lx_async_error->get_task( ).
ENDTRY.
```
