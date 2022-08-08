CLASS zcl_async_framework_injector DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS:
      inject_async_process
        IMPORTING
          async_process_test_double TYPE REF TO zif_async_process.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_async_framework_injector IMPLEMENTATION.

  METHOD inject_async_process.
    zcl_async_framework=>go_async_process_double = async_process_test_double.
  ENDMETHOD.

ENDCLASS.
