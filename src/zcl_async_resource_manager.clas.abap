CLASS zcl_async_resource_manager DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    INTERFACES:
      zif_async_resource_manager .

    CLASS-METHODS get_singleton
      RETURNING
        VALUE(resource_manager) TYPE REF TO zif_async_resource_manager .

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA:
      resource_manager TYPE REF TO zif_async_resource_manager,
      async_queue      TYPE TABLE OF REF TO zif_async_process.
ENDCLASS.



CLASS zcl_async_resource_manager IMPLEMENTATION.


  METHOD get_singleton.

    IF zcl_async_resource_manager=>resource_manager IS BOUND.
      resource_manager = zcl_async_resource_manager=>resource_manager.
      RETURN.
    ENDIF.

    resource_manager = zcl_async_resource_manager=>resource_manager = NEW zcl_async_resource_manager( ).

  ENDMETHOD.


  METHOD zif_async_resource_manager~add_to_queue.
    me->async_queue = VALUE #( BASE me->async_queue ( async_process ) ).
  ENDMETHOD.


  METHOD zif_async_resource_manager~is_resource_available.

    DATA: server_name TYPE rfcdest.

    CALL FUNCTION 'SPBT_PARALLEL_PROCESSING'
      EXPORTING
        group_name          = space
        rfc_function_module = 'ZZCL_ASYNC_GENERAL'
      IMPORTING
        server_name         = server_name
      EXCEPTIONS
        resource_failure    = 1.

    IF sy-subrc <> 0.
      resource_available = abap_false.
    ELSE.
      resource_available = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD zif_async_resource_manager~process_queue.

    DO.
      TRY.
          IF zif_async_resource_manager~is_resource_available( ) = abap_true.

            DATA(async_object_to_process) = me->async_queue[ 1 ].

            async_object_to_process->async( ).

            zif_async_resource_manager~remove_from_queue( async_object_to_process ).

          ELSE.
            WAIT UP TO 1 SECONDS.
          ENDIF.

          " Catch other exception for unable to process and/or unable to remove
        CATCH cx_sy_itab_line_not_found.
          EXIT.
      ENDTRY.
    ENDDO.

  ENDMETHOD.


  METHOD zif_async_resource_manager~remove_from_queue.
    DELETE me->async_queue WHERE table_line = async_process.
  ENDMETHOD.

ENDCLASS.
