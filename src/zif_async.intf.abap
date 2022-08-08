INTERFACE zif_async
  PUBLIC .


  INTERFACES if_serializable_object .

  METHODS perform_async
    RAISING
      cx_static_check.
  METHODS callback.
ENDINTERFACE.
