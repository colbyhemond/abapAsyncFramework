FUNCTION ZZCL_ASYNC_GENERAL.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PROCESS_OBJECT_SERIALIZED) TYPE  XML_STRNG
*"  EXPORTING
*"     VALUE(CALLBACK_OBJECT_SERIALIZED) TYPE  XML_STRNG
*"     VALUE(ERROR_OBJECT_SERIALIZED) TYPE  XML_STRNG
*"----------------------------------------------------------------------
  .

  TRY.

      DATA(async_object) = zcl_async_serializer=>deserialize( process_object_serialized ).

      IF async_object IS BOUND.
        async_object->perform_async(  ).
        callback_object_serialized = zcl_async_serializer=>serialize( async_object ).
      ELSE.

      ENDIF.

    CATCH cx_root INTO DATA(lx_root).

      DATA(lx_async_error) = NEW zcx_async_error( previous = lx_root ).

      error_object_serialized = zcl_async_serializer=>serialize_error( lx_async_error ).

  ENDTRY.

ENDFUNCTION.
