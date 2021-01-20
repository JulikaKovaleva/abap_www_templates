class ZKJK_CL_WWW_FILES definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR .
  methods READ_FILES_LIST
    importing
      !IR_OBJID type ZKJK_TR_WWW_OBJID optional
      !IV_RELID type W3_RELID optional
    exporting
      !ET_WWW_FILES_LIST type ZKJK_TT_WWW_LIST .
  methods DOWNLOAD_ONE_AND_OPEN
    importing
      !IV_RELID type W3_RELID optional
      !IV_OBJID type W3OBJID .
  methods DOWNLOAD_ONE
    importing
      !IV_RELID type W3_RELID optional
      !IV_OBJID type W3OBJID
    exporting
      !EV_FILE_NAME type STRING .
  methods READ_FILE_INFO
    importing
      !IV_RELID type W3_RELID optional
      !IV_OBJID type W3OBJID
    exporting
      !ES_FILE_INFO type ZKJK_S_WWW_LIST .
  methods GET_FILE_DATA
    importing
      !IV_RELID type W3_RELID
      !IV_OBJID type W3OBJID
    exporting
      !ET_MIME type ZKJK_TT_W3MIME
      !EV_FILE_NAME type STRING .
  methods DOWNLOAD_ALL_AND_OPEN
    importing
      !IR_OBJID type ZKJK_TR_WWW_OBJID
      !IV_RELID type W3_RELID .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      mt_file_attributes TYPE RANGE OF w3_name .
    CONSTANTS mc_filepath TYPE w3_name VALUE 'filename' ##NO_TEXT.
    CONSTANTS mc_extension TYPE w3_name VALUE 'fileextension' ##NO_TEXT.
    CONSTANTS mc_relid TYPE w3_relid VALUE 'MI' ##NO_TEXT.
    CONSTANTS mc_filetype_bin TYPE char10 VALUE 'BIN' ##NO_TEXT.
*  constants MC_FILE_ATTRIBUTES type range of W3_NAME value .
ENDCLASS.



CLASS ZKJK_CL_WWW_FILES IMPLEMENTATION.
ENDCLASS.
