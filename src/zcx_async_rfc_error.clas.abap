CLASS zcx_async_rfc_error DEFINITION
  PUBLIC
  INHERITING FROM zcx_classic_to_class_based
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        !iv_text1 TYPE sylisel OPTIONAL
        !iv_text2 TYPE sylisel OPTIONAL
        !iv_text3 TYPE sylisel OPTIONAL
        !iv_text4 TYPE sylisel OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCX_ASYNC_RFC_ERROR IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous
        iv_text1 = iv_text1
        iv_text2 = iv_text2
        iv_text3 = iv_text3
        iv_text4 = iv_text4.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
