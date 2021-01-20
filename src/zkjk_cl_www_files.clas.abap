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


  METHOD constructor.

    "Зaполнение стрибута с именами параметров файлов для дальнейшей обработки
    mt_file_attributes = VALUE #( ( sign = 'I'
                                    option = 'EQ'
                                    low = mc_filepath )
                                  ( sign = 'I'
                                    option = 'EQ'
                                    low = mc_extension ) ).

  ENDMETHOD.


  METHOD download_all_and_open.

    DATA: lt_files_list TYPE zkjk_tt_www_list,
          lt_mime       TYPE zkjk_tt_w3mime,

          ls_key        TYPE wwwdatatab,

          lv_relid      TYPE w3_relid,
          lv_filename   TYPE string.

    IF iv_relid IS INITIAL.
      lv_relid = mc_relid.
    ELSE.
      lv_relid = iv_relid.
    ENDIF.

    "Чтение информации по фалам
    read_files_list( EXPORTING ir_objid = ir_objid
                               iv_relid = lv_relid
                     IMPORTING et_www_files_list = lt_files_list ).

    LOOP AT lt_files_list ASSIGNING FIELD-SYMBOL(<ls_files_list>).

      CLEAR: ls_key, lt_mime.

      "Для каждого файла получить данные и выгрузить
      ls_key-relid = lv_relid.
      ls_key-objid = <ls_files_list>-objid.

      CALL FUNCTION 'WWWDATA_IMPORT'
        EXPORTING
          key    = ls_key
        TABLES
          mime   = lt_mime
        EXCEPTIONS
          OTHERS = 99.

      lv_filename = <ls_files_list>-objid && <ls_files_list>-fileextension.

      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename = lv_filename
          filetype = mc_filetype_bin
        TABLES
          data_tab = lt_mime.

      "открыть скачанный файл
      cl_gui_frontend_services=>execute(
        EXPORTING
          document               = lv_filename
          synchronous            = ''  "открыть и пойти дальше, не ждать пока закроют
        EXCEPTIONS
          cntl_error             = 1
          error_no_gui           = 2
          bad_parameter          = 3
          file_not_found         = 4
          path_not_found         = 5
          file_extension_unknown = 6
          error_execute_failed   = 7
          synchronous_failed     = 8
          not_supported_by_gui   = 9
          OTHERS                 = 10
          ).
      IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD download_one.

    DATA:
      lt_mime      TYPE zkjk_tt_w3mime,

      lv_file_name TYPE string.

    get_file_data( EXPORTING iv_relid = iv_relid
                             iv_objid = iv_objid
                   IMPORTING et_mime = lt_mime
                             ev_file_name = ev_file_name ).

    "скачать файл
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename = ev_file_name
        filetype = mc_filetype_bin
      TABLES
        data_tab = lt_mime.

  ENDMETHOD.


  METHOD download_one_and_open.

    DATA:
      lv_file_name TYPE string.

    download_one( EXPORTING iv_relid = iv_relid
                            iv_objid = iv_objid
                  IMPORTING ev_file_name = lv_file_name ).

*    Открыть файл
    cl_gui_frontend_services=>execute(
      EXPORTING
        document               = lv_file_name
        synchronous            = ''  "открыть и пойти дальше, не ждать пока закроют
      EXCEPTIONS
        cntl_error             = 1
        error_no_gui           = 2
        bad_parameter          = 3
        file_not_found         = 4
        path_not_found         = 5
        file_extension_unknown = 6
        error_execute_failed   = 7
        synchronous_failed     = 8
        not_supported_by_gui   = 9
        OTHERS                 = 10
    ).
    IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.


  METHOD get_file_data.

    DATA:
      ls_file_info TYPE zkjk_s_www_list,
      ls_key       TYPE wwwdatatab.

    "Получить данные по файлу
    read_file_info( EXPORTING iv_relid = iv_relid
                              iv_objid = iv_objid
                    IMPORTING es_file_info = ls_file_info ).

    "Сформировать имя файла
    ev_file_name = ls_file_info-objid && ls_file_info-fileextension.

    MOVE-CORRESPONDING ls_file_info TO ls_key.

    "Выбрать данные по файлу
    CALL FUNCTION 'WWWDATA_IMPORT'
      EXPORTING
        key    = ls_key
      TABLES
        mime   = et_mime
      EXCEPTIONS
        OTHERS = 99.

  ENDMETHOD.


  METHOD read_files_list.

    DATA:
      lv_relid          TYPE w3_relid,

      lt_wwwparams      TYPE TABLE OF wwwparams,

      ls_www_files_list LIKE LINE OF et_www_files_list.

    "Получить список шаблонов
    IF iv_relid IS NOT INITIAL.
      lv_relid = iv_relid.
    ELSE.
      lv_relid = mc_relid.
    ENDIF.

    SELECT *
      FROM wwwparams
      INTO TABLE @lt_wwwparams
      WHERE relid = @lv_relid
        AND objid IN @ir_objid "если не подадут, будет пустой и выберется все
        AND name IN @mt_file_attributes.

    LOOP AT lt_wwwparams ASSIGNING FIELD-SYMBOL(<ls_wwwparams>).
      READ TABLE et_www_files_list ASSIGNING FIELD-SYMBOL(<ls_www_files>)
        WITH TABLE KEY relid = lv_relid
                       objid = <ls_wwwparams>.
      IF sy-subrc  IS NOT INITIAL.
        "Значит строки еще нет, надо добавить
        CLEAR ls_www_files_list.
        ls_www_files_list-relid = lv_relid.
        ls_www_files_list-objid = <ls_wwwparams>-objid.
        INSERT ls_www_files_list INTO TABLE et_www_files_list.
        "Связать филдсимвол с только что вставленной строкой для дальнейшего заполнения неключевых полей
        ASSIGN et_www_files_list[ sy-tabix ] TO <ls_www_files>.
      ENDIF.

      "для найденной/вставленной строки заполнить текущий параметр (имена полей в выходной таблице совпадают с именами параметров в таблице БД)
      ASSIGN COMPONENT <ls_wwwparams>-name OF STRUCTURE <ls_www_files> TO FIELD-SYMBOL(<lv_comp>).
      IF sy-subrc IS INITIAL.
        <lv_comp> = <ls_wwwparams>-value.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD read_file_info.

    DATA:
      lv_relid     TYPE w3_relid,

      lt_wwwparams TYPE TABLE OF wwwparams.

    IF iv_relid IS INITIAL.
      lv_relid = mc_relid.
    ELSE.
      lv_relid = iv_relid.
    ENDIF.

    "Получить параметры файла из таблицы
    SELECT *
      FROM wwwparams
      INTO TABLE @lt_wwwparams
      WHERE relid = @lv_relid
        AND objid = @iv_objid
        AND name IN @mt_file_attributes.

    es_file_info-relid = lv_relid.
    es_file_info-objid = iv_objid.

    "распарсить данные в выходную структуру
    LOOP AT lt_wwwparams ASSIGNING FIELD-SYMBOL(<ls_params>).
      ASSIGN COMPONENT <ls_params>-name OF STRUCTURE es_file_info TO FIELD-SYMBOL(<lv_comp>).
      IF sy-subrc IS INITIAL.
        <lv_comp> = <ls_params>-value.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
