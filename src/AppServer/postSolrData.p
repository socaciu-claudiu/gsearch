
/*------------------------------------------------------------------------
    File        : postSolrData.p
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
USING OpenEdge.Net.HTTP.IHttpRequest.
USING OpenEdge.Net.HTTP.IHttpResponse.
USING OpenEdge.Net.HTTP.ClientBuilder.
USING OpenEdge.Net.HTTP.IHttpClientLibrary.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.
USING OpenEdge.Net.HTTP.RequestBuilder.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.


DEFINE VARIABLE oLib         AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
DEFINE VARIABLE oHttpClient  AS OpenEdge.Net.HTTP.IHttpClient        NO-UNDO.
DEFINE VARIABLE oRequest     AS IHttpRequest                         NO-UNDO.
DEFINE VARIABLE oResponse    AS IHttpResponse                        NO-UNDO.
DEFINE VARIABLE oRequestBody AS Progress.Lang.Object                 NO-UNDO. /* this is the XML payload to update the SOLR data */
ASSIGN
    oLib        = ClientLibraryBuilder:Build():sslVerifyHost(NO):library
    oHttpClient = ClientBuilder:Build():UsingLibrary(oLib):Client
    oRequest    = RequestBuilder:Post('http://localhost:8983/solr/globalsearch/update', oRequestBody):ContentType("application/xml"):Request
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
