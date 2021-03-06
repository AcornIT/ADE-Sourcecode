/*************************************************************/
/* Copyright (c) 2015,2019 by progress Software Corporation. */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
   File        : AuthenticationSystemDataSource
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : hdaniels
   Created     : feb 2011
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataSource.DataSource from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath. 
using OpenEdge.DataAdmin.DataAccess.DataMapper from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.AuthenticationSystemDataSource inherits DataSource: 
    define buffer b_authenticationsystem for dictdb._Sec-Authentication-System.
    define protected variable mBuffer   as handle    no-undo.
    define           variable cErrorMap as character no-undo.
    define private   variable msave     as logical   no-undo.
    define           variable mptr      as MEMPTR    no-undo.
    define           variable iLength   as integer   no-undo.
    define private   variable mMapping  as char
        init     
        "Name,_Domain-type,~
Description,_Domain-type-description,~
IsEnabled,_PAM-plug-in,~
Callback,_PAM-callback-procedure,~
Comments,_Custom-detail"     
        no-undo.
    /* Names decided in discussions for the 11.1 changes   
    ModuleName,_PAM-module-name,~     
    ModuleChecksum,_PAM-library-checksum"     
    */    
    constructor public AuthenticationSystemDataSource (pcurl as char):        
        this-object ( ).   
        url = pcURL. 
    end constructor.
    
    constructor public AuthenticationSystemDataSource ( ):        
        super ("_sec-authentication-system","dictdb._sec-authentication-system", mMapping). 
        BaseQueryTemplate = "for each _sec-authentication-system&1no-lock".
    end constructor.
    
    method protected override void PrepareBuffer(phBuffer as handle):    
        phBuffer:set-callback("After-Row-fill","AfterRow").       
        mBuffer = phBuffer.
    end method.
    
    method public override logical Save(phBuffer as handle):
        define variable hBeforeBuff as handle     no-undo.     
        define variable hquery      as handle     no-undo.
        define variable hDataset    as handle     no-undo.
        define variable mapper      as DataMapper no-undo.
        define variable cMsg        as character  no-undo.        
       
        create query hquery.
        hBeforeBuff = phBuffer:before-buffer.       
        hquery:add-buffer(hBeforeBuff).
        hQuery:query-prepare("for each ttAuthenticationSystemCopy").    
        hquery:query-open().
        
        do while true:
            
            hquery:get-next.
            if not hBeforebuff:avail then 
                leave.
         
            if hBeforeBuff:row-state = row-deleted then 
            do:
                find b_authenticationsystem where b_authenticationsystem._domain-type = hBeforeBuff::Name exclusive no-wait.
                delete  b_authenticationsystem.
            end.
            else 
            do:
                phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
             
                if hBeforeBuff:row-state = row-created then 
                do:
                    create dictdb._sec-authentication-system.
                    assign 
                        dictdb._sec-authentication-system._Domain-type = phBuffer::Name.
                      
                    /* PAM plug in is currrenty not exposed in any tools or APIs, but 
                       shopuld default to NO for now (as in DataAdmin tool ) */
                    /* 11.1- adding new isEnabled flag and callback procedure  */     
                    if phBuffer::Callback NE ? or phBuffer::Callback NE "" then 
                    do:
                        assign  
                            dictdb._sec-authentication-system._PAM-plug-in            = phBuffer::IsEnabled
                            dictdb._sec-authentication-system._PAM-callback-procedure = phBuffer::Callback.
                    end.
                    else if phBuffer::Callback EQ ? or phBuffer::Callback EQ "" then
                            assign  dictdb._sec-authentication-system._PAM-plug-in            = false
                                dictdb._sec-authentication-system._PAM-callback-procedure = phBuffer::Callback.                               
                        else 
                            undo, throw new UnsupportedOperationError("Cannot have blank or unknown callback procedure if authentication enabled.").        
                end. 
                else 
                do:
                    find dictdb._sec-authentication-system
                        where dictdb._sec-authentication-system._Domain-type = phbuffer::Name exclusive no-wait.
                end.    
            
                if dictdb._sec-authentication-system._Domain-type begins "_" then 
                do: /* in-built types */
                
                    if phBuffer::Callback NE dictdb._sec-authentication-system._PAM-callback-procedure then 
                    do:                        
                        if phBuffer::Callback eq ? or phBuffer::Callback eq "" then
                        do: 
                            assign 
                                dictdb._sec-authentication-system._PAM-library-checksum   = ?
                                dictdb._sec-authentication-system._PAM-callback-procedure = phBuffer::Callback.
                        end.   
                        else 
                        do: 
                            assign 
                                dictdb._sec-authentication-system._PAM-callback-procedure = phBuffer::Callback.
                            if phBuffer::ModuleChecksum then
                            do:             
                                calculateMD5(phBuffer).                             
                                assign 
                                    dictdb._sec-authentication-system._PAM-library-checksum = GET-BYTES(mptr,1, iLength).
                                SET-SIZE(mptr) = 0.
                            end.
                        end.                                                  
                    end. 
                    else 
                    do:
                        /* there is a chance of having same callback procedure but it might be re-coomplied. when callback procedure is recompiled, 
                        the rcode information will change. the new rcode will have a new value. */   
                        if phBuffer::ModuleChecksum then
                        do:
                            calculateMD5(phBuffer).
                            assign 
                                dictdb._sec-authentication-system._PAM-library-checksum = GET-BYTES(mptr,1, iLength).
                            SET-SIZE(mptr) = 0.
                        end.
                        else dictdb._sec-authentication-system._PAM-library-checksum = ?.
                    end.              
                end.
                else 
                do:                    
                    assign 
                        dictdb._sec-authentication-system._Domain-type-description = phBuffer::Description
                        dictdb._sec-authentication-system._Custom-detail           = phBuffer::Comments. 
                    if phBuffer::Callback NE ? or phBuffer::Callback NE "" then 
                    do:                        
                        if phBuffer::ModuleChecksum then
                        do:
                            calculateMD5(phBuffer).
                            assign 
                                dictdb._sec-authentication-system._PAM-library-checksum = GET-BYTES(mptr,1, iLength).
                            SET-SIZE(mptr) = 0.
                        end.
                        else dictdb._sec-authentication-system._PAM-library-checksum = ?.
                        assign  
                            dictdb._sec-authentication-system._PAM-plug-in            = phBuffer::IsEnabled
                            dictdb._sec-authentication-system._PAM-callback-procedure = phBuffer::Callback.
                    end.
                    else if phBuffer::Callback EQ ? or phBuffer::Callback EQ "" then
                            assign  dictdb._sec-authentication-system._PAM-plug-in            = phBuffer::IsEnabled
                                dictdb._sec-authentication-system._PAM-callback-procedure = phBuffer::Callback
                                dictdb._sec-authentication-system._PAM-library-checksum   = ?.
                        else
                            undo, throw new UnsupportedOperationError("Cannot have blank or unknown callback procedure if authentication enabled.").        
                end.  
                 
                hdataset = phBuffer:dataset.
                msave = true.
                AfterRow (dataset-handle hdataset  by-reference).
                msave = false.
        
            end. /* end of else row-deleted */ 
        end.
 
        return true.   
        catch e as Progress.Lang.Error :
            mapper = new DataMapper("Authentication System,_sec-authentication-system,Domain,_sec-authentication-domain",mmapping).
            /* replace domain type with name */   
            if e:GetMessageNum(1) = 132 then
            do:
                cMsg = replace(e:GetMessage(1),"Domain type","name").
                undo, throw new DataAccessError(mapper,cMsg,e:GetMessageNum(1),e).
            end.
            else           
                undo, throw new DataAccessError( mapper ,  e). 
        end catch.   
                    
    end method.    
    
    method public override void AfterRow(dataset-handle hds):
        define variable hbuffer    as handle    no-undo.        
        define variable typeurl    as character no-undo.
        define variable iSource    as integer   no-undo.         
        assign
            hBuffer      = hds:get-buffer-handle("ttAuthenticationSystem")
            hBuffer::Url = Url + "/authenticationsystems/" + WebUtil:UrlEncode(hBuffer::Name). 
            
        isource = lookup("_sec-authentication-system",Tables). 
        if valid-handle(DataSourceHandle) then 
        do:            
            if get-string(DataSourceHandle:get-source-buffer(isource)::_PAM-library-checksum,1) eq "" or 
                get-string(DataSourceHandle:get-source-buffer(isource)::_PAM-library-checksum,1) eq ? then
                hBuffer::ModuleChecksum = false.
            else hBuffer::ModuleChecksum = true.
        end.
        if not msave then   
        do:
            isource = lookup("_sec-authentication-system",Tables).
            hBuffer::IsBuiltin  = DataSourceHandle:get-source-buffer(isource)::_Domain-type begins "_".
             
        end.
    end method.   
    
    method public void calculateMD5(hBuffer as handle):       
       
        define variable cFileName  as character no-undo.
        define variable md5Value   as character no-undo.        
       
        cFileName = hBuffer::Callback.
        RCODE-INFO:FILE-NAME = REPLACE(cFileName, ".p", ".r").
        IF RCODE-INFO:CRC-VALUE = ? THEN 
        DO:                                
            undo, throw new UnsupportedOperationError("ERROR - did not find info for rcode in callback procedure").
        END.
        
        md5Value = RCODE-INFO:SIGNATURE-VALUE.
        IF md5Value = ? THEN 
        DO:                                
            undo, throw new UnsupportedOperationError("ERROR - callback procedure's rcode does not have signature value").
        END.
        
        iLength = LENGTH(md5Value).
        SET-SIZE(mptr) = iLength + 1.
        PUT-STRING(mptr,1) = md5Value.        
    end method.                 
    
end class.
