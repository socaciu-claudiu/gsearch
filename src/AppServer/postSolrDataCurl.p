
/*------------------------------------------------------------------------
    File        : postSolrDataCurl.p
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
DEFINE INPUT PARAMETER cpDataFilePath AS CHARACTER NO-UNDO.

DEFINE VARIABLE cCurlCommand AS CHARACTER NO-UNDO.
DEFINE VARIABLE cPostUrl     AS CHARACTER NO-UNDO.
DEFINE VARIABLE icLongBody   AS CHARACTER NO-UNDO.

ASSIGN
    cPostUrl     = '"http://localhost:8983/solr/globalsearch/update"'
    icLongBody   = SESSION:TEMP-DIRECTORY + GUID(GENERATE-UUID) + ".body"
    cCurlCommand = SUBSTITUTE ("curl --request POST --data-binary @&2    &1 --output &3", cPostUrl, cpDataFilePath, icLongBody)
    .

MESSAGE "cCurlCommand:" cCurlCommand VIEW-AS ALERT-BOX.


OS-COMMAND SILENT VALUE(cCurlCommand).

/* Delete  temp files for stream */
IF OPSYS = "UNIX" THEN
    OS-COMMAND SILENT VALUE("rm -f " + cpDataFilePath).
ELSE
    OS-COMMAND SILENT VALUE("del " + cpDataFilePath).

IF OPSYS = "UNIX" THEN
    OS-COMMAND SILENT VALUE("rm -f " + icLongBody).
ELSE
    OS-COMMAND SILENT VALUE("del " + icLongBody).
