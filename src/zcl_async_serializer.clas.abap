CLASS zcl_async_serializer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS:
      deserialize
        IMPORTING
          !serialized_object  TYPE xml_strng
        RETURNING
          VALUE(async_object) TYPE REF TO zif_async ,

      serialize
        IMPORTING
          !async_object            TYPE REF TO zif_async
        RETURNING
          VALUE(serialized_object) TYPE xml_strng ,

      deserialize_error
        IMPORTING
          !serialized_error_object  TYPE string
        RETURNING
          VALUE(async_error_object) TYPE REF TO zcx_async_error,

      serialize_error
        IMPORTING
          !async_error_object            TYPE REF TO zcx_async_error
        RETURNING
          VALUE(serialized_error_object) TYPE xml_strng .
ENDCLASS.



CLASS zcl_async_serializer IMPLEMENTATION.


  METHOD deserialize.
    IF serialized_object <> space.
      CALL TRANSFORMATION id SOURCE XML serialized_object
                             RESULT oref = async_object.
    ENDIF.
  ENDMETHOD.


  METHOD serialize.
    CALL TRANSFORMATION id SOURCE oref = async_object
                       RESULT XML serialized_object.
  ENDMETHOD.

  METHOD deserialize_error.
    IF serialized_error_object <> space.
      CALL TRANSFORMATION id SOURCE XML serialized_error_object
                             RESULT oref = async_error_object.
    ENDIF.
  ENDMETHOD.

  METHOD serialize_error.
    CALL TRANSFORMATION id SOURCE oref = async_error_object
                       RESULT XML serialized_error_object.
  ENDMETHOD.

ENDCLASS.
