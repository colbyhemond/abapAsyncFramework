CLASS zcx_async_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES:
      if_t100_message,
      zif_async_serializable.

    METHODS:
      constructor
        IMPORTING
          !textid     LIKE if_t100_message=>t100key OPTIONAL
          !previous   LIKE previous OPTIONAL
          !async_task TYPE clike OPTIONAL,

      set_task
        IMPORTING
          !async_task TYPE clike,

      get_task
        RETURNING
          VALUE(async_task) TYPE string.


  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA async_task TYPE string.
ENDCLASS.



CLASS zcx_async_error IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
    me->async_task  = async_task.
  ENDMETHOD.


  METHOD set_task.
    me->async_task = async_task.
  ENDMETHOD.

  METHOD get_task.
    async_task = me->async_task.
  ENDMETHOD.

ENDCLASS.
