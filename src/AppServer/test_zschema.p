&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win
/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created:

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* *************************** Temp-Tables Definitions **********************************/
DEFINE TEMP-TABLE tt-db NO-UNDO
    FIELD cDb                     AS CHARACTER FORMAT "X(30)"
    FIELD cDesc                   AS CHARACTER FORMAT "X(30)"
    INDEX iDb cDb.
    .

DEFINE TEMP-TABLE tt-table NO-UNDO
    FIELD cDb                     AS CHARACTER FORMAT "X(30)"
    FIELD cTable                  AS CHARACTER FORMAT "X(40)"
    FIELD cDesc                   AS CHARACTER FORMAT "X(100)"
    INDEX iTabel cDb cTable.
    .

DEFINE TEMP-TABLE tt-field NO-UNDO
    FIELD cDb                     AS CHARACTER FORMAT "X(30)"
    FIELD cTable                  AS CHARACTER FORMAT "X(30)"
    FIELD cField                  AS CHARACTER FORMAT "X(100)"
    FIELD cDataType               AS CHARACTER FORMAT "X(10)"
    FIELD cFormat                 AS CHARACTER FORMAT "X(30)"
    FIELD cOrder                  AS CHARACTER FORMAT "X(20)"
    FIELD cDesc                   AS CHARACTER FORMAT "X(100)"
    FIELD cExtent                 AS CHARACTER FORMAT "X(5)"
    FIELD cMandatory              AS CHARACTER FORMAT "X(5)"
    FIELD cInitValue              AS CHARACTER FORMAT "X(50)"
    FIELD cValidation             AS CHARACTER FORMAT "X(500)"
    FIELD cValidationMsg          AS CHARACTER FORMAT "X(500)"
    INDEX iField cDb cTable cField cOrder
    .

DEFINE TEMP-TABLE tt-index NO-UNDO
    FIELD cDb                     AS CHARACTER FORMAT "X(30)"
    FIELD cTable                  AS CHARACTER FORMAT "X(30)"
    FIELD cIndex                  AS CHARACTER FORMAT "X(100)"
    FIELD cType                   AS CHARACTER FORMAT "X(6)"
    FIELD cOrder                  AS INTEGER
    INDEX iIndex cDb cTable cOrder cIndex
    .

DEFINE TEMP-TABLE tt-indexField NO-UNDO
    FIELD cDb                     AS CHARACTER FORMAT "X(30)"
    FIELD cTable                  AS CHARACTER FORMAT "X(30)"
    FIELD cIndex                  AS CHARACTER FORMAT "X(40)"
    FIELD cIndexField             AS CHARACTER FORMAT "X(100)"
    FIELD iOrder                  AS INTEGER
    FIELD lAscending             AS LOGICAL
    INDEX iField cDb cTable cIndex iOrder
    .

DEFINE TEMP-TABLE tt-Filter NO-UNDO
    FIELD cField                  AS CHARACTER FORMAT "X(50)"
    FIELD cFrom                   AS CHARACTER FORMAT "X(30)"
    FIELD cTo                     AS CHARACTER FORMAT "X(30)"
    FIELD cContains               AS CHARACTER FORMAT "X(30)"
    .

DEFINE TEMP-TABLE tt-NonVisibleColumns NO-UNDO
    FIELD cTable                  AS CHARACTER FORMAT "X(30)"
    FIELD cField                  AS CHARACTER FORMAT "X(50)"
    .

DEFINE TEMP-TABLE tt-VisibleColumns NO-UNDO
    FIELD cTable                  AS CHARACTER FORMAT "X(30)"
    FIELD cField                  AS CHARACTER FORMAT "X(50)"
    .

/* *************************** Variables definitions *************************************/
DEFINE VARIABLE hBuf                AS HANDLE               NO-UNDO.
DEFINE VARIABLE cTableRecid         AS CHARACTER            NO-UNDO.
DEFINE VARIABLE cIndexRecid         AS CHARACTER            NO-UNDO.
DEFINE VARIABLE v-mod               AS CHARACTER            NO-UNDO.

DEFINE VARIABLE hbr-Data            AS HANDLE               NO-UNDO.
DEFINE VARIABLE hqueryData          AS HANDLE               NO-UNDO.
DEFINE VARIABLE hBufTable           AS HANDLE               NO-UNDO.
DEFINE VARIABLE v-rowid             AS ROWID                NO-UNDO.
DEFINE VARIABLE cQueryDataString    AS CHARACTER            NO-UNDO  INIT ''.
DEFINE VARIABLE cSortDataString     AS CHARACTER            NO-UNDO  INIT ''.
DEFINE VARIABLE cDataWhereClause    AS CHARACTER            NO-UNDO  INIT ''.
DEFINE VARIABLE hMenu               AS HANDLE               NO-UNDO.
DEFINE VARIABLE hSearchable         AS HANDLE               NO-UNDO.
DEFINE VARIABLE hMovable            AS HANDLE               NO-UNDO.
DEFINE VARIABLE hShowData           AS HANDLE               NO-UNDO.
DEFINE VARIABLE nrColumn            AS INTEGER              NO-UNDO.
DEFINE VARIABLE cLastSelectedTable  AS CHARACTER            NO-UNDO  INIT ''.
DEFINE VARIABLE cChangedRecords     AS CHARACTER            NO-UNDO  INIT ''. /* list with the rowids of last changed records */
DEFINE VARIABLE i                   AS INTEGER              NO-UNDO.
DEFINE VARIABLE hbr-Filter          AS HANDLE              NO-UNDO.
DEFINE VARIABLE v-dbNameError      AS LOGICAL              NO-UNDO.

DEFINE VARIABLE hcol                AS HANDLE  EXTENT 1000  NO-UNDO.
DEFINE VARIABLE hw-visField         AS HANDLE  EXTENT 1000  NO-UNDO.

/* *************************** Buffers definitions ***********************************/
DEFINE BUFFER buf-tt-Columns FOR tt-VisibleColumns.

/* *************************** Constants definition **********************************/
&SCOPED-DEFINE FRAME-COLUMNS-WIDTH        123
&SCOPED-DEFINE FRAME-COLUMNS-ROW          4.33
&SCOPED-DEFINE FRAME-COLUMNS-COL          57
&SCOPED-DEFINE BUTTON-FREEQUERY-WIDTH     12
&SCOPED-DEFINE EDITOR-FREEQUERY-COL       32
&SCOPED-DEFINE FRAME-COLUMNS-HEIGHT       8.8

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME br-AllColumns

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-NonVisibleColumns tt-db tt-Field ~
tt-Filter tt-index tt-indexField tt-Table tt-VisibleColumns

/* Definitions for BROWSE br-AllColumns                                 */
&Scoped-define FIELDS-IN-QUERY-br-AllColumns tt-NonVisibleColumns.cField
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-AllColumns
&Scoped-define SELF-NAME br-AllColumns
&Scoped-define QUERY-STRING-br-AllColumns FOR EACH tt-NonVisibleColumns       WHERE tt-NonVisibleColumns.cTable      =  cLastSelectedTable       NO-LOCK BY tt-NonVisibleColumns.cField
&Scoped-define OPEN-QUERY-br-AllColumns OPEN QUERY {&SELF-NAME}    FOR EACH tt-NonVisibleColumns       WHERE tt-NonVisibleColumns.cTable      =  cLastSelectedTable       NO-LOCK BY tt-NonVisibleColumns.cField.
&Scoped-define TABLES-IN-QUERY-br-AllColumns tt-NonVisibleColumns
&Scoped-define FIRST-TABLE-IN-QUERY-br-AllColumns tt-NonVisibleColumns


/* Definitions for BROWSE br-db                                         */
&Scoped-define FIELDS-IN-QUERY-br-db tt-db.cDb tt-db.cDesc
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-db
&Scoped-define SELF-NAME br-db
&Scoped-define QUERY-STRING-br-db FOR EACH tt-db
&Scoped-define OPEN-QUERY-br-db OPEN QUERY {&SELF-NAME} FOR EACH tt-db.
&Scoped-define TABLES-IN-QUERY-br-db tt-db
&Scoped-define FIRST-TABLE-IN-QUERY-br-db tt-db


/* Definitions for BROWSE br-Field                                      */
&Scoped-define FIELDS-IN-QUERY-br-Field tt-field.cField tt-field.cDataType tt-field.cFormat tt-field.cExtent tt-field.cDesc tt-field.cMandatory tt-field.cInitValue tt-field.cValidation tt-field.cValidationMsg
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-Field ALL
&Scoped-define SELF-NAME br-Field
&Scoped-define QUERY-STRING-br-Field FOR EACH tt-Field BY tt-field.cField
&Scoped-define OPEN-QUERY-br-Field OPEN QUERY {&SELF-NAME} FOR EACH tt-Field BY tt-field.cField.
&Scoped-define TABLES-IN-QUERY-br-Field tt-Field
&Scoped-define FIRST-TABLE-IN-QUERY-br-Field tt-Field


/* Definitions for BROWSE br-Filter                                     */
&Scoped-define FIELDS-IN-QUERY-br-Filter tt-Filter.cField tt-Filter.cFrom tt-Filter.cTo tt-Filter.cContains
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-Filter ALL ~
  /*EXCEPT tt-filter.cField*/
&Scoped-define ENABLED-TABLES-IN-QUERY-br-Filter tt-filter
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-Filter tt-filter
&Scoped-define SELF-NAME br-Filter
&Scoped-define QUERY-STRING-br-Filter FOR EACH tt-Filter BY tt-Filter.cField
&Scoped-define OPEN-QUERY-br-Filter OPEN QUERY {&SELF-NAME} FOR EACH tt-Filter BY tt-Filter.cField.
&Scoped-define TABLES-IN-QUERY-br-Filter tt-Filter
&Scoped-define FIRST-TABLE-IN-QUERY-br-Filter tt-Filter


/* Definitions for BROWSE br-index                                      */
&Scoped-define FIELDS-IN-QUERY-br-index tt-index.cIndex tt-index.cType
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-index
&Scoped-define SELF-NAME br-index
&Scoped-define QUERY-STRING-br-index FOR EACH tt-index
&Scoped-define OPEN-QUERY-br-index OPEN QUERY {&SELF-NAME} FOR EACH tt-index.
&Scoped-define TABLES-IN-QUERY-br-index tt-index
&Scoped-define FIRST-TABLE-IN-QUERY-br-index tt-index


/* Definitions for BROWSE br-indexField                                 */
&Scoped-define FIELDS-IN-QUERY-br-indexField tt-IndexField.cIndexField tt-IndexField.lAscending
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-indexField ALL
&Scoped-define SELF-NAME br-indexField
&Scoped-define QUERY-STRING-br-indexField FOR EACH tt-indexField
&Scoped-define OPEN-QUERY-br-indexField OPEN QUERY {&SELF-NAME} FOR EACH tt-indexField.
&Scoped-define TABLES-IN-QUERY-br-indexField tt-indexField
&Scoped-define FIRST-TABLE-IN-QUERY-br-indexField tt-indexField


/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table tt-Table.cTable tt-Table.cDesc
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table tt-Table.cDesc
&Scoped-define ENABLED-TABLES-IN-QUERY-br-table tt-Table
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-table tt-Table
&Scoped-define SELF-NAME br-table
&Scoped-define QUERY-STRING-br-table FOR EACH tt-Table
&Scoped-define OPEN-QUERY-br-table OPEN QUERY {&SELF-NAME} FOR EACH tt-Table .
&Scoped-define TABLES-IN-QUERY-br-table tt-Table
&Scoped-define FIRST-TABLE-IN-QUERY-br-table tt-Table


/* Definitions for BROWSE br-VisibleColumns                             */
&Scoped-define FIELDS-IN-QUERY-br-VisibleColumns tt-VisibleColumns.cField
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-VisibleColumns
&Scoped-define SELF-NAME br-VisibleColumns
&Scoped-define QUERY-STRING-br-VisibleColumns FOR EACH tt-VisibleColumns       WHERE tt-VisibleColumns.cTable = cLastSelectedTable       NO-LOCK BY tt-VisibleColumns.cField
&Scoped-define OPEN-QUERY-br-VisibleColumns OPEN QUERY {&SELF-NAME}    FOR EACH tt-VisibleColumns       WHERE tt-VisibleColumns.cTable = cLastSelectedTable       NO-LOCK BY tt-VisibleColumns.cField.
&Scoped-define TABLES-IN-QUERY-br-VisibleColumns tt-VisibleColumns
&Scoped-define FIRST-TABLE-IN-QUERY-br-VisibleColumns tt-VisibleColumns


/* Definitions for FRAME frm-Columns                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frm-Columns ~
    ~{&OPEN-QUERY-br-AllColumns}~
    ~{&OPEN-QUERY-br-VisibleColumns}

/* Definitions for FRAME frm-data                                       */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frm-data ~
    ~{&OPEN-QUERY-br-Filter}

/* Definitions for FRAME frm-schema                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frm-schema ~
    ~{&OPEN-QUERY-br-db}~
    ~{&OPEN-QUERY-br-Field}~
    ~{&OPEN-QUERY-br-index}~
    ~{&OPEN-QUERY-br-indexField}~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 btn-view

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GetTableRecid C-Win
FUNCTION GetTableRecid RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isCorrectDataType C-Win
FUNCTION isCorrectDataType RETURNS LOGICAL
    ( INPUT p-field     AS CHARACTER,
    INPUT p-data_type AS CHARACTER
    )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btn-view
    LABEL "&Data"
    SIZE 14 BY 1.

DEFINE RECTANGLE RECT-1
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
    SIZE 178 BY 1.57.

DEFINE BUTTON btn-Deselect
    LABEL "<-"
    SIZE 15 BY 1.05.

DEFINE BUTTON btn-DeselectAll
    LABEL "<<-"
    SIZE 15 BY 1.05.

DEFINE BUTTON btn-Ok
    LABEL "Ok"
    SIZE 13 BY 1.05.

DEFINE BUTTON btn-Select
    LABEL "->"
    SIZE 15 BY 1.05.

DEFINE BUTTON btn-SelectAll
    LABEL "->>"
    SIZE 15 BY 1.05.

DEFINE BUTTON bntAdd
    LABEL "Add"
    SIZE 14 BY .95.

DEFINE BUTTON btn-FreeQuery
    LABEL "Free Query"
    SIZE 12 BY 1.91.

DEFINE BUTTON btn-Refresh
    LABEL "Refresh"
    SIZE 14 BY .95.

DEFINE BUTTON btn-save
    LABEL "Save"
    SIZE 14 BY .95.

DEFINE BUTTON btnDelete
    LABEL "Delete"
    SIZE 14 BY .95.

DEFINE VARIABLE ed-FreeQuery AS CHARACTER
    VIEW-AS EDITOR MAX-CHARS 10000 SCROLLBAR-VERTICAL
    SIZE 135 BY 1.91 NO-UNDO.

DEFINE BUTTON btn_RecNo
    LABEL "Records No"
    SIZE 14 BY .95.


DEFINE VARIABLE w-recNo AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 12 BY .95 NO-UNDO.

DEFINE VARIABLE w-SearchFilterField AS CHARACTER FORMAT "X(100)":U
    VIEW-AS FILL-IN
    SIZE 15 BY 1.19 NO-UNDO.

DEFINE RECTANGLE RECT-4
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
    SIZE 162 BY 1.19.

DEFINE VARIABLE w-FieldSearch AS CHARACTER FORMAT "X(256)":U
    LABEL "Field search"
    VIEW-AS FILL-IN
    SIZE 24 BY .95 NO-UNDO.

DEFINE VARIABLE w-SearchFieldName AS CHARACTER FORMAT "X(100)":U
    VIEW-AS FILL-IN
    SIZE 30 BY .95 NO-UNDO.

DEFINE VARIABLE w-tableSearch AS CHARACTER FORMAT "X(256)":U
    LABEL "Table Search"
    VIEW-AS FILL-IN
    SIZE 24 BY .95 NO-UNDO.

DEFINE RECTANGLE RECT-2
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
    SIZE 38 BY .24.

DEFINE RECTANGLE RECT-3
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
    SIZE 146 BY .95.

DEFINE VARIABLE w-FieldMatches AS LOGICAL INITIAL NO
    LABEL "Matches"
    VIEW-AS TOGGLE-BOX
    SIZE 13.4 BY .81 NO-UNDO.

DEFINE VARIABLE w-HiddenTable AS LOGICAL INITIAL NO
    LABEL "Hidden"
    VIEW-AS TOGGLE-BOX
    SIZE 13.4 BY .81 NO-UNDO.

DEFINE VARIABLE w-TableBegins AS LOGICAL INITIAL NO
    LABEL "Begins"
    VIEW-AS TOGGLE-BOX
    SIZE 13.4 BY .81 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-AllColumns FOR
    tt-NonVisibleColumns SCROLLING.

DEFINE QUERY br-db FOR
    tt-db SCROLLING.

DEFINE QUERY br-Field FOR
    tt-Field SCROLLING.

DEFINE QUERY br-Filter FOR
    tt-Filter SCROLLING.

DEFINE QUERY br-index FOR
    tt-index SCROLLING.

DEFINE QUERY br-indexField FOR
    tt-indexField SCROLLING.

DEFINE QUERY br-table FOR
    tt-Table SCROLLING.

DEFINE QUERY br-VisibleColumns FOR
    tt-VisibleColumns SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-AllColumns
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-AllColumns C-Win _FREEFORM
    QUERY br-AllColumns NO-LOCK DISPLAY
    tt-NonVisibleColumns.cField  LABEL 'Not visible columns'
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 41 BY 6.52 FIT-LAST-COLUMN.

DEFINE BROWSE br-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-db C-Win _FREEFORM
    QUERY br-db DISPLAY
    tt-db.cDb    COLUMN-LABEL 'Database'    FORMAT "x(17)"
    tt-db.cDesc  COLUMN-LABEL 'Type'
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 38 BY 5 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE br-Field
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-Field C-Win _FREEFORM
    QUERY br-Field DISPLAY
    tt-field.cField            COLUMN-LABEL 'Field'             WIDTH 25
    tt-field.cDataType         COLUMN-LABEL 'Data type'         WIDTH 10
    tt-field.cFormat           COLUMN-LABEL 'Format'            WIDTH 15
    tt-field.cExtent           COLUMN-LABEL 'Extent'            WIDTH 10
    tt-field.cDesc            COLUMN-LABEL 'Description'       WIDTH 40
    tt-field.cMandatory        COLUMN-LABEL 'Mandatory'         WIDTH 10
    tt-field.cInitValue        COLUMN-LABEL 'Initial value'     WIDTH 11
    tt-field.cValidation      COLUMN-LABEL 'Validation'        WIDTH 30
    tt-field.cValidationMsg    COLUMN-LABEL 'Validation msg'    WIDTH 40

ENABLE ALL
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 177.2 BY 17.52 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE br-Filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-Filter C-Win _FREEFORM
    QUERY br-Filter DISPLAY
    tt-Filter.cField          COLUMN-LABEL 'Field'           WIDTH 15
    tt-Filter.cFrom           COLUMN-LABEL 'From'            WIDTH 10
    tt-Filter.cTo             COLUMN-LABEL 'To'              WIDTH 10
    tt-Filter.cContains       COLUMN-LABEL 'Contains'        WIDTH 20

   ENABLE ALL
         /*EXCEPT tt-filter.cField*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 55 BY 27.14 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE br-index
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-index C-Win _FREEFORM
    QUERY br-index DISPLAY
    tt-index.cIndex   COLUMN-LABEL 'Index' FORMAT 'x(27)'
    tt-index.cType    COLUMN-LABEL 'Type'
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 42 BY 11.43 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE br-indexField
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-indexField C-Win _FREEFORM
    QUERY br-indexField DISPLAY
    tt-IndexField.cIndexField    COLUMN-LABEL "Index Fields" WIDTH 20
    tt-IndexField.lAscending     COLUMN-LABEL "Ascending"
ENABLE ALL
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 35.4 BY 11.43 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table C-Win _FREEFORM
    QUERY br-table DISPLAY
    tt-Table.cTable  COLUMN-LABEL 'Table' FORMAT "X(25)"
    tt-Table.cDesc   COLUMN-LABEL 'Description'

   ENABLE tt-Table.cDesc
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 59.4 BY 11.43 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE br-VisibleColumns
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-VisibleColumns C-Win _FREEFORM
    QUERY br-VisibleColumns NO-LOCK DISPLAY
    tt-VisibleColumns.cField   LABEL 'Visible columns'
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 41 BY 6.52 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
    btn-view AT ROW 1.38 COL 2
    RECT-1 AT ROW 1.1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
    SIDE-LABELS NO-UNDERLINE THREE-D
    AT COL 1.6 ROW 1
    SIZE 255.4 BY 46.43.

DEFINE FRAME frm-data
    btn-FreeQuery AT ROW 1 COL 167
    ed-FreeQuery AT ROW 1.05 COL 32 NO-LABEL
    bntAdd AT ROW 1.1 COL 1.8
    btn-Refresh AT ROW 1.1 COL 17.4
    btnDelete AT ROW 2.05 COL 1.8
    btn-save AT ROW 2.05 COL 17.4
    w-SearchFilterField AT ROW 3.14 COL 1.6 NO-LABEL
    btn_RecNo AT ROW 3.24 COL 152 WIDGET-ID 2
    w-recNo AT ROW 3.24 COL 164.6 COLON-ALIGNED NO-LABEL
    br-Filter AT ROW 4.48 COL 1
    RECT-4 AT ROW 3.14 COL 17
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
    SIDE-LABELS NO-UNDERLINE THREE-D
    AT COL 1 ROW 2.86
    SCROLLABLE SIZE 255 BY 44.57.

DEFINE FRAME frm-Columns
    br-AllColumns AT ROW 2.57 COL 3
    br-VisibleColumns AT ROW 2.57 COL 65
    btn-SelectAll AT ROW 3.29 COL 46.8
    btn-Select AT ROW 4.71 COL 46.8
    btn-Deselect AT ROW 6.14 COL 46.8
    btn-DeselectAll AT ROW 7.57 COL 46.8
    btn-Ok AT ROW 8.05 COL 108
    "Select visible columns" VIEW-AS TEXT
    SIZE 28 BY .62 AT ROW 1.48 COL 43
    FGCOLOR 1 FONT 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
    SIDE-LABELS NO-UNDERLINE THREE-D
    AT COL 57 ROW 4.52
    SIZE 122 BY 8.81
    BGCOLOR 8 .

DEFINE FRAME frm-schema
    br-db AT ROW 1.1 COL 1.6
    br-table AT ROW 1.1 COL 40.6
    br-index AT ROW 1.1 COL 100.8
    br-indexField AT ROW 1.1 COL 143.6
    w-tableSearch AT ROW 6.71 COL 13.6 COLON-ALIGNED
    w-TableBegins AT ROW 7.81 COL 15.8
    w-HiddenTable AT ROW 8.71 COL 15.8
    w-FieldSearch AT ROW 10.05 COL 13.6 COLON-ALIGNED
    w-FieldMatches AT ROW 11.24 COL 15.8
    w-SearchFieldName AT ROW 12.91 COL 2 NO-LABEL
    br-Field AT ROW 14.1 COL 2
    RECT-2 AT ROW 9.57 COL 2
    RECT-3 AT ROW 12.91 COL 33
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
    SIDE-LABELS NO-UNDERLINE THREE-D
    AT COL 1 ROW 2.86
    SIZE 255 BY 44.57.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
    CREATE WINDOW C-Win ASSIGN
        HIDDEN             = YES
        TITLE              = "<insert window title>"
        HEIGHT             = 32.76
        WIDTH              = 179.4
        MAX-HEIGHT         = 46.43
        MAX-WIDTH          = 256
        VIRTUAL-HEIGHT     = 46.43
        VIRTUAL-WIDTH      = 256
        RESIZE             = YES
        SCROLL-BARS        = NO
        STATUS-AREA        = NO
        BGCOLOR            = ?
        FGCOLOR            = ?
        KEEP-FRAME-Z-ORDER = YES
        THREE-D            = YES
        MESSAGE-AREA       = NO
        SENSITIVE          = YES.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME frm-Columns:FRAME = FRAME frm-data:HANDLE
    FRAME frm-data:FRAME = FRAME DEFAULT-FRAME:HANDLE
    FRAME frm-schema:FRAME = FRAME DEFAULT-FRAME:HANDLE.

/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME frm-Columns
                                                                        */
/* BROWSE-TAB br-AllColumns TEXT-1 frm-Columns */
/* BROWSE-TAB br-VisibleColumns br-AllColumns frm-Columns */
ASSIGN
    FRAME frm-Columns:HIDDEN           = TRUE.

/* SETTINGS FOR FRAME frm-data
                                                                        */
/* BROWSE-TAB br-Filter w-SearchFilterField w-recNo frm-data */
ASSIGN
    FRAME frm-data:HIDDEN           = TRUE
    FRAME frm-data:HEIGHT           = 44.57
    FRAME frm-data:WIDTH            = 255.

ASSIGN
    btn-FreeQuery:HIDDEN IN FRAME frm-data           = TRUE.

/* SETTINGS FOR FILL-IN w-SearchFilterField IN FRAME frm-data
   ALIGN-L                                                              */
/* SETTINGS FOR FRAME frm-schema
                                                                        */
/* BROWSE-TAB br-db RECT-3 frm-schema */
/* BROWSE-TAB br-table br-db frm-schema */
/* BROWSE-TAB br-index br-table frm-schema */
/* BROWSE-TAB br-indexField br-index frm-schema */
/* BROWSE-TAB br-Field w-SearchFieldName frm-schema */
ASSIGN
    FRAME frm-schema:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN w-SearchFieldName IN FRAME frm-schema
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win) THEN C-Win:HIDDEN = NO.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-AllColumns
/* Query rebuild information for BROWSE br-AllColumns
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
   FOR EACH tt-NonVisibleColumns
      WHERE tt-NonVisibleColumns.cTable      =  cLastSelectedTable
      NO-LOCK BY tt-NonVisibleColumns.cField.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-AllColumns */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-db
/* Query rebuild information for BROWSE br-db
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-db.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-db */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-Field
/* Query rebuild information for BROWSE br-Field
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-Field BY tt-field.cField.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-Field */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-Filter
/* Query rebuild information for BROWSE br-Filter
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-Filter BY tt-Filter.cField.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-Filter */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-index
/* Query rebuild information for BROWSE br-index
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-index.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-index */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-indexField
/* Query rebuild information for BROWSE br-indexField
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-indexField.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-indexField */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-Table .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-VisibleColumns
/* Query rebuild information for BROWSE br-VisibleColumns
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
   FOR EACH tt-VisibleColumns
      WHERE tt-VisibleColumns.cTable = cLastSelectedTable
      NO-LOCK BY tt-VisibleColumns.cField.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-VisibleColumns */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME frm-data
/* Query rebuild information for FRAME frm-data
     _Query            is NOT OPENED
*/  /* FRAME frm-data */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME frm-schema
/* Query rebuild information for FRAME frm-schema
     _Query            is NOT OPENED
*/  /* FRAME frm-schema */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Schema */
    OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
        /* This case occurs when the user presses the "Esc" key.
           In a persistently run window, just ignore this.  If we did not, the
           application would exit. */
        IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Schema */
    DO:
        RUN EmptyRecordCheck.

        APPLY "CLOSE":U TO THIS-PROCEDURE.
        RETURN NO-APPLY.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-RESIZED OF C-Win /* Schema */
    DO:
        RUN OnWindowResized.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm-data
&Scoped-define SELF-NAME bntAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bntAdd C-Win
ON CHOOSE OF bntAdd IN FRAME frm-data /* Add */
    DO:
        RUN RecordAdd.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-AllColumns
&Scoped-define FRAME-NAME frm-Columns
&Scoped-define SELF-NAME br-AllColumns
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-AllColumns C-Win
ON MOUSE-SELECT-DBLCLICK OF br-AllColumns IN FRAME frm-Columns
    DO:
        APPLY 'CHOOSE' TO btn-Select IN FRAME frm-Columns.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-db
&Scoped-define FRAME-NAME frm-schema
&Scoped-define SELF-NAME br-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-db C-Win
ON VALUE-CHANGED OF br-db IN FRAME frm-schema
    DO:
        RUN FillTable.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-index
&Scoped-define SELF-NAME br-index
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-index C-Win
ON VALUE-CHANGED OF br-index IN FRAME frm-schema
    DO:

        IF TEMP-TABLE tt-index:HANDLE:HAS-RECORDS THEN DO:

            CREATE BUFFER hBuf FOR TABLE tt-db.cDb + '._index' .
            hbuf:FIND-FIRST(' where _index._file-recid = "' + cTableRecid + '" and _index._index-name = "' + tt-index.cIndex + '"').
            cIndexRecid = STRING(hbuf:RECID).
            DELETE OBJECT hBuf.

            RUN FillIndexFields (INPUT cIndexRecid).

        END.
        ELSE DO:

            EMPTY TEMP-TABLE tt-index.
            EMPTY TEMP-TABLE tt-indexField.

      {&OPEN-QUERY-br-index}
      {&OPEN-QUERY-br-indexField}

        END.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table C-Win
ON MOUSE-SELECT-DBLCLICK OF br-table IN FRAME frm-schema
    DO:
        RUN ChangeViewMode.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table C-Win
ON VALUE-CHANGED OF br-table IN FRAME frm-schema
    DO:
        IF TEMP-TABLE tt-table:HAS-RECORDS THEN DO:

            cTableRecid = GetTableRecid().

            RUN FillFields(cTableRecid).
            RUN FillIndex (cTableRecid).

            APPLY 'VALUE-CHANGED' TO BROWSE br-index.

        END.
        ELSE DO:
            EMPTY TEMP-TABLE tt-field.
            EMPTY TEMP-TABLE tt-index.
            EMPTY TEMP-TABLE tt-indexField.

      {&OPEN-QUERY-br-Field}
      {&OPEN-QUERY-br-index}
      {&OPEN-QUERY-br-indexField}
        END.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-VisibleColumns
&Scoped-define FRAME-NAME frm-Columns
&Scoped-define SELF-NAME br-VisibleColumns
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-VisibleColumns C-Win
ON MOUSE-SELECT-DBLCLICK OF br-VisibleColumns IN FRAME frm-Columns
    DO:
        APPLY 'CHOOSE' TO btn-Deselect IN FRAME frm-Columns.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-Deselect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-Deselect C-Win
ON CHOOSE OF btn-Deselect IN FRAME frm-Columns /* <- */
    DO:

        DEFINE VARIABLE i AS INTEGER    NO-UNDO.

        DO i = 1 TO BROWSE br-VisibleColumns:NUM-SELECTED-ROWS:

            br-VisibleColumns:FETCH-SELECTED-ROW(i).

            CREATE tt-NonVisibleColumns.
            BUFFER-COPY tt-VisibleColumns TO tt-NonVisibleColumns.

            DELETE tt-VisibleColumns.

        END.

   {&OPEN-QUERY-br-AllColumns}
   {&OPEN-QUERY-br-VisibleColumns}

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-DeselectAll
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-DeselectAll C-Win
ON CHOOSE OF btn-DeselectAll IN FRAME frm-Columns /* <<- */
    DO:

        FOR EACH tt-VisibleColumns:

            CREATE tt-NonVisibleColumns.
            BUFFER-COPY tt-VisibleColumns TO tt-NonVisibleColumns.

            DELETE tt-VisibleColumns.

        END.

   {&OPEN-QUERY-br-AllColumns}
   {&OPEN-QUERY-br-VisibleColumns}

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm-data
&Scoped-define SELF-NAME btn-FreeQuery
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-FreeQuery C-Win
ON CHOOSE OF btn-FreeQuery IN FRAME frm-data /* Free Query */
    DO:
        DEFINE VARIABLE bool AS LOGICAL     NO-UNDO.

        ASSIGN INPUT FRAME frm-data ed-FreeQuery.

        hqueryData:QUERY-CLOSE().

        bool =  hqueryData:QUERY-PREPARE(ed-FreeQuery + cSortDataString) NO-ERROR.

        IF bool = FALSE THEN DO:

            MESSAGE 'Incorrect query string!'
                VIEW-AS ALERT-BOX INFO BUTTONS OK.

        END.
        ELSE DO:

            w-recNo:SCREEN-VALUE = ''.

            hqueryData:QUERY-OPEN() NO-ERROR.

            IF hQueryData:NUM-RESULTS > 0 THEN ENABLE  Btn-save WITH FRAME frm-data.
            ELSE DISABLE Btn-save WITH FRAME frm-data.

        END.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm-Columns
&Scoped-define SELF-NAME btn-Ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-Ok C-Win
ON CHOOSE OF btn-Ok IN FRAME frm-Columns /* Ok */
    DO:
        RUN HideFrmColumns.

        RUN SetVisibleColumns.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm-data
&Scoped-define SELF-NAME btn-Refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-Refresh C-Win
ON CHOOSE OF btn-Refresh IN FRAME frm-data /* Refresh */
    DO:

        RUN FilterData.
        RUN OpenQuery.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-save C-Win
ON CHOOSE OF btn-save IN FRAME frm-data /* Save */
    DO:
        RUN RecordSave.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm-Columns
&Scoped-define SELF-NAME btn-Select
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-Select C-Win
ON CHOOSE OF btn-Select IN FRAME frm-Columns /* -> */
    DO:

        DEFINE VARIABLE i AS INTEGER    NO-UNDO.

        DO i = 1 TO BROWSE br-AllColumns:NUM-SELECTED-ROWS :

            br-AllColumns:FETCH-SELECTED-ROW(i).

            CREATE tt-VisibleColumns.
            BUFFER-COPY tt-NonVisibleColumns TO tt-VisibleColumns.

            DELETE tt-NonVisibleColumns.

        END.

   {&OPEN-QUERY-br-AllColumns}
   {&OPEN-QUERY-br-VisibleColumns}

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-SelectAll
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-SelectAll C-Win
ON CHOOSE OF btn-SelectAll IN FRAME frm-Columns /* ->> */
    DO:

        FOR EACH tt-NonVisibleColumns:

            CREATE tt-VisibleColumns.
            BUFFER-COPY tt-NonVisibleColumns TO tt-VisibleColumns.

            DELETE tt-NonVisibleColumns.

        END.

   {&OPEN-QUERY-br-AllColumns}
   {&OPEN-QUERY-br-VisibleColumns}

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define SELF-NAME btn-view
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-view C-Win
ON CHOOSE OF btn-view IN FRAME DEFAULT-FRAME /* Data */
    DO:
        RUN ChangeViewMode.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm-data
&Scoped-define SELF-NAME btnDelete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btnDelete C-Win
ON CHOOSE OF btnDelete IN FRAME frm-data /* Delete */
    DO:
        RUN RecordDelete.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define FRAME-NAME frm-data
&Scoped-define SELF-NAME btn_RecNo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_RecNo C-Win
ON CHOOSE OF btn_RecNo IN FRAME frm-data /* Records No */
    DO:

        RUN GetTotalRecNo.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed-FreeQuery
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed-FreeQuery C-Win
ON LEAVE OF ed-FreeQuery IN FRAME frm-data
    DO:
        DEFINE VARIABLE bool AS LOGICAL     NO-UNDO.

        ASSIGN INPUT FRAME frm-data ed-FreeQuery.

        hqueryData:QUERY-CLOSE().

        bool =  hqueryData:QUERY-PREPARE(ed-FreeQuery + cSortDataString) NO-ERROR.

        IF bool = FALSE THEN DO:

            MESSAGE 'Incorrect query string!'
                VIEW-AS ALERT-BOX INFO BUTTONS OK.

        END.
        ELSE DO:

            hqueryData:QUERY-OPEN() NO-ERROR.

            IF hQueryData:NUM-RESULTS > 0 THEN ENABLE  Btn-save WITH FRAME frm-data.
            ELSE DISABLE Btn-save WITH FRAME frm-data.

        END.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm-schema
&Scoped-define SELF-NAME w-FieldMatches
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-FieldMatches C-Win
ON VALUE-CHANGED OF w-FieldMatches IN FRAME frm-schema /* Matches */
    DO:
        ASSIGN INPUT FRAME frm-schema w-FieldMatches .

        IF w-FieldSearch <> '' THEN DO:
            RUN FindTablesforField.
            APPLY 'VALUE-CHANGED' TO BROWSE br-table.
        END.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME w-FieldSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-FieldSearch C-Win
ON LEAVE OF w-FieldSearch IN FRAME frm-schema /* Field search */
    DO:
        ASSIGN INPUT FRAME frm-schema w-FieldSearch .

        IF w-FieldSearch <> '' THEN RUN FindTablesforField.
        ELSE RUN FillTable.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-FieldSearch C-Win
ON RETURN OF w-FieldSearch IN FRAME frm-schema /* Field search */
    DO:
        ASSIGN INPUT FRAME frm-schema w-FieldSearch .

        IF w-FieldSearch <> '' THEN RUN FindTablesforField.
        ELSE RUN FillTable.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-FieldSearch C-Win
ON VALUE-CHANGED OF w-FieldSearch IN FRAME frm-schema /* Field search */
    DO:

        ASSIGN INPUT FRAME frm-schema w-FieldSearch .

        IF TRIM(w-FieldSearch) = '' THEN APPLY 'RETURN' TO w-FieldSearch.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME w-HiddenTable
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-HiddenTable C-Win
ON VALUE-CHANGED OF w-HiddenTable IN FRAME frm-schema /* Hidden */
    DO:
        ASSIGN INPUT FRAME frm-schema w-HiddenTable.
        /*
        IF w-HiddenTable
        THEN DISABLE btn-view WITH FRAME default-frame.
        ELSE ENABLE  btn-view WITH FRAME default-frame.
        */
        IF w-FieldSearch = '' THEN RUN FillTable.
        ELSE RUN FindTablesforField.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME w-SearchFieldName
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-SearchFieldName C-Win
ON RETURN OF w-SearchFieldName IN FRAME frm-schema
    DO:

        APPLY 'VALUE-CHANGED' TO w-SearchFieldName IN FRAME FRM-SCHEMA.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-SearchFieldName C-Win
ON VALUE-CHANGED OF w-SearchFieldName IN FRAME frm-schema
    DO:
        ASSIGN INPUT FRAME frm-schema w-SearchFieldName.

        DEFINE VARIABLE cTableName AS CHARACTER  NO-UNDO.

        FIND FIRST tt-field
            WHERE tt-field.cDb      = tt-db.cDb
            AND tt-field.cTable   = tt-table.cTable
            AND tt-field.cField  >= w-SearchFieldName
            NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-field THEN FIND LAST tt-field NO-ERROR.

        IF AVAILABLE tt-field THEN DO:

            REPOSITION br-field TO ROWID ROWID(tt-field) NO-ERROR.

            IF NOT ERROR-STATUS:ERROR THEN APPLY 'VALUE-CHANGED' TO BROWSE br-field.

        END. /* IF AVAILABLE tt-field */

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm-data
&Scoped-define SELF-NAME w-SearchFilterField
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-SearchFilterField C-Win
ON RETURN OF w-SearchFilterField IN FRAME frm-data
    DO:
        APPLY 'VALUE-CHANGED' TO w-SearchFilterField IN FRAME FRM-DATA.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-SearchFilterField C-Win
ON VALUE-CHANGED OF w-SearchFilterField IN FRAME frm-data
    DO:
        ASSIGN INPUT FRAME frm-data w-SearchFilterField.

        DEFINE VARIABLE cTableName AS CHARACTER  NO-UNDO.

        FIND FIRST tt-Filter
            WHERE tt-Filter.cField  >= w-SearchFilterField
            NO-ERROR.

        IF NOT AVAILABLE tt-Filter THEN FIND LAST tt-Filter NO-ERROR.

        IF AVAILABLE tt-Filter THEN DO:

            REPOSITION br-filter TO ROWID ROWID(tt-Filter) NO-ERROR.

            IF NOT ERROR-STATUS:ERROR THEN APPLY 'VALUE-CHANGED' TO BROWSE br-field.

        END. /* IF AVAILABLE tt-Filter */

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frm-schema
&Scoped-define SELF-NAME w-TableBegins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-TableBegins C-Win
ON VALUE-CHANGED OF w-TableBegins IN FRAME frm-schema /* Begins */
    DO:

        ASSIGN INPUT FRAME frm-schema w-TableBegins .

        IF NOT w-TableBegins THEN RUN FillTable.

        APPLY 'VALUE-CHANGED' TO w-tableSearch.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME w-tableSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-tableSearch C-Win
ON VALUE-CHANGED OF w-tableSearch IN FRAME frm-schema /* Table Search */
    DO:

        ASSIGN INPUT FRAME frm-schema w-tableSearch
            w-TableBegins
            w-FieldSearch.

        IF w-FieldSearch <> '' THEN RUN FindTablesForField.
        ELSE DO:

            IF w-TableBegins THEN RUN FillTable.
            ELSE RUN FindTable.

        END.

        ASSIGN w-SearchFieldName = '':U.
        DISPLAY w-SearchFieldName WITH FRAME FRM-SCHEMA.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME br-AllColumns
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME}
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE
    RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    RUN enable_UI.

    RUN InitProgram.

    IF NOT THIS-PROCEDURE:PERSISTENT THEN WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChangeViewMode C-Win
PROCEDURE ChangeViewMode :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    /* Data -> Schema */
    IF v-mod = 'Data' THEN DO:

        RUN EmptyRecordCheck.

        ASSIGN
            v-mod       = 'Schema'
            c-Win:TITLE = 'Schema view'.

        RUN DeleteObjectsFrmData.

        ASSIGN
            btn-view:LABEL IN FRAME DEFAULT-FRAME        = 'Data'
            FRAME frm-data:HIDDEN                        = TRUE
            FRAME frm-schema:HIDDEN                      = FALSE

            cQueryDataString = ''
            cDataWhereClause = ''
            cSortDataString  = ''
            cChangedRecords  = ''
            .

        CLOSE QUERY br-Filter.

      {&OPEN-QUERY-br-Field}

    END.
    ELSE /* this else is mandatory */

    /* Schema -> Data */
    IF v-mod           = 'Schema' AND
        /*  w-hiddenTable   = FALSE    AND*/
        AVAILABLE tt-table THEN DO:

        CREATE BUFFER hBufTable FOR TABLE tt-table.cDB + '.' + tt-table.cTable NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:

            v-dbNameError = TRUE.
            CREATE BUFFER hBufTable FOR TABLE tt-table.cTable NO-ERROR.
            IF ERROR-STATUS:ERROR THEN DO:

                MESSAGE tt-table.cDB + '.' + tt-table.cTable 'not accessible'.
                RETURN '-1':U.

            END.

        END.

        ASSIGN
            v-mod                = 'Data'
            c-Win:TITLE          = 'Sch-' + tt-table.cTable

            btn-view:LABEL IN FRAME DEFAULT-FRAME         = 'Schema'
            ed-FreeQuery:SCREEN-VALUE IN FRAME FRM-DATA   = ''
            FRAME frm-data:HIDDEN                         = FALSE
            FRAME frm-schema:HIDDEN                       = TRUE
            w-SearchFilterField:SCREEN-VALUE              = ''
            w-recNo:SCREEN-VALUE                         = ''
            .

        DISABLE btn-save WITH FRAME frm-data.

        APPLY 'VALUE-CHANGED' TO BROWSE br-table.

        CLOSE QUERY br-Field.

        IF cLastSelectedTable   <> tt-table.cTable THEN DO:
            ASSIGN cLastSelectedTable = tt-table.cTable.
            RUN FillFilter.
        END.

      {&OPEN-QUERY-br-Filter}

        RUN CreateDataWidgtes.
        RUN FilterData.
        RUN OpenQuery.

    /*   APPLY 'ENTRY' TO br-Filter.*/

    END.

    APPLY 'WINDOW-RESIZED' TO C-Win.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ColumnsMovable C-Win
PROCEDURE ColumnsMovable :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    ASSIGN
        hBr-Data:ALLOW-COLUMN-SEARCHING  = FALSE
        hBr-Data:COLUMN-MOVABLE          = TRUE
        hMovable:SENSITIVE               = FALSE
        hSearchable:SENSITIVE            = TRUE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ColumnsSearchable C-Win
PROCEDURE ColumnsSearchable :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    ASSIGN
        hBr-Data:ALLOW-COLUMN-SEARCHING  = TRUE
        hBr-Data:COLUMN-MOVABLE          = FALSE
        hMovable:SENSITIVE               = TRUE
        hSearchable:SENSITIVE            = FALSE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CreateBrowseData C-Win
PROCEDURE CreateBrowseData :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE iExtent    AS INTEGER     NO-UNDO.
    DEFINE VARIABLE i          AS INTEGER     NO-UNDO.
    DEFINE VARIABLE nrExt      AS INTEGER     NO-UNDO.

    CREATE BROWSE hbr-Data
        ASSIGN
        NAME                   = 'DataBrowse'
        FRAME                   = FRAME frm-data:HANDLE
        ROW                     = BROWSE br-Filter:HANDLE:ROW
        COLUMN                  = BROWSE br-Filter:HANDLE:COLUMN + BROWSE br-Filter:HANDLE:WIDTH + 0.5
        WIDTH                  = c-Win:WIDTH - hbr-Data:COLUMN /* - 0.5 */
        HEIGHT                  = c-Win:HEIGHT - 4.3
        ROW-MARKERS             = FALSE
        SEPARATORS              = TRUE
        HIDDEN                  = FALSE
        COLUMN-RESIZABLE        = TRUE
        SENSITIVE               = TRUE
        READ-ONLY               = FALSE
        MENU-MOUSE              = 3
        QUERY                   = hqueryData
        POPUP-MENU              = hMenu
        TOOLTIP                = ''
        TRIGGERS:
            ON START-SEARCH PERSISTENT RUN onStartSearch IN THIS-PROCEDURE.
            ON ROW-DISPLAY  PERSISTENT RUN onRowDisplay  IN THIS-PROCEDURE.
        END TRIGGERS.

    hbr-Data:SET-REPOSITIONED-ROW(15,"CONDITIONAL").

    ASSIGN nrColumn = 0.

    FOR EACH tt-field
        NO-LOCK
        BY tt-field.cField:

        nrColumn  = nrColumn + iExtent + 1.

        IF v-dbNameError THEN hCol[nrColumn] = hbr-Data:ADD-LIKE-COLUMN(tt-field.cTable + '.' + tt-field.cField):HANDLE.
        ELSE hCol[nrColumn] = hbr-Data:ADD-LIKE-COLUMN(tt-field.cDB + '.' + tt-field.cTable + '.' + tt-field.cField):HANDLE.

        ASSIGN
            hCol[nrColumn]:LABEL     = IF tt-field.cExtent <> '0' THEN tt-field.cField + '[1]' ELSE tt-field.cField
            hCol[nrColumn]:READ-ONLY = FALSE
            hCol[nrColumn]:VISIBLE   = FALSE
            iExtent                  = IF INT(tt-field.cExtent) > 0 THEN INT(tt-field.cExtent) - 1 ELSE 0
         NO-ERROR.


        IF VALID-HANDLE(hCol[nrColumn]) THEN

            CASE hCol[nrColumn]:DATA-TYPE:

                WHEN 'CHARACTER'
                THEN hCol[nrColumn]:WIDTH-CHARS = MAX(20,LENGTH(hCol[nrColumn]:LABEL) + 1).

                WHEN 'INTEGER' OR
                WHEN 'DECIMAL'
                THEN hCol[nrColumn]:WIDTH-CHARS = MAX(10,LENGTH(hCol[nrColumn]:LABEL) + 1).

                WHEN 'DATE'
                THEN hCol[nrColumn]:WIDTH-CHARS = MAX(12,LENGTH(hCol[nrColumn]:LABEL) + 1).

                WHEN 'LOGICAL'
                THEN hCol[nrColumn]:WIDTH-CHARS = LENGTH(hCol[nrColumn]:LABEL) + 1.

            END CASE.

    END. /* FOR EACH tt-field */

    /* umplu golurile lasate de extent */
    DO i = 1 TO hbr-Data:NUM-COLUMNS:

        IF VALID-HANDLE(hcol[i]) THEN DO:
            nrExt = 1.
            NEXT.
        END.

        ASSIGN
            nrExt                   = nrExt + 1
            hCol[i]                 = hbr-data:GET-BROWSE-COLUMN(i)
            hCol[i]:LABEL           = hbr-data:GET-BROWSE-COLUMN(i):NAME + '[' + STRING(nrExt) + ']'
            hCol[i]:READ-ONLY       = FALSE
            hCol[i]:VISIBLE         = FALSE
         NO-ERROR.

        CASE hCol[i]:DATA-TYPE:

            WHEN 'CHARACTER'
            THEN hCol[i]:WIDTH-CHARS = MAX(20,LENGTH(hCol[i]:LABEL) + 1).

            WHEN 'INTEGER' OR
            WHEN 'DECIMAL'
            THEN hCol[i]:WIDTH-CHARS = MAX(10,LENGTH(hCol[i]:LABEL) + 1).

            WHEN 'DATE'
            THEN hCol[i]:WIDTH-CHARS = MAX(12,LENGTH(hCol[i]:LABEL) + 1).

            WHEN 'LOGICAL'
            THEN hCol[i]:WIDTH-CHARS = LENGTH(hCol[i]:LABEL) + 1.

        END CASE.

    END.

    RUN SetVisibleColumns.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CreateDataWidgtes C-Win
PROCEDURE CreateDataWidgtes :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    RUN CreatePopupMenu.

    RUN CreateQueryData.

    RUN CreateBrowseData.


    hbr-Filter = BROWSE br-Filter:HANDLE.

    ON LEAVE OF cFrom IN BROWSE br-Filter PERSISTENT RUN onLeavecFrombrFilter IN THIS-PROCEDURE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CreatePopupMenu C-Win
PROCEDURE CreatePopupMenu :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE hSelectColumns AS HANDLE NO-UNDO.

    CREATE MENU hMenu.

    CREATE MENU-ITEM hMovable
        ASSIGN
        PARENT = hMenu
        LABEL  = "Movable"
        TRIGGERS:
            ON CHOOSE PERSISTENT RUN ColumnsMovable IN THIS-PROCEDURE.
        END TRIGGERS.

    CREATE MENU-ITEM hSearchable
        ASSIGN
        PARENT      = hMenu
        LABEL       = "Searchable"
        SENSITIVE   = FALSE
        TRIGGERS:
            ON CHOOSE PERSISTENT RUN ColumnsSearchable IN THIS-PROCEDURE.
        END TRIGGERS.

    CREATE MENU-ITEM hSelectColumns
        ASSIGN
        PARENT      = hMenu
        LABEL       = "Select columns"
        SENSITIVE   = TRUE
        TRIGGERS:
            ON CHOOSE PERSISTENT RUN SelectDataColumns IN THIS-PROCEDURE.
        END TRIGGERS.

    CREATE MENU-ITEM hShowData
        ASSIGN
        PARENT      = hMenu
        LABEL      = "Show data"
        SENSITIVE  = TRUE
        TRIGGERS:
            ON CHOOSE PERSISTENT RUN ShowDataColumns IN THIS-PROCEDURE.
        END TRIGGERS.


    ASSIGN
        hMenu:POPUP-ONLY        = YES
        hSearchable:SENSITIVE   = FALSE
        .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CreateQueryData C-Win
PROCEDURE CreateQueryData :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE i AS INTEGER     NO-UNDO.

    /*
    In baza de date formatul unor campuri este mai mic decat lungimea lor. (exemplu: com_bas_evt.typ_com_bas)
    Setez un format mai mare, ca sa fiu sigur ca vad tot continutul campului respectiv.
    */
    FOR EACH tt-Field NO-LOCK:

        i = i + 1.

        IF hBufTable:BUFFER-FIELD(i):DATA-TYPE = 'CHARACTER' THEN hBufTable:BUFFER-FIELD(i):FORMAT = 'x(500)'.

    END.

    IF v-dbNameError THEN cQueryDataString = 'for each ' + tt-table.cTable + ' no-lock where YES '.
    ELSE cQueryDataString = 'for each ' + tt-table.cDB + '.' + tt-table.cTable + ' no-lock where YES '.

    CREATE QUERY hqueryData.
    hqueryData:SET-BUFFERS(hBufTable).
    hqueryData:QUERY-PREPARE(cQueryDataString).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DeleteObjectsFrmData C-Win
PROCEDURE DeleteObjectsFrmData :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    IF VALID-HANDLE(hbr-Data) THEN DELETE OBJECT hbr-Data.

    IF VALID-HANDLE(hqueryData) THEN DELETE OBJECT hqueryData.

    IF VALID-HANDLE(hBufTable) THEN DELETE OBJECT hBufTable.

    IF VALID-HANDLE(hSearchable) THEN DELETE OBJECT hSearchable.

    IF VALID-HANDLE(hMovable) THEN DELETE OBJECT hMovable.

    IF VALID-HANDLE(hMenu) THEN DELETE OBJECT hMenu.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DisableTriggers C-Win
PROCEDURE DisableTriggers :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE INPUT  PARAMETER p-operation    AS CHARACTER      NO-UNDO.
    DEFINE OUTPUT PARAMETER p-rowid        AS ROWID          NO-UNDO.

    DEFINE VARIABLE v-errorCode            AS CHARACTER      NO-UNDO.
    DEFINE VARIABLE v-file_name            AS CHARACTER      NO-UNDO.

    IF NOT AVAILABLE tt-Table THEN RETURN '-1'.

    v-file_name = 'disableTriggers.p'.

    OUTPUT TO VALUE(v-file_name).

    PUT UNFORMATTED 'DEFINE INPUT  PARAMETER hbr-Data      AS HANDLE      NO-UNDO.' SKIP.
    PUT UNFORMATTED 'DEFINE INPUT  PARAMETER hBufTable     AS HANDLE      NO-UNDO.' SKIP.
    PUT UNFORMATTED 'DEFINE OUTPUT PARAMETER p-rowid       AS ROWID       NO-UNDO.' SKIP.
    PUT UNFORMATTED 'DEFINE OUTPUT PARAMETER p-errorCode   AS CHARACTER   NO-UNDO  INIT "".' SKIP(2).

    CASE p-operation:

        WHEN 'ADD'
        THEN DO:

                PUT UNFORMATTED 'DISABLE TRIGGERS FOR LOAD OF ' + tt-Table.cTable + '.' SKIP(1).

                PUT UNFORMATTED 'DO TRANSACTION:' SKIP(1).

                PUT UNFORMATTED '    hBufTable:BUFFER-CREATE() NO-ERROR.' SKIP.
                PUT UNFORMATTED '    IF ERROR-STATUS:ERROR' SKIP.
                PUT UNFORMATTED '    THEN DO:' SKIP(1).

                PUT UNFORMATTED '       MESSAGE "New record could not be created."' SKIP.
                PUT UNFORMATTED '          VIEW-AS ALERT-BOX INFO BUTTONS OK.' SKIP(1).

                PUT UNFORMATTED '       ASSIGN p-errorCode = "-1".' SKIP.
                PUT UNFORMATTED '       RETURN.' SKIP(1).

                PUT UNFORMATTED '    END.' SKIP(1).

                PUT UNFORMATTED '    ASSIGN p-rowid = hBufTable:ROWID.' SKIP(1).

                PUT UNFORMATTED 'END.' SKIP.

            END.

        WHEN 'CHANGE'
        THEN DO:

                PUT UNFORMATTED 'DEFINE VARIABLE i AS INTEGER NO-UNDO.' SKIP(2).


                PUT UNFORMATTED 'DISABLE TRIGGERS FOR LOAD OF ' + tt-Table.cTable + '.' SKIP(1).

                PUT UNFORMATTED 'hbr-Data:SELECT-FOCUSED-ROW().' SKIP(1).

                PUT UNFORMATTED 'DO TRANSACTION:' SKIP(1).

                PUT UNFORMATTED '   hBufTable:FIND-CURRENT(EXCLUSIVE-LOCK) NO-ERROR.' SKIP.

                PUT UNFORMATTED '   IF ERROR-STATUS:ERROR' SKIP.

                PUT UNFORMATTED '   THEN DO:' SKIP.

                PUT UNFORMATTED '      MESSAGE "Record is not available.".' SKIP.

                PUT UNFORMATTED '      ASSIGN p-errorCode = "-1".' SKIP.
                PUT UNFORMATTED '      RETURN.' SKIP.

                PUT UNFORMATTED '   END.' SKIP(1).


                PUT UNFORMATTED '   p-rowid = hBufTable:ROWID.' SKIP(1).


                PUT UNFORMATTED '   DO i = 1 TO hbr-Data:NUM-COLUMNS:' SKIP(1).

                PUT UNFORMATTED '      hBufTable:BUFFER-FIELD(hbr-Data:GET-BROWSE-COLUMN(i):BUFFER-FIELD:NAME):BUFFER-VALUE' SKIP.
                PUT UNFORMATTED '          = hbr-Data:GET-BROWSE-COLUMN(i):SCREEN-VALUE NO-ERROR.' SKIP(1).


                PUT UNFORMATTED '      IF ERROR-STATUS:ERROR' SKIP.

                PUT UNFORMATTED '      THEN DO:' SKIP.

                PUT UNFORMATTED '         MESSAGE "Record can not be saved.".' SKIP.

                PUT UNFORMATTED '      ASSIGN p-errorCode = "-1".' SKIP.
                PUT UNFORMATTED '      UNDO, RETURN.' SKIP.

                PUT UNFORMATTED '      END.' SKIP(1).


                PUT UNFORMATTED '   END.' SKIP(1).


                PUT UNFORMATTED 'END. /*  DO TRANSACTION: */' SKIP.


            END.

        WHEN 'DELETE'
        THEN DO:

                PUT UNFORMATTED 'hbr-Data:SELECT-FOCUSED-ROW().' SKIP (1).

                PUT UNFORMATTED 'DO TRANSACTION:' SKIP(1).

                PUT UNFORMATTED '   hBufTable:FIND-CURRENT(EXCLUSIVE-LOCK).' SKIP.
                PUT UNFORMATTED '   hBufTable:BUFFER-DELETE() NO-ERROR.' SKIP(1).

                PUT UNFORMATTED '   IF ERROR-STATUS:ERROR' SKIP.
                PUT UNFORMATTED '   THEN DO:' SKIP(1).

                PUT UNFORMATTED '      MESSAGE "Record could not be deleted.".' SKIP(1).

                PUT UNFORMATTED '      ASSIGN p-errorCode = "-1".' SKIP.
                PUT UNFORMATTED '      RETURN.' SKIP(1).

                PUT UNFORMATTED '   END.' SKIP(1).

                PUT UNFORMATTED 'END. /*  DO TRANSACTION: */' SKIP.

            END.
    END CASE.

    OUTPUT CLOSE.

    RUN VALUE(v-file_name)
        (
        INPUT  hbr-Data,
        INPUT  hBufTable,
        OUTPUT p-rowid,
        OUTPUT v-errorCode
        )
        NO-ERROR.

    IF ERROR-STATUS:ERROR THEN RETURN '-1'.

    RETURN v-errorCode.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
    /*------------------------------------------------------------------------------
      Purpose:     DISABLE the User Interface
      Parameters:  <none>
      Notes:       Here we clean-up the user-interface by deleting
                   dynamic widgets we have created and/or hide
                   frames.  This procedure is usually called when
                   we are ready to "clean-up" after running.
    ------------------------------------------------------------------------------*/
    /* Delete the WINDOW we created */
    IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win) THEN DELETE WIDGET C-Win.
    IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE EmptyFilter C-Win
PROCEDURE EmptyFilter :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    FOR EACH tt-Filter
        WHERE tt-Filter.cFrom      <> ''
        OR tt-Filter.cTo        <> ''
        OR tt-Filter.cContains  <> ''
        EXCLUSIVE-LOCK:

        ASSIGN
            tt-Filter.cFrom      = ''
            tt-Filter.cTo        = ''
            tt-Filter.cContains  = ''
            .

    END.

    BROWSE br-Filter:REFRESH().

    ASSIGN
        cDataWhereClause                             = ''
        ed-FreeQuery:SCREEN-VALUE IN FRAME frm-data  = cQueryDataString.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE EmptyRecordCheck C-Win
PROCEDURE EmptyRecordCheck :
    /*------------------------------------------------------------------------------
      Purpose:    EmptyRecordCheck
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE cWhereClause     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE lFound           AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE i                AS INTEGER     NO-UNDO.

    IF cLastSelectedTable = '' OR
        cChangedRecords    = '' THEN RETURN.

    FOR FIRST tt-index
        WHERE tt-index.cTable = cLastSelectedTable
        AND tt-index.cType  = 'UNIQUE',
        EACH tt-IndexField
        WHERE tt-indexField.cTable = cLastSelectedTable
        AND tt-indexField.cIndex = tt-index.cIndex:

        ASSIGN cWhereClause = cWhereClause + tt-indexField.cIndexField.

        CASE hBufTable:BUFFER-FIELD(tt-indexField.cIndexField):DATA-TYPE:

            WHEN 'INTEGER' OR
            WHEN 'DECIMAL'
            THEN ASSIGN cWhereClause = cWhereClause + ' = 0 '.

            WHEN 'CHARACTER'
            THEN ASSIGN cWhereClause = cWhereClause + ' = "" '.

            WHEN 'DATE'
            THEN ASSIGN cWhereClause = cWhereClause + ' = ? '.

        END CASE.

        ASSIGN cWhereClause = cWhereClause + ' AND ' .

    END.

    ASSIGN cWhereClause = SUBSTRING(cWhereClause, 1, LENGTH(cWhereClause) - 4).

    DO i = 1 TO NUM-ENTRIES(cChangedRecords, CHR(3)) - 1:

        lFound = hBufTable:FIND-FIRST('WHERE ' + QUOTER(STRING(hBufTable:ROWID)) + ' = ' + QUOTER(ENTRY(i, cChangedRecords, CHR(3))) +
            ' AND ' + cWhereClause ) NO-ERROR.
        IF lFound THEN DO TRANSACTION:

            IF hBufTable:DISABLE-LOAD-TRIGGERS(TRUE) = TRUE THEN hBufTable:BUFFER-DELETE() NO-ERROR.

        END.

    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
    /*------------------------------------------------------------------------------
      Purpose:     ENABLE the User Interface
      Parameters:  <none>
      Notes:       Here we display/view/enable the widgets in the
                   user-interface.  In addition, OPEN all queries
                   associated with each FRAME and BROWSE.
                   These statements here are based on the "Other
                   Settings" section of the widget Property Sheets.
    ------------------------------------------------------------------------------*/
    ENABLE RECT-1 btn-view
        WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
    {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
    DISPLAY ed-FreeQuery w-SearchFilterField w-recNo
        WITH FRAME frm-data IN WINDOW C-Win.
    ENABLE btn-FreeQuery RECT-4 ed-FreeQuery bntAdd btn-Refresh btnDelete
        btn-save btn_RecNo w-recNo w-SearchFilterField br-Filter
        WITH FRAME frm-data IN WINDOW C-Win.
    VIEW FRAME frm-data IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frm-data}
    DISPLAY w-tableSearch w-TableBegins w-HiddenTable w-FieldSearch w-FieldMatches
        w-SearchFieldName
        WITH FRAME frm-schema IN WINDOW C-Win.
    ENABLE RECT-2 RECT-3 br-db br-table br-index br-indexField w-tableSearch
        w-TableBegins w-HiddenTable w-FieldSearch w-FieldMatches
        w-SearchFieldName br-Field
        WITH FRAME frm-schema IN WINDOW C-Win.
    VIEW FRAME frm-schema IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frm-schema}
    ENABLE br-AllColumns br-VisibleColumns btn-SelectAll btn-Select btn-Deselect
        btn-DeselectAll btn-Ok
        WITH FRAME frm-Columns IN WINDOW C-Win.
    VIEW FRAME frm-Columns IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frm-Columns}
    VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FillDb C-Win
PROCEDURE FillDb :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE i          AS INTEGER.

    DO i = 1 TO NUM-DBS:

        IF CAN-FIND (FIRST tt-db
            WHERE tt-db.cDb = LDBNAME(i)) THEN LEAVE.

        IF LDBNAME(i) = 'rtb' THEN NEXT.

        CREATE tt-Db.
        ASSIGN
            tt-Db.cDb   = LDBNAME(i)
            tt-Db.cDesc = DBTYPE(i) .

    END.

   {&OPEN-QUERY-br-db}

    APPLY 'VALUE-CHANGED' TO BROWSE br-db.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FillFields C-Win
PROCEDURE FillFields :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  p-recid  AS CHARACTER   NO-UNDO.

    DEFINE VARIABLE cTableName       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE hquery           AS HANDLE      NO-UNDO.

    EMPTY TEMP-TABLE tt-field.

    IF AVAILABLE tt-table THEN DO:

        cTableName = tt-db.cDb + '._field'.

        CREATE BUFFER hBuf FOR TABLE cTableName .

        CREATE QUERY hquery.
        hquery:SET-BUFFERS(hbuf).
        hquery:QUERY-PREPARE('for each ' + cTableName + ' where _file-recid = ' + p-recid + ' no-lock').
        hquery:QUERY-OPEN().
        hquery:GET-FIRST().

        DO WHILE NOT hquery:QUERY-OFF-END:

            CREATE tt-field.
            ASSIGN
                tt-field.cDb            = tt-table.cDB
                tt-field.cTable         = tt-table.cTable
                tt-field.cField         = hbuf:BUFFER-FIELD('_Field-name'):BUFFER-VALUE
                tt-field.cDataType      = hbuf:BUFFER-FIELD('_data-type'):BUFFER-VALUE
                tt-field.cFormat        = hbuf:BUFFER-FIELD('_format'):BUFFER-VALUE
                tt-field.cOrder         = hbuf:BUFFER-FIELD('_order'):BUFFER-VALUE
                tt-field.cDesc          = hbuf:BUFFER-FIELD('_desc'):BUFFER-VALUE
                tt-field.cExtent        = hbuf:BUFFER-FIELD('_extent'):BUFFER-VALUE
                tt-field.cMandatory     = hbuf:BUFFER-FIELD('_mandatory'):BUFFER-VALUE
                tt-field.cInitValue     = IF hbuf:BUFFER-FIELD('_Initial'):BUFFER-VALUE = ?
                                      THEN ''
                                      ELSE hbuf:BUFFER-FIELD('_Initial'):BUFFER-VALUE
                tt-field.cValidation    = IF hbuf:BUFFER-FIELD('_Valexp'):BUFFER-VALUE = ?
                                      THEN ''
                                      ELSE hbuf:BUFFER-FIELD('_Valexp'):BUFFER-VALUE
                tt-field.cValidationMsg = IF hbuf:BUFFER-FIELD('_Valmsg'):BUFFER-VALUE = ?
                                      THEN ''
                                      ELSE hbuf:BUFFER-FIELD('_Valmsg'):BUFFER-VALUE
                .

            hquery:GET-NEXT().

        END.

        DELETE OBJECT hbuf.

    END.

   {&OPEN-QUERY-br-field}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FillFilter C-Win
PROCEDURE FillFilter :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    EMPTY TEMP-TABLE tt-Filter.

    FOR EACH tt-field
        NO-LOCK:

        CREATE tt-Filter.
        ASSIGN tt-Filter.cField  = tt-field.cField.

    END.

   {&open-query-br-Filter}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FillIndex C-Win
PROCEDURE FillIndex :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER  p-recid AS CHARACTER  NO-UNDO.

    DEFINE VARIABLE cTableName    AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE hquery        AS HANDLE      NO-UNDO.

    EMPTY TEMP-TABLE tt-index.

    cTableName  = tt-db.cDb + '._index'.

    CREATE BUFFER hBuf FOR TABLE cTableName .

    CREATE QUERY hquery.
    hquery:SET-BUFFERS(hbuf).
    hquery:QUERY-PREPARE('for each ' + cTableName + ' where _file-recid = "' + p-recid + '" no-lock').
    hquery:QUERY-OPEN().
    hquery:GET-FIRST().

    DO WHILE NOT hquery:QUERY-OFF-END:

        CREATE tt-index.
        ASSIGN
            tt-index.cDb      = tt-table.cDB
            tt-index.cTable   = tt-table.cTable
            tt-index.cIndex   = hbuf:BUFFER-FIELD('_index-name'):BUFFER-VALUE
            /*   tt-index.cType    = hbuf:BUFFER-FIELD('_unique'):BUFFER-VALUE*/
            tt-index.cOrder   = int(hbuf:BUFFER-FIELD('_idx-num'):BUFFER-VALUE)
            .

        IF hbuf:BUFFER-FIELD('_unique'):BUFFER-VALUE THEN tt-index.cType = 'UNIQUE'.
        ELSE tt-index.cType = ''.


        hquery:GET-NEXT().

    END.

    DELETE OBJECT hbuf.

   {&OPEN-QUERY-br-index}

/*APPLY 'VALUE-CHANGED' TO BROWSE br-index.*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FillIndexFields C-Win
PROCEDURE FillIndexFields :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER  p-recid AS CHARACTER  NO-UNDO.


    DEFINE VARIABLE cTableIndexField    AS CHARACTER      NO-UNDO.
    DEFINE VARIABLE cTableField         AS CHARACTER      NO-UNDO.
    DEFINE VARIABLE hqueryIndexField    AS HANDLE         NO-UNDO.
    DEFINE VARIABLE hqueryField         AS HANDLE         NO-UNDO.
    DEFINE VARIABLE hBufIndexField      AS HANDLE         NO-UNDO.
    DEFINE VARIABLE hBufField           AS HANDLE         NO-UNDO.

    EMPTY TEMP-TABLE tt-indexField.

    IF AVAILABLE tt-index THEN DO:

        cTableIndexField = tt-db.cDb + '._index-field'.
        cTableField = tt-db.cDb + '._field'.

        CREATE BUFFER hBufIndexField FOR TABLE cTableIndexField .
        CREATE BUFFER hBufField FOR TABLE cTableField .

        CREATE QUERY hqueryIndexField.
        hqueryIndexField:SET-BUFFERS(hBufIndexField).
        hqueryIndexField:QUERY-PREPARE('for each ' + cTableIndexField + ' where _index-recid = "' + p-recid + '" no-lock').
        hqueryIndexField:QUERY-OPEN().

        CREATE QUERY hqueryField.
        hqueryField:SET-BUFFERS(hBufField).

        hqueryIndexField:GET-FIRST().
        DO WHILE NOT hqueryIndexField:QUERY-OFF-END:

            hqueryField:QUERY-PREPARE('for each ' + cTableField + ' where recid(' + cTableField + ') = "' + hBufIndexField:BUFFER-FIELD('_field-recid'):BUFFER-VALUE + '" no-lock').
            hqueryField:QUERY-OPEN().
            hqueryField:GET-FIRST().

            IF hqueryField:NUM-RESULTS <> 0 THEN DO:
                CREATE tt-indexField.
                ASSIGN
                    tt-indexField.cDb         = tt-index.cDB
                    tt-indexField.cTable      = tt-index.cTable
                    tt-indexField.cIndex      = tt-index.cIndex
                    tt-indexField.cIndexField = hBufField:BUFFER-FIELD('_field-name'):BUFFER-VALUE
                    tt-indexField.iOrder      = hBufIndexField:BUFFER-FIELD('_index-seq'):BUFFER-VALUE
                    tt-indexField.lAscending  = hBufIndexField:BUFFER-FIELD('_Ascending'):BUFFER-VALUE
               NO-ERROR.
            END.

            hqueryField:QUERY-CLOSE().

            hqueryIndexField:GET-NEXT().
        END.

        DELETE OBJECT hBufField.
        DELETE OBJECT hBufIndexField.
        DELETE OBJECT hqueryIndexField.
        DELETE OBJECT hqueryField.

    END.

   {&OPEN-QUERY-br-indexField}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FillTable C-Win
PROCEDURE FillTable :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE cTable           AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE hBuf             AS HANDLE      NO-UNDO.
    DEFINE VARIABLE hquery           AS HANDLE      NO-UNDO.
    DEFINE VARIABLE v-FilterString   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cTableRecid      AS CHARACTER   NO-UNDO.


    IF NOT AVAILABLE tt-db THEN RETURN.

    v-filterString = ' where yes '.

    IF w-tableBegins AND
        w-tableSearch <> '' THEN v-filterString = v-filterString + ' and  _File-name begins "' + w-tableSearch + '"'.

    IF w-hiddenTable THEN v-filterString = v-filterString + ' and _hidden = true'.
    ELSE v-filterString = v-filterString + ' and _hidden = false'.


    EMPTY TEMP-TABLE tt-table.

    cTable = tt-db.cDb + '._file'.

    CREATE BUFFER hBuf FOR TABLE cTable .

    CREATE QUERY hquery.
    hquery:SET-BUFFERS(hbuf).
    hquery:QUERY-PREPARE('for each ' + cTable + v-filterString + ' no-lock').
    hquery:QUERY-OPEN().
    hquery:GET-FIRST().

    DO WHILE NOT hquery:QUERY-OFF-END:

        CREATE tt-table.
        ASSIGN
            tt-table.cDb      = tt-db.cDB
            tt-table.cTable   = hbuf:BUFFER-FIELD('_File-name'):BUFFER-VALUE
            tt-table.cDesc    = IF hbuf:BUFFER-FIELD('_File-label'):BUFFER-VALUE <> ?
                             THEN hbuf:BUFFER-FIELD('_File-label'):BUFFER-VALUE
                             ELSE ''
            .
        hquery:GET-NEXT().

    END.

    DELETE OBJECT hbuf.

   {&OPEN-QUERY-br-table}

    APPLY 'VALUE-CHANGED' TO BROWSE br-table.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FilterData C-Win
PROCEDURE FilterData :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lFlag   AS CHARACTER  NO-UNDO.

    ASSIGN cDataWhereClause     = ''.

    FOR EACH tt-filter NO-LOCK:

        FIND FIRST tt-Field
            WHERE tt-Field.cField        = tt-Filter.cField
            AND INT(tt-Field.cExtent)  > 0
            NO-LOCK NO-ERROR.

        IF AVAILABLE tt-Field THEN DO:

            IF tt-filter.cFrom <> '' AND
                tt-filter.cFrom <> ? THEN DO:

                ASSIGN cDataWhereClause = cDataWhereClause + ' AND ('.

                DO i = 1 TO INT(tt-Field.cExtent):
                    cDataWhereClause = cDataWhereClause + tt-filter.cField + '[' + STRING(i) + '] >= "' + tt-filter.cFrom + '" OR '.
                END.

                ASSIGN cDataWhereClause = SUBSTRING(cDataWhereClause, 1, LENGTH(cDataWhereClause) - 3) + ')'. /* elimin ' OR ' de la final */

            END.

            IF tt-filter.cTo <> '' AND
                tt-filter.cTo <> ? THEN DO:

                ASSIGN cDataWhereClause = cDataWhereClause + ' AND ('.

                DO i = 1 TO INT(tt-Field.cExtent):
                    cDataWhereClause = cDataWhereClause + tt-filter.cField + '[' + STRING(i) + '] <= "' + tt-filter.cTo + '" OR '.
                END.

                ASSIGN cDataWhereClause = SUBSTRING(cDataWhereClause, 1, LENGTH(cDataWhereClause) - 3) + ')'. /* elimin ' OR ' de la final */

            END.

            IF tt-filter.cContains <> '' AND
                tt-filter.cContains <> ? THEN DO:

                ASSIGN cDataWhereClause = cDataWhereClause + ' AND ('.

                FIND FIRST tt-Field
                    WHERE tt-Field.cField = tt-Filter.cField
                    NO-LOCK NO-ERROR.

                IF AVAILABLE tt-Field AND
                    tt-field.cDataType = 'CHARACTER' THEN
                DO i = 1 TO INT(tt-Field.cExtent):
                    cDataWhereClause = cDataWhereClause + ' INDEX(' + tt-filter.cField + '[' + STRING(i) + '],' + QUOTER(tt-filter.cContains) + ') > 0 OR '.
                END.
                ELSE
                DO i = 1 TO INT(tt-Field.cExtent):
                    cDataWhereClause = cDataWhereClause + tt-filter.cField + '[' + STRING(i) + '] = ' + tt-filter.cContains + ' OR '.
                END.

                ASSIGN cDataWhereClause = SUBSTRING(cDataWhereClause, 1, LENGTH(cDataWhereClause) - 3) + ')'.

            END.

        END. /* IF AVAILABLE tt-Field */
        ELSE DO:

            IF tt-filter.cFrom <> '' AND
                tt-filter.cFrom <> ? THEN cDataWhereClause = cDataWhereClause + ' and ' + tt-filter.cField + ' >= "' + tt-filter.cFrom + '"'.

            IF tt-filter.cTo <> '' AND
                tt-filter.cTo <> ? THEN cDataWhereClause = cDataWhereClause + ' and ' + tt-filter.cField + ' <= "' + tt-filter.cTo + '"'.

            IF tt-filter.cContains <> '' AND
                tt-filter.cContains <> ? THEN DO:

                FIND FIRST tt-Field
                    WHERE tt-Field.cField = tt-Filter.cField
                    NO-LOCK NO-ERROR.

                IF AVAILABLE tt-Field AND
                    tt-field.cDataType = 'CHARACTER' THEN
                    cDataWhereClause = cDataWhereClause + ' and INDEX(' + tt-filter.cField + ',"' + tt-filter.cContains + '") > 0'.
                ELSE
                    cDataWhereClause = cDataWhereClause + ' and ' + tt-filter.cField + ' = ' + tt-filter.cContains .

            END.

        END.

    END. /* EACH tt-filter */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FindTable C-Win
PROCEDURE FindTable :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE cTableName AS CHARACTER  NO-UNDO.

    FIND FIRST tt-table
        WHERE tt-table.cDb      = tt-db.cDb
        AND tt-table.cTable  >= w-tableSearch
        NO-LOCK NO-ERROR.

    IF AVAILABLE tt-table THEN DO:

        REPOSITION br-table TO ROWID ROWID(tt-table) NO-ERROR.

        IF NOT ERROR-STATUS:ERROR THEN APPLY 'VALUE-CHANGED' TO BROWSE br-Table.

    END. /* IF AVAILABLE tt-table */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FindTablesforField C-Win
PROCEDURE FindTablesforField :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE cTableField      AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cTableFile       AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE hBufField        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hBufFile         AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hqueryField      AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hqueryFile       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE v-filterString   AS CHARACTER   NO-UNDO.


    EMPTY TEMP-TABLE tt-table.

    ASSIGN
        cTableField = tt-Db.cDb + '._field'
        cTableFile  = tt-Db.cDb + '._file'.

    CREATE BUFFER hBufField FOR TABLE cTableField.
    CREATE BUFFER hBufFile  FOR TABLE cTableFile.

    CREATE QUERY hqueryField.
    hqueryField:SET-BUFFERS(hBufField).

    IF w-FieldMatches THEN
        hqueryField:QUERY-PREPARE('for each ' + cTableField + ' where ' + cTableField + '._field-name MATCHES "*' + w-FieldSearch + '*" no-lock').
    ELSE
        hqueryField:QUERY-PREPARE('for each ' + cTableField + ' where ' + cTableField + '._field-name = "' + w-FieldSearch + '" no-lock').

    hqueryField:QUERY-OPEN().
    hqueryField:GET-FIRST().

    CREATE QUERY hqueryFile.
    hqueryFile:SET-BUFFERS(hBufFile).

    /* introduc conditiile de filtrare */
    v-filterString = ''.
    IF w-tableBegins AND
        w-tableSearch <> '' THEN v-filterString = v-filterString + ' and _File-name begins "' + w-tableSearch + '"'.

    IF w-hiddenTable THEN v-filterString = v-filterString + ' and _hidden = true'.
    ELSE v-filterString = v-filterString + ' and _hidden = false'.
    /* conditiile de filtrare */

    DO WHILE NOT hqueryField:QUERY-OFF-END:

        hqueryFile:QUERY-PREPARE('for each ' + cTableFile + ' where recid(' + cTableFile + ') = ' + hBufField:BUFFER-FIELD('_file-recid'):BUFFER-VALUE + v-filterString + ' no-lock').
        hqueryFile:QUERY-OPEN().
        hqueryFile:GET-FIRST().

        IF hqueryFile:NUM-RESULTS <> 0 THEN

            IF NOT CAN-FIND (FIRST tt-table
                WHERE tt-table.cTable = STRING(hBufFile:BUFFER-FIELD('_File-name'):BUFFER-VALUE) ) THEN DO:
                CREATE tt-table.
                ASSIGN
                    tt-table.cDb      = tt-db.cDB
                    tt-table.cTable   = hBufFile:BUFFER-FIELD('_File-name'):BUFFER-VALUE
                    tt-table.cDesc    = IF hBufFile:BUFFER-FIELD('_File-label'):BUFFER-VALUE <> ?
                                   THEN hBufFile:BUFFER-FIELD('_File-label'):BUFFER-VALUE
                                   ELSE ''
                    .

            END.

        hqueryFile:QUERY-CLOSE().

        hqueryField:GET-NEXT().

    END.

    DELETE OBJECT hBufField.
    DELETE OBJECT hBufFile.
    DELETE OBJECT hqueryField.
    DELETE OBJECT hqueryFile.

   {&OPEN-QUERY-br-table}

    APPLY 'VALUE-CHANGED' TO BROWSE br-table.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetTotalRecNo C-Win
PROCEDURE GetTotalRecNo :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE v-query_prepare        AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE v-prepare_string_old   AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE hqueryCount            AS HANDLE     NO-UNDO.

    CREATE QUERY hqueryCount.
    hqueryCount:SET-BUFFERS(hBufTable).
    hqueryCount:QUERY-PREPARE(cQueryDataString + cDataWhereClause + cSortDataString) NO-ERROR.

    ASSIGN
        cQueryDataString     = REPLACE (cQueryDataString, 'FOR EACH', 'PRESELECT EACH')
        v-prepare_string_old = hqueryCount:PREPARE-STRING.
    v-query_prepare      = hqueryCount:QUERY-PREPARE(cQueryDataString + cDataWhereClause + cSortDataString)
        NO-ERROR.

    IF NOT v-query_prepare THEN hqueryCount:QUERY-PREPARE(v-prepare_string_old).

    hqueryCount:QUERY-OPEN() NO-ERROR.

    ASSIGN
        w-recNo:SCREEN-VALUE IN FRAME FRM-DATA = STRING(hqueryCount:NUM-RESULTS)
        cQueryDataString     = REPLACE (cQueryDataString, 'PRESELECT EACH', 'FOR EACH' ).

    DELETE OBJECT hqueryCount .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE HideFrmColumns C-Win
PROCEDURE HideFrmColumns :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    ASSIGN
        FRAME frm-Columns:VISIBLE  = FALSE
        hbr-Data:ROW               = BROWSE br-Filter:ROW
        hbr-Data:HEIGHT            = BROWSE br-Filter:HEIGHT
        .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE InitProgram C-Win
PROCEDURE InitProgram :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    ASSIGN
        BROWSE br-db:COLUMN-RESIZABLE                  = TRUE
        BROWSE br-table:COLUMN-RESIZABLE               = TRUE
        BROWSE br-index:COLUMN-RESIZABLE               = TRUE
        BROWSE br-indexField:COLUMN-RESIZABLE          = TRUE
        BROWSE br-Field:COLUMN-RESIZABLE               = TRUE
        BROWSE br-Filter:COLUMN-RESIZABLE              = TRUE
        BROWSE br-Filter:READ-ONLY                     = FALSE
        FRAME frm-Columns:VISIBLE                      = FALSE
        FRAME frm-Columns:SCROLLABLE                   = FALSE
        v-mod                                          = 'Data'
        .

    RUN FillDb.

    RUN ChangeViewMode.

    APPLY 'ENTRY' TO w-tableSearch IN FRAME frm-schema.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE onRowDisplay C-Win
PROCEDURE onRowDisplay :
/*------------------------------------------------------------------------------
  Purpose:
------------------------------------------------------------------------------*/



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE onLeavecFrombrFilter C-Win
PROCEDURE onLeavecFrombrFilter :
    /*------------------------------------------------------------------------------
      Purpose:    onLeavecFrombrFilter
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE hcol_cFrom AS HANDLE      NO-UNDO.
    DEFINE VARIABLE hcol_cTo  AS HANDLE      NO-UNDO.

    IF hbr-Filter:CURRENT-ROW-MODIFIED THEN DO:

        hcol_cFrom = hbr-Filter:GET-BROWSE-COLUMN(2).
        hcol_cTo  = hbr-Filter:GET-BROWSE-COLUMN(3).
        /*
              IF hcol_cFrom:MODIFIED AND
                (
                    hcol_cTo:SCREEN-VALUE = '':U OR
                    hcol_cTo:SCREEN-VALUE = ?
                )
              THEN hcol_cTo:SCREEN-VALUE = hcol_cFrom:SCREEN-VALUE.
        */
        IF hcol_cFrom:MODIFIED THEN hcol_cTo:SCREEN-VALUE = hcol_cFrom:SCREEN-VALUE.

    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE onStartSearch C-Win
PROCEDURE onStartSearch :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    /*
       IF INDEX(cSortDataString,hbr-Data:CURRENT-COLUMN:NAME) > 0
       THEN
          IF INDEX(cSortDataString,' DESCENDING ') > 0
          THEN
             cSortDataString = ' by ' + hbr-Data:CURRENT-COLUMN:NAME .
          ELSE
             cSortDataString = ' by ' + hbr-Data:CURRENT-COLUMN:NAME + ' DESCENDING '.
        ELSE
           cSortDataString = ' by ' + hbr-Data:CURRENT-COLUMN:NAME .
    */


    IF INDEX(cSortDataString,hbr-Data:CURRENT-COLUMN:LABEL) > 0 THEN
        IF INDEX(cSortDataString,' DESCENDING ') > 0 THEN
            cSortDataString = ' by ' + hbr-Data:CURRENT-COLUMN:LABEL .
        ELSE
            cSortDataString = ' by ' + hbr-Data:CURRENT-COLUMN:LABEL + ' DESCENDING '.
    ELSE
        cSortDataString = ' by ' + hbr-Data:CURRENT-COLUMN:LABEL .

    RUN OpenQuery.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OnWindowResized C-Win
PROCEDURE OnWindowResized :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/
    ASSIGN RECT-1:WIDTH-CHARS IN FRAME DEFAULT-FRAME = c-Win:WIDTH - 1.

    IF v-Mod = 'Data' THEN
    DO WITH FRAME frm-data:

        ASSIGN
            w-SearchFilterField:WIDTH     = BROWSE br-Filter:GET-BROWSE-COLUMN(1):WIDTH
            hbr-Data:WIDTH                = c-Win:WIDTH - {&FRAME-COLUMNS-COL}
            br-Filter:HEIGHT              = c-Win:HEIGHT - 5.3
            btn-FreeQuery:WIDTH           = 12
            btn-FreeQuery:HEIGHT          = 1.9
            btn-FreeQuery:COLUMN          = c-Win:WIDTH - {&BUTTON-FREEQUERY-WIDTH} - 0.5
            ed-FreeQuery:WIDTH            = c-Win:WIDTH - {&EDITOR-FREEQUERY-COL}   - {&BUTTON-FREEQUERY-WIDTH} - 0.5
            FRAME frm-Columns:WIDTH       = c-Win:WIDTH - {&FRAME-COLUMNS-COL}
            RECT-4:WIDTH                  = c-Win:WIDTH - w-SearchFilterField:WIDTH - 2
            w-recNo:COL                  = c-Win:WIDTH - w-recNo:WIDTH
            btn_RecNo:COL                = c-Win:WIDTH - w-recNo:WIDTH - btn_RecNo:WIDTH
            NO-ERROR.

        IF FRAME frm-Columns:VISIBLE = FALSE THEN ASSIGN hbr-Data:HEIGHT      = c-Win:HEIGHT - 5.3 NO-ERROR.
        ELSE ASSIGN hbr-Data:HEIGHT      = c-Win:HEIGHT - {&FRAME-COLUMNS-HEIGHT} - 5.3 NO-ERROR.

        IF FRAME frm-Columns:WIDTH < 121.6 THEN FRAME frm-Columns:SCROLLABLE = TRUE.
        ELSE FRAME frm-Columns:SCROLLABLE = FALSE.

    END.
    ELSE /* SCHEMA */
    DO WITH FRAME frm-schema:

        ASSIGN
            br-indexField:WIDTH           = c-Win:WIDTH  - br-indexField:COLUMN - 0.5
            br-Field:WIDTH                = c-Win:WIDTH  - br-Field:COLUMN - 0.5
            br-Field:HEIGHT               = c-Win:HEIGHT - br-Field:ROW - 1
            w-SearchFieldName:WIDTH      = BROWSE br-Field:GET-BROWSE-COLUMN(1):WIDTH + 1
            RECT-3:COL                   = w-SearchFieldName:WIDTH + 2
            RECT-3:WIDTH                 = c-Win:WIDTH - w-SearchFieldName:WIDTH - 2
            NO-ERROR.

    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenQuery C-Win
PROCEDURE OpenQuery :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE v-query_prepare        AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE v-prepare_string_old   AS CHARACTER   NO-UNDO.

    ASSIGN v-prepare_string_old = hqueryData:PREPARE-STRING.

    hqueryData:QUERY-CLOSE().

    v-query_prepare = hqueryData:QUERY-PREPARE(cQueryDataString + cDataWhereClause + cSortDataString) NO-ERROR.
    IF NOT v-query_prepare THEN DO:
        MESSAGE 'Incompatible data types in assignment!'
            VIEW-AS ALERT-BOX INFO BUTTONS OK.

        hqueryData:QUERY-PREPARE(v-prepare_string_old).
    END.

    hqueryData:QUERY-OPEN() NO-ERROR.

    ASSIGN ed-FreeQuery:SCREEN-VALUE IN FRAME frm-data = hQueryData:PREPARE-STRING NO-ERROR.

    w-recNo:SCREEN-VALUE = ''.

    IF hQueryData:NUM-RESULTS > 0 THEN ENABLE  Btn-save WITH FRAME frm-data.
    ELSE DISABLE Btn-save WITH FRAME frm-data.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RecordAdd C-Win
PROCEDURE RecordAdd :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    MESSAGE 'Are you sure you want to add a new record?'
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE vAnswer AS LOGICAL.

    IF vAnswer = NO THEN RETURN.

    IF hBufTable:DISABLE-LOAD-TRIGGERS(FALSE) = FALSE THEN DO:
        MESSAGE 'You can not delete records from this table.'
            VIEW-AS ALERT-BOX INFO BUTTONS OK.

        RETURN.
    END.

    /* set visible all columns */
    APPLY 'CHOOSE' TO btn-SelectAll IN FRAME FRM-COLUMNS.
    APPLY 'CHOOSE' TO btn-Ok IN FRAME FRM-COLUMNS.

    DO TRANSACTION:

        hBufTable:BUFFER-CREATE() NO-ERROR.

        IF ERROR-STATUS:ERROR THEN DO:
            MESSAGE "New record could not be created."
                VIEW-AS ALERT-BOX INFO BUTTONS OK.

        END.

        hBufTable:VALIDATE() NO-ERROR.

        IF ERROR-STATUS:ERROR THEN DO:
            MESSAGE "New record could not be validated."
                VIEW-AS ALERT-BOX INFO BUTTONS OK.

        END.

        ASSIGN v-rowid = hBufTable:ROWID.

        IF LOOKUP (STRING(v-rowid), cChangedRecords, CHR(3)) = 0 THEN cChangedRecords = cChangedRecords + STRING(v-rowid) + CHR(3).

    END. /* TRANSACTION */

    RUN EmptyFilter.
    RUN OpenQuery.

    hqueryData:REPOSITION-TO-ROWID(v-rowid) NO-ERROR.

/*
   hBufTable:FIND-BY-ROWID(v-rowid, EXCLUSIVE-LOCK) NO-ERROR.
   IF NOT ERROR-STATUS:ERROR
   THEN hBufTable:BUFFER-DELETE() NO-ERROR.
*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RecordDelete C-Win
PROCEDURE RecordDelete :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE v-rowid    AS ROWID    NO-UNDO.

    MESSAGE 'Are you sure you want to delete this record?'
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE vAnswer AS LOGICAL.

    IF vAnswer = NO THEN RETURN.

    IF hBufTable:DISABLE-LOAD-TRIGGERS(FALSE)  = FALSE OR
        hBufTable:DISABLE-DUMP-TRIGGERS()      = FALSE THEN DO:
        MESSAGE 'You can not delete records from this table.'
            VIEW-AS ALERT-BOX INFO BUTTONS OK.

        RETURN.
    END.

    hbr-Data:SELECT-FOCUSED-ROW().

    DO TRANSACTION:

        hBufTable:FIND-CURRENT(EXCLUSIVE-LOCK).
        hBufTable:BUFFER-DELETE() NO-ERROR.

        IF ERROR-STATUS:ERROR THEN MESSAGE "Record could not be deleted.".

    END. /*  DO TRANSACTION: */

    RUN OpenQuery.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RecordSave C-Win
PROCEDURE RecordSave :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE i    AS INTEGER    NO-UNDO.
    DEFINE VARIABLE ext  AS INTEGER    NO-UNDO.

    MESSAGE 'Are you sure you want to save this record ?'
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE vSave AS LOGICAL.

    IF NOT vSave THEN DO:

        hqueryData:QUERY-CLOSE().
        hqueryData:QUERY-OPEN().

        RETURN.

    END.

    IF hBufTable:DISABLE-LOAD-TRIGGERS(FALSE) = FALSE THEN DO:
        MESSAGE 'You can not save records in this table.'
            VIEW-AS ALERT-BOX INFO BUTTONS OK.

        RUN OpenQuery.

        RETURN.
    END.

    hbr-Data:SELECT-FOCUSED-ROW().

    DO TRANSACTION:

        hBufTable:FIND-CURRENT(EXCLUSIVE-LOCK) NO-ERROR.

        IF ERROR-STATUS:ERROR THEN DO:

            MESSAGE "Record is not available.".

            RUN OpenQuery.

            RETURN.

        END.

        ASSIGN v-rowid = hBufTable:ROWID.

        DO i = 1 TO hbr-Data:NUM-COLUMNS:

            FIND FIRST tt-Field
                WHERE tt-Field.cField        = STRING(hbr-Data:GET-BROWSE-COLUMN(i):BUFFER-FIELD:NAME)
                AND INT(tt-Field.cExtent) <> 0 NO-ERROR.

            IF AVAILABLE tt-Field THEN DO:
                IF tt-Field.cField <> STRING(hbr-Data:GET-BROWSE-COLUMN(i - 1):BUFFER-FIELD:NAME) THEN ext = 1.
                ELSE ext = ext + 1.

                hBufTable:BUFFER-FIELD(hbr-Data:GET-BROWSE-COLUMN(i):BUFFER-FIELD:NAME):BUFFER-VALUE[ext]
                = hbr-Data:GET-BROWSE-COLUMN(i):SCREEN-VALUE NO-ERROR.
            END.
            ELSE DO:

                hBufTable:BUFFER-FIELD(hbr-Data:GET-BROWSE-COLUMN(i):BUFFER-FIELD:NAME):BUFFER-VALUE
                = hbr-Data:GET-BROWSE-COLUMN(i):SCREEN-VALUE NO-ERROR.

            END.

            IF ERROR-STATUS:ERROR THEN DO:

                MESSAGE "Record can not be saved." SKIP
                    ERROR-STATUS:GET-MESSAGE(1).

                RUN OpenQuery.

                RETURN.

            END.

        END. /* DO i = 1 TO hbr-Data:NUM-COLUMNS */

    END. /*  DO TRANSACTION: */.

    IF LOOKUP (STRING(v-rowid), cChangedRecords, CHR(3)) = 0 THEN cChangedRecords = cChangedRecords + STRING(v-rowid) + CHR(3).

    RUN OpenQuery.

    hqueryData:REPOSITION-TO-ROWID (v-rowid) NO-ERROR.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SelectDataColumns C-Win
PROCEDURE SelectDataColumns :
/*------------------------------------------------------------------------------
  Purpose:
------------------------------------------------------------------------------*/

   {&OPEN-QUERY-br-AllColumns}
   {&OPEN-QUERY-br-VisibleColumns}

    ASSIGN
        hbr-Data:HEIGHT            = BROWSE br-Filter:HEIGHT  - {&FRAME-COLUMNS-HEIGHT} - 0.1
        hbr-Data:ROW               = FRAME frm-Columns:HEIGHT + {&FRAME-COLUMNS-ROW}    + 0.05
        FRAME frm-columns:COLUMN   = hbr-Data:COLUMN
        FRAME frm-columns:WIDTH    = hbr-Data:WIDTH
        FRAME frm-Columns:VISIBLE  = TRUE
      NO-ERROR.

    FRAME frm-columns:MOVE-TO-TOP().

    FIND FIRST tt-Field NO-ERROR.

    IF NOT CAN-FIND(FIRST tt-NonVisibleColumns
        WHERE tt-NonVisibleColumns.cTable = cLastSelectedTable) THEN DO:

        FOR EACH tt-Field NO-LOCK BY tt-Field.cField:

            CREATE tt-NonVisibleColumns.
            ASSIGN
                tt-NonVisibleColumns.cTable = cLastSelectedTable
                tt-NonVisibleColumns.cField = tt-Field.cField
                .

        END. /* EACH tt-Field */

        FOR EACH tt-VisibleColumns
            WHERE tt-VisibleColumns.cTable = cLastSelectedTable:

            DELETE tt-VisibleColumns.

        END.

    END.

   {&OPEN-QUERY-br-AllColumns}
   {&OPEN-QUERY-br-VisibleColumns}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SetVisibleColumns C-Win
PROCEDURE SetVisibleColumns :
    /*------------------------------------------------------------------------------
      Purpose:   SetVisibleColumns
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE i       AS INTEGER    NO-UNDO.

    IF NOT CAN-FIND (FIRST tt-VisibleColumns
        WHERE tt-VisibleColumns.cTable = cLastSelectedTable) THEN DO:

        FOR EACH tt-Field NO-LOCK BY tt-Field.cField:

            CREATE tt-VisibleColumns.
            ASSIGN
                tt-VisibleColumns.cTable   = cLastSelectedTable
                tt-VisibleColumns.cField   = tt-Field.cField
                .

        END. /* EACH tt-Field */

        FOR EACH tt-NonVisibleColumns:
            DELETE tt-NonVisibleColumns.
        END.

    END.

    DO i = 1 TO hbr-Data:NUM-COLUMNS:

        IF CAN-FIND (FIRST tt-VisibleColumns
            WHERE tt-VisibleColumns.cTable = cLastSelectedTable
            AND tt-VisibleColumns.cField = hCol[i]:NAME) THEN ASSIGN hCol[i]:VISIBLE = TRUE.
        ELSE ASSIGN hCol[i]:VISIBLE = FALSE.

    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ShowDataColumns C-Win
PROCEDURE ShowDataColumns :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE v-colName     AS CHARACTER  NO-UNDO INIT ''.
    DEFINE VARIABLE v-colLabel    AS CHARACTER  NO-UNDO INIT ''.
    DEFINE VARIABLE v-posX        AS INTEGER    NO-UNDO.
    DEFINE VARIABLE i             AS INTEGER    NO-UNDO.
    DEFINE VARIABLE v-found       AS LOGICAL    NO-UNDO.


    ASSIGN v-posX = FOCUS:X.

    DO i = 1 TO nrColumn - 1:

        IF hcol[i]:X      <= v-posX AND
            hcol[i + 1]:X  >  v-posX THEN DO:
            ASSIGN
                v-colName  = hcol[i]:NAME.
            v-colLabel = hcol[i]:LABEL.

            IF INDEX(v-colLabel, '[') > 0 THEN v-colLabel =  SUBSTRING(v-colLabel, LENGTH(v-colLabel) - 1, 1).

            LEAVE.
        END.

    END.

    IF hcol[nrColumn]:X <= v-posX THEN DO:
        ASSIGN
            v-colName  = hcol[nrColumn]:NAME
            v-colLabel = hcol[nrColumn]:LABEL.

        IF INDEX(v-colLabel, '[') > 0 THEN v-colLabel =  SUBSTRING(v-colLabel, LENGTH(v-colLabel) - 1, 1).
    END.

    IF v-ColName = '' THEN RETURN.

    ASSIGN v-found = hBufTable:FIND-CURRENT(NO-LOCK) NO-ERROR.

    IF NOT v-found THEN RETURN.

    ASSIGN i = INT(v-colLabel) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN MESSAGE hBufTable:BUFFER-FIELD(v-ColName):BUFFER-VALUE.
    ELSE MESSAGE hBufTable:BUFFER-FIELD(v-ColName):BUFFER-VALUE[i].


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GetTableRecid C-Win
FUNCTION GetTableRecid RETURNS CHARACTER
    ( /* parameter-definitions */ ) :

    DEFINE VARIABLE cTableRecid AS CHARACTER.

    CREATE BUFFER hBuf FOR TABLE  tt-db.cDb + '._file'.

    hbuf:FIND-FIRST('where _file-name = "' + tt-table.cTable + '"').

    IF hbuf:AVAILABLE THEN cTableRecid = STRING(hbuf:RECID).
    DELETE OBJECT hbuf.

    RETURN cTableRecid.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isCorrectDataType C-Win
FUNCTION isCorrectDataType RETURNS LOGICAL
    ( INPUT p-field     AS CHARACTER,
    INPUT p-data_type AS CHARACTER
    ) :
    /*------------------------------------------------------------------------------
      Purpose:
    ------------------------------------------------------------------------------*/

    CASE p-data_type:

        WHEN 'INTEGER'
        THEN DO:

                DEFINE VARIABLE v-itemp AS INTEGER    NO-UNDO.

                v-itemp = INTEGER(p-field) NO-ERROR.
                IF ERROR-STATUS:ERROR THEN RETURN FALSE.

            END.

        WHEN 'DECIMAL'
        THEN DO:

                DEFINE VARIABLE v-detemp AS DECIMAL    NO-UNDO.

                v-detemp = DECIMAL(p-field) NO-ERROR.
                IF ERROR-STATUS:ERROR THEN RETURN FALSE.

            END.

        WHEN 'LOGICAL'
        THEN DO:

                DEFINE VARIABLE v-ltemp AS LOGICAL    NO-UNDO.

                v-ltemp = LOGICAL(p-field) NO-ERROR.
                IF ERROR-STATUS:ERROR THEN RETURN FALSE.

            END.

        WHEN 'DATE'
        THEN DO:

                DEFINE VARIABLE v-dttemp AS DATE    NO-UNDO.

                v-dttemp = DATE(p-field) NO-ERROR.
                IF ERROR-STATUS:ERROR THEN RETURN FALSE.

            END.

    END CASE.


    RETURN TRUE.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

