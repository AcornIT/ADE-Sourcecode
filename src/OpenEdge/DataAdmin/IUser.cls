/*************************************************************/
/* Copyright (c) 2011,2015,2024 by Progress Software Corporation  */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : IUser
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : 
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDomain from propath.
using OpenEdge.DataAdmin.ITenant from propath.

interface OpenEdge.DataAdmin.IUser inherits IDataAdminElement:  
     /** The unique identifier  (name@domainname) */
     define public property Id            as character no-undo get.  
     
     /** The unique name of the user within the parent Domain. 
         Makes up the first part of the unique identifier.  (name@domainname) */
     define public property Name          as character no-undo get. set. 
     
     /** The Domain of the user.   
         The Domain:Name makes up the second part of the unique identifier.  (name@domainname) */
     define public property Domain        as IDomain   no-undo get. set.
     
     /** The Tenant of the user (as defined by the Domain) */
     define public property Tenant        as ITenant   no-undo get.   
       
     /** An optional description of the user. */
     define public property Description   as character no-undo get. set.    
     
     /** An optional User number of the user) */
     define public property Number        as integer no-undo get. set.
     
     /** Set to true if the user is an SQL only user. (ignored by ABL runtime)*/
     define public property IsSqlOnly     as logical no-undo get. set.   
     
     /** The given name of the user. (optional) */
     define public property GivenName     as character no-undo get. set.   
    
     /** The middle intial of the user. (optional) */
     define public property MiddleInitial as character no-undo get. set.  
    
     /** The surname (familyname, lastname) of the user. (optional) */
     define public property SurName       as character no-undo get. set.  
     
     /** The password. Can only be edited by the actual user.  
         The default behavior is to ENCODE the password on server. 
         Setting the IDataAdminService PasswordPolicy:PreEncodeUserPassword to true 
         will tell the server side to avoid the ENCODE  
     */
     define public property Password      as character no-undo get. set.
     
     /** A telephone number for the user (optional) */
     define public property Telephone     as character no-undo get. set.

     /** An email address for the user (optional) */
     define public property Email         as character no-undo get. set. 

     /** Determine user is Security Admin. To be a Security Administrator, user must have:
        Write  permission on _File._Can-read
        Write  permission on _File._Can-write
        Write  permission on _File._Can-create
        Write  permission on _File._Can-delete
        Write  permission on _Field._Can-read
        Write  permission on _Field._Can-write
        Create permission on _User
        Delete permission on _User */
     define public property IsSecAdmin    as logical no-undo get.	 
         
end interface.
