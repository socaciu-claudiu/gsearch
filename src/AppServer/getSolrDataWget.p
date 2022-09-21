
/*------------------------------------------------------------------------
    File        : getSolrDataWget.p
    Purpose     :

    Syntax      :

    Description :

    Author(s)   : claus
    Created     :
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE INPUT PARAMETER cpSearchText   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER cpSearchEntity AS CHARACTER NO-UNDO.

DEFINE VARIABLE icJsonResp     AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE cWgetCommand   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cBaseSearchUrl AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFilterEntity  AS CHARACTER NO-UNDO.
DEFINE VARIABLE icLongBody     AS CHARACTER NO-UNDO.

ASSIGN
    cFilterEntity  = IF cpSearchEntity <> "" AND cpSearchEntity <> ? THEN ("&fq=entity:" + cpSearchEntity) ELSE ""
    cBaseSearchUrl = '"http://localhost:8983/solr/globalsearch/select?wt=json&q=text:(' + cpSearchText + " OR " + cpSearchText + '*)' + cFilterEntity + '"'
    icLongBody     = SESSION:TEMP-DIRECTORY + GUID(GENERATE-UUID) + ".body"
    cWgetCommand   = SUBSTITUTE ('wget -q &1 --output-document=&2', cBaseSearchUrl, QUOTER(icLongBody))
    .

MESSAGE "cWgetCommand:" cWgetCommand VIEW-AS ALERT-BOX.


OS-COMMAND SILENT VALUE(cWgetCommand).

COPY-LOB FROM FILE icLongBody TO icJsonResp NO-CONVERT NO-ERROR.

MESSAGE STRING(icJsonResp)
    VIEW-AS ALERT-BOX.
/* Delete  temp files for stream */

IF OPSYS = "UNIX" THEN
    OS-COMMAND SILENT VALUE("rm -f " + icLongBody).
ELSE
    OS-COMMAND SILENT VALUE("del " + icLongBody).
