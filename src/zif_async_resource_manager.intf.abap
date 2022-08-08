INTERFACE zif_async_resource_manager
  PUBLIC .


  METHODS add_to_queue
    IMPORTING
      !async_process TYPE REF TO zif_async_process .
  METHODS remove_from_queue
    IMPORTING
      !async_process TYPE REF TO zif_async_process .
  METHODS is_resource_available
    RETURNING
      VALUE(resource_available) TYPE abap_bool .
  METHODS process_queue
    RAISING zcx_async_error.
ENDINTERFACE.
