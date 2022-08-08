CLASS zcl_async_process DEFINITION
  PUBLIC
  FINAL
  CREATE PROTECTED

  GLOBAL FRIENDS zcl_async_framework.

  PUBLIC SECTION.

    INTERFACES:
      zif_async_process.

    METHODS:
      callback_handler
        IMPORTING
          !p_task TYPE clike
        RAISING
          zcx_async_error,

      constructor
        IMPORTING
          !resource_manager TYPE REF TO zif_async_resource_manager .

  PROTECTED SECTION.

    METHODS:
      set_async_object
        IMPORTING
          !async_object   TYPE REF TO zif_async
        RETURNING
          VALUE(response) TYPE REF TO zcl_async_process ,

      start_async_thread
        RETURNING
          VALUE(async_process) TYPE REF TO zif_async_process
        RAISING
          zcx_async_error.

  PRIVATE SECTION.

    CLASS-DATA:
      task_id TYPE i,
      error   TYPE REF TO zcx_async_error.

    DATA:
      async_object      TYPE REF TO zif_async,
      result            TYPE abap_bool VALUE abap_false ##NO_TEXT,
      serialized_object TYPE xml_strng,
      resource_manager  TYPE REF TO zif_async_resource_manager.

    METHODS:
      set_serialized_object
        IMPORTING
          !serialized_object TYPE xml_strng ,

      set_error
        IMPORTING
          error_object TYPE REF TO zcx_async_error,

      get_error
        RETURNING
          VALUE(error) TYPE REF TO zcx_async_error.

ENDCLASS.



CLASS zcl_async_process IMPLEMENTATION.


  METHOD callback_handler.

    DATA: serialized_callback_object TYPE xml_strng,
          serialized_error_object    TYPE xml_strng.

    TRY.

        TRY.

            RECEIVE RESULTS FROM FUNCTION 'ZZCL_ASYNC_GENERAL'
                IMPORTING
                    callback_object_serialized = serialized_callback_object
                    error_object_serialized = serialized_error_object
                EXCEPTIONS
                    communication_failure = 1
                    system_failure = 2 "This gets raised for short dumps, should this abend at calling program or should the developer decide how to handle
                    OTHERS = 3.

            IF sy-subrc > 0.
              RAISE EXCEPTION TYPE zcx_async_rfc_error
                EXPORTING
                  textid   = VALUE scx_t100key( msgid = sy-msgid
                                                msgno = sy-msgno
                                                attr1 = `GV_TEXT1`
                                                attr2 = `GV_TEXT2`
                                                attr3 = `GV_TEXT3`
                                                attr4 = `GV_TEXT4` )
                  iv_text1 = CONV #( sy-msgv1 )
                  iv_text2 = CONV #( sy-msgv2 )
                  iv_text3 = CONV #( sy-msgv3 )
                  iv_text4 = CONV #( sy-msgv4 ).
            ENDIF.

            DATA(async_object) = zcl_async_serializer=>deserialize( serialized_callback_object ).
            DATA(error_object) = zcl_async_serializer=>deserialize_error( serialized_error_object ).

            IF error_object IS BOUND.
              RAISE EXCEPTION TYPE zcx_async_error
                EXPORTING
                  previous   = error_object
                  async_task = p_task.
            ENDIF.

            IF async_object IS BOUND.
              set_async_object( async_object ).
              async_object->callback( ).
            ENDIF.

          CATCH zcx_async_rfc_error INTO DATA(lx_rfc_error).
            RAISE EXCEPTION TYPE zcx_async_error
              EXPORTING
                previous   = lx_rfc_error
                async_task = p_task.
        ENDTRY.

      CATCH zcx_async_error INTO DATA(lx_async_error).
        "Cannot raise error from the callback method as it cannot be caught by calling program
        "This error object is set in a private attribute to be checked and raised from await( ) method
        set_error( lx_async_error ).
    ENDTRY.

  ENDMETHOD.


  METHOD constructor.
    me->resource_manager = resource_manager.
  ENDMETHOD.


  METHOD set_async_object.
    me->async_object = async_object.
    set_serialized_object( zcl_async_serializer=>serialize( async_object ) ).
    response = me.
  ENDMETHOD.


  METHOD set_serialized_object.
    me->serialized_object = serialized_object.
  ENDMETHOD.


  METHOD start_async_thread.

    IF me->resource_manager->is_resource_available( ) = abap_true.

      me->task_id = me->task_id + 1.

      DATA(taskname) = |async_task_{ me->task_id }|.

      CALL FUNCTION 'ZZCL_ASYNC_GENERAL'
        STARTING NEW TASK taskname
        DESTINATION IN GROUP DEFAULT
        CALLING callback_handler ON END OF TASK
        EXPORTING
          process_object_serialized = me->serialized_object
        EXCEPTIONS
          communication_failure     = 1
          resource_failure          = 2
          system_failure            = 3
          OTHERS                    = 4.

      CASE sy-subrc.
        WHEN 0.
          "Successful - Continue Processing
        WHEN 1.
          me->resource_manager->add_to_queue( me ).
        WHEN 2.
          me->resource_manager->add_to_queue( me ).
        WHEN OTHERS.
          TRY.
              RAISE EXCEPTION TYPE zcx_async_rfc_error
                EXPORTING
                  textid   = VALUE scx_t100key( msgid = sy-msgid
                                                msgno = sy-msgno
                                                attr1 = `GV_TEXT1`
                                                attr2 = `GV_TEXT2`
                                                attr3 = `GV_TEXT3`
                                                attr4 = `GV_TEXT4` )
                  iv_text1 = CONV #( sy-msgv1 )
                  iv_text2 = CONV #( sy-msgv2 )
                  iv_text3 = CONV #( sy-msgv3 )
                  iv_text4 = CONV #( sy-msgv4 ).

            CATCH zcx_async_rfc_error INTO DATA(lx_async_rfc_error).

              RAISE EXCEPTION TYPE zcx_async_error
                EXPORTING
                  previous   = lx_async_rfc_error
                  async_task = taskname.

          ENDTRY.
      ENDCASE.

    ELSE.

      me->resource_manager->add_to_queue( me ).

    ENDIF.

    async_process = me.

  ENDMETHOD.


  METHOD zif_async_process~async.

    async_process = me.

    IF async_object IS BOUND.
      me->set_async_object( async_object ).
    ENDIF.

    me->start_async_thread( ).

  ENDMETHOD.


  METHOD zif_async_process~await.

    me->resource_manager->process_queue( ).
    WAIT FOR ASYNCHRONOUS TASKS UNTIL me->result = abap_true.
    response = me->async_object.

    IF me->error IS BOUND.

      TRY.
          DATA(source_exception) = me->error->previous.
          DO.
            IF source_exception->previous IS BOUND.
              source_exception = source_exception->previous.
            ELSE.
              EXIT.
            ENDIF.
          ENDDO.
        CATCH cx_sy_message_illegal_text.
          "source_exception should already be assigned
      ENDTRY.

      RAISE EXCEPTION TYPE zcx_async_error
        EXPORTING
          previous   = source_exception
          async_task = me->error->get_task( ).

    ENDIF.

  ENDMETHOD.

  METHOD set_error.
    me->error = error_object.
  ENDMETHOD.

  METHOD get_error.
    error = me->error.
  ENDMETHOD.

ENDCLASS.
