
/*------------------------------------------------------------------------
    File        : dsUpdateSolr.i
    Purpose     :

    Syntax      :

    Description :

    Author(s)   : claus
    Created     :
    Notes       :

    /* Post data to SOLR XML example */
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
                <field name="text">customername</field>
                <field name="parent_id">adrs-nummer=1164</field>
                <field name="orga">?</field>
            </doc>
        </add>
        <commit/>
        </update>
    */
  ----------------------------------------------------------------------*/
DEFINE TEMP-TABLE ttUpdate   NO-UNDO   XML-NODE-NAME 'update':u
    FIELD updateID  AS CHARACTER XML-NODE-TYPE "hidden"
    INDEX pk IS PRIMARY UNIQUE updateID
    .

DEFINE TEMP-TABLE ttAdd   NO-UNDO   XML-NODE-NAME 'add':u
    FIELD updateID  AS CHARACTER XML-NODE-TYPE "hidden"
    FIELD addID     AS CHARACTER XML-NODE-TYPE "hidden"
    INDEX pk IS PRIMARY UNIQUE addID
    .

DEFINE TEMP-TABLE ttDoc   NO-UNDO   XML-NODE-NAME 'doc':u
    FIELD addID     AS CHARACTER XML-NODE-TYPE "hidden"
    FIELD docID     AS CHARACTER XML-NODE-TYPE "hidden"
    INDEX pk IS PRIMARY UNIQUE docID
    .

DEFINE TEMP-TABLE ttDocField   NO-UNDO   XML-NODE-NAME 'field':u
    FIELD docID      AS CHARACTER XML-NODE-TYPE "hidden"
    FIELD DocFieldID AS CHARACTER XML-NODE-TYPE "hidden"
    FIELD FieldName  AS CHARACTER XML-NODE-TYPE 'attribute':u XML-NODE-NAME 'name':u
    FIELD FieldVal   AS CHARACTER XML-NODE-TYPE 'text':u
    INDEX pk IS PRIMARY UNIQUE DocFieldID
    .

DEFINE TEMP-TABLE ttCommit   NO-UNDO   XML-NODE-NAME 'commit':u
    FIELD updateID  AS CHARACTER XML-NODE-TYPE "hidden"
    INDEX pk IS PRIMARY UNIQUE updateID
    .

DEFINE DATASET dsUpdateSolr XML-NODE-NAME "update" XML-NODE-TYPE 'hidden'
    FOR ttUpdate, ttAdd, ttDoc, ttDocField, ttCommit
    DATA-RELATION UpdateSolr FOR ttUpdate, ttAdd RELATION-FIELDS (updateID, updateID) NESTED
    DATA-RELATION AddSolr FOR ttAdd, ttDoc RELATION-FIELDS (addID, addID) NESTED
    DATA-RELATION docSolr FOR ttDoc, ttDocField RELATION-FIELDS (docID, docID) NESTED
    .

/* ************************  Function Prototypes ********************** */


FUNCTION solrDate RETURNS CHARACTER
    (  pdDate AS DATE ) FORWARD.


/* ************************  Function Implementations ***************** */


FUNCTION solrDate RETURNS CHARACTER
    (  pdDate AS DATE ):
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/

    DEFINE VARIABLE icDate AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iiYear AS INTEGER   NO-UNDO.

    iiYear = YEAR(pdDate).
    IF iiYear > 9999 THEN iiYear = 9999.
    icDate = STRING(iiYear, "9999") + "-" + string(MONTH(pdDate), "99") + "-" + string(DAY(pdDate), "99") + "T00:00:00Z".
    RETURN icDate.

END FUNCTION.
