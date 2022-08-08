CLASS zcl_async_framework DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_async_framework_injector.

  PUBLIC SECTION.

    CLASS-METHODS async
      IMPORTING
        !async_object        TYPE REF TO zif_async
      RETURNING
        VALUE(async_process) TYPE REF TO zif_async_process
      RAISING
        zcx_async_error.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA go_async_process_double TYPE REF TO zif_async_process.
ENDCLASS.



CLASS zcl_async_framework IMPLEMENTATION.


  METHOD async.

    TRY.

          async_process =  COND #( WHEN go_async_process_double IS BOUND
                                              THEN go_async_process_double
                                            ELSE NEW zcl_async_process( zcl_async_resource_manager=>get_singleton( ) ) ).

          async_process->async(  async_object ).

      CATCH zcx_async_rfc_error INTO DATA(async_rfc_error).

        RAISE EXCEPTION TYPE zcx_async_error
          EXPORTING
            previous = async_rfc_error.

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
