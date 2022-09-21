
/*------------------------------------------------------------------------
    File        : getSolrData.p
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

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING OpenEdge.Net.HTTP.IHttpRequest.
USING OpenEdge.Net.HTTP.IHttpResponse.
USING OpenEdge.Net.HTTP.ClientBuilder.
USING OpenEdge.Net.HTTP.IHttpClientLibrary.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.
USING OpenEdge.Net.HTTP.RequestBuilder.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.

/* ***************************  Session config  *************************** */
/* OPTIONAL FOR DEBUG/TRACING
*/
SESSION:ERROR-STACK-TRACE = TRUE.
SESSION:DEBUG-ALERT = TRUE.
LOG-MANAGER:LOGFILE-NAME  = SESSION:TEMP-DIR + '/debug_json_txt.log'.
LOG-MANAGER:LOGGING-LEVEL = 6.
LOG-MANAGER:CLEAR-LOG().


DEFINE VARIABLE oLib        AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
DEFINE VARIABLE oHttpClient AS OpenEdge.Net.HTTP.IHttpClient        NO-UNDO.
DEFINE VARIABLE oRequest    AS IHttpRequest                         NO-UNDO.
DEFINE VARIABLE oResponse   AS IHttpResponse                        NO-UNDO.

ASSIGN
    oLib        = ClientLibraryBuilder:Build():sslVerifyHost(NO):library
    oHttpClient = ClientBuilder:Build():UsingLibrary(oLib):Client
    oRequest    = RequestBuilder:Get('http://localhost:8983/solr/globalsearch/select?fq=entity:customer&q=text:*63621*&wt=json'):AcceptAll():Request
    oResponse   = oHttpClient:Execute(oRequest).

MESSAGE
    oResponse:StatusCode SKIP
    oResponse:StatusReason SKIP
    oResponse:ContentType SKIP
    STRING(oResponse:Entity)   /* this is the response */
    VIEW-AS ALERT-BOX.
IF oResponse:StatusCode = 200 THEN
    CAST(oResponse:entity, JsonArray):WriteFile('c:\OpenEdge\WRK\response.json', TRUE).

CATCH oError AS Progress.Lang.Error:
    MESSAGE "err" SKIP  oError:GetMessage(1) SKIP
        oError:callStack
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
END CATCH.
