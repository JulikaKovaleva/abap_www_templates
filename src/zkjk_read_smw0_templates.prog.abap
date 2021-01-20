*&---------------------------------------------------------------------*
*& Report ZKJK_READ_SMW0_TEMPLATES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkjk_read_smw0_templates.

DATA: ls_key      TYPE wwwdatatab,

      lt_mime     TYPE STANDARD TABLE OF w3mime WITH HEADER LINE,

      lv_filename TYPE string,
      lv_ext(10)  TYPE c.

ls_key-relid = 'MI'.
ls_key-objid = 'ZWWW'.


CALL FUNCTION 'WWWDATA_IMPORT'
  EXPORTING
    key    = ls_key
  TABLES
    mime   = lt_mime
  EXCEPTIONS
    OTHERS = 99.

CALL FUNCTION 'WWWPARAMS_READ'
  EXPORTING
    relid  = 'MI'
    objid  = 'ZWWW'
    name   = 'fileextension'
  IMPORTING
    value  = lv_ext
  EXCEPTIONS
    OTHERS = 1.

lv_filename = ls_key-objid && lv_ext.

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    filename = lv_filename
    filetype = 'BIN'
  TABLES
    data_tab = lt_mime[].
