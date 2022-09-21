
/*------------------------------------------------------------------------
    File        : cusomerentity.p
    Purpose     : create an xml document to be used for data update in SOLR

    Syntax      :

    Description :

    Author(s)   : claus
    Created     :
    Notes       :
  ----------------------------------------------------------------------*/

/* Request example */
/*
<?xml version="1.0" encoding="utf-8" ?>
<update>
    <add>
        <doc>
            <field name="id">custnum=7889</field>
            <field name="entity">customer</field>
            <field name="active">true</field>
            <field name="valid_start">2022-01-01T00:00:00Z</field>
            <field name="valid_end">2029-11-29T00:00:00Z</field>
            <field name="text">TIL127</field>
            <field name="parent_id">adrs-nummer=1164</field>
            <field name="orga">?</field>
        </doc>
    </add>
    <commit/>
    </update>
*/


/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

DEFINE INPUT PARAMETER pi-custnum AS INTEGER NO-UNDO.
DEFINE VARIABLE icXmlReq    AS LONGCHAR                         NO-UNDO.
DEFINE VARIABLE icDataFile  AS CHARACTER                        NO-UNDO.

{dsUpdateSolr.i}

FOR EACH customer WHERE customer.custnum = pi-custnum NO-LOCK:
    LEAVE.
END.

IF NOT AVAILABLE customer THEN
    RETURN ERROR SUBSTITUTE ("Customer witd ID &1 not found!", STRING(pi-custnum) ).


CREATE ttUpdate.
ASSIGN ttUpdate.updateID  = '1'
    .

CREATE ttCommit.
ASSIGN ttCommit.updateID  = '1'
    .

CREATE ttAdd.
ASSIGN ttAdd.updateID     = '1'
    ttAdd.addID           = STRING(customer.custnum)
    .

CREATE ttDoc.
ASSIGN ttDoc.docID        = '1'
    ttDoc.addID           = STRING(customer.custnum)
    .

CREATE ttDocField.
ASSIGN ttDocField.docID   = '1'
    ttDocField.DocFieldID = GUID(GENERATE-UUID)
    ttDocField.FieldName  = 'id'
    ttDocField.FieldVal   = "customer=" + string(customer.custnum)
    .


CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'entity'
    ttDocField.FieldVal    = "customer"
    .

CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'active'
    ttDocField.FieldVal    = "true"
    .

CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'parent_id'
    ttDocField.FieldVal    = "?"
    .

CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'orga'
    ttDocField.FieldVal    = "?"
    .

CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'valid_start'
    ttDocField.FieldVal    = solrDate(TODAY)
    .

CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'valid_end'
    ttDocField.FieldVal    = solrDate(TODAY)
    .

CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'text'
    ttDocField.FieldVal    = customer.Address + " " + customer.city + " " + customer.country
    .


CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'text'
    ttDocField.FieldVal    = customer.Contact
    .

CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'text'
    ttDocField.FieldVal    = customer.name
    .

CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'text'
    ttDocField.FieldVal    = customer.Phone
    .

CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'text'
    ttDocField.FieldVal    = customer.PostalCode
    .

CREATE ttDocField.
ASSIGN ttDocField.docID    = '1'
    ttDocField.DocFieldID  = GUID(GENERATE-UUID)
    ttDocField.FieldName   = 'text'
    ttDocField.FieldVal    = customer.EmailAddress
    .

/* DEBUG
/*DATASET dsUpdateSolr:WRITE-XML("longchar", icXmlReq, TRUE, 'UTF-8') NO-ERROR.*/
MESSAGE icXmlReq
VIEW-AS ALERT-BOX.
 END DEBUG*/

/* Dump the SOLR XML data */
icDataFile = SESSION:TEMP-DIR + GUID(GENERATE-UUID) + ".xml".
DATASET dsUpdateSolr:WRITE-XML("file",icDataFile,FALSE,'UTF-8') NO-ERROR.
RUN postSolrDataCurl.p (INPUT icDataFile).
