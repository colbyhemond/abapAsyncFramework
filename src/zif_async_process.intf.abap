INTERFACE zif_async_process
  PUBLIC .


  METHODS async
    IMPORTING
      !async_object        TYPE REF TO zif_async OPTIONAL
    RETURNING
      VALUE(async_process) TYPE REF TO zif_async_process
    RAISING
      zcx_async_error.
  METHODS await
    RETURNING
      VALUE(response) TYPE REF TO zif_async
    RAISING
      zcx_async_error.
ENDINTERFACE.
