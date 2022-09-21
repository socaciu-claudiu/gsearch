/*------------------------------------------------------------------------
    File        : initialIndexCustomerEntity.p
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


FOR EACH customer NO-LOCK:
    RUN indexcustomerentity.p (INPUT customer.custnum).
END.

MESSAGE 'done'
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
