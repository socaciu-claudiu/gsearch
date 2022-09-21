
/*------------------------------------------------------------------------
    File        : Change_Costomer.p
    Purpose     :

    Syntax      :

    Description : test the write trigger of customer to post SOLR data

    Author(s)   : claus
    Created     :
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

FOR EACH customer
    WHERE Customer.CustNum = 1189 EXCLUSIVE-LOCK:
         ASSIGN customer.name = "Chin Lin"
                .
    LEAVE.
END.