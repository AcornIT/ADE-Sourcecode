/* *************************************************************************************************************************
Copyright (c) 2019-2020 by Progress Software Corporation and/or one of its subsidiaries or affiliates. All rights reserved.
************************************************************************************************************************** */
/*------------------------------------------------------------------------
    File        : JsonLogWriter
    Purpose     : Writes log messages to a JSON Array
    Description :  
    Author(s)   : pjudge
    Created     : 2019-08-29
    Notes       : * This class uses an array for the messages because that
                    ensures the order   
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using Ccs.Common.Support.ILongcharArrayHolder.
using OpenEdge.Core.Collections.IList.
using OpenEdge.Core.Json.JsonConverter.
using OpenEdge.Logging.Filter.ILoggerFilter.
using OpenEdge.Logging.LogEvent.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.

class OpenEdge.Logging.Writer.JsonLogWriter implements ILoggerFilter:
    /* An array of log messages */ 
    define public property LogData as JsonArray no-undo
        get.
        set.
    
    /* Default constructor */
    constructor public JsonLogWriter():
        assign this-object:LogData = new JsonArray().
    end constructor.
    
    /* Performs implementation-specific filtering for a logger type
        
       @param LogEvent The event to capture. */
    method public void ExecuteFilter(input pEvent as LogEvent ):
        define variable logData as JsonObject no-undo.
        define variable ctx as Progress.Lang.Object no-undo.
        
        // because the LogData property is mutable, don't fail if someone's
        // 'accidentally' deleted it
        if not valid-object(this-object:LogData) then
            return.
        
        assign logData = new JsonObject().
        // append this log event to the array
        this-object:LogData:Add(logData).
        
        // don't write the LoggedBy user; we may want to anonymise that or otherwise
        // mask it.
        logData:Add('loggedAt':u,   pEvent:TimeStamp).
        logData:Add('level':u,      string(pEvent:LogLevel)).
        logData:Add('msg':u,        pEvent:Message:Message).
        
        logData:Add('hasError':u,   valid-object(pEvent:Error)).
        if valid-object(pEvent:Error) then
            logData:Add('error':u, JsonConverter:ToObject(pEvent:Error)).
        
        logData:Add('loggerName':u, pEvent:LoggerName).
        logData:Add('msgStack':u,   new JsonArray(pEvent:CallStack)).
        
        // tokens
        assign ctx = pEvent:Message:GetContext('tokens':u).
        if   valid-object(ctx)
        and type-of(ctx, IList)
        then
            logData:Add('ctx.tokens':u, JsonConverter:ToArray(cast(ctx, IList))).
        
        // args
        assign ctx = pEvent:Message:GetContext('args':u).
        if  valid-object(ctx)
        and type-of(ctx, ILongcharArrayHolder)
        then
            logData:Add('ctx.args':u, JsonConverter:ToArray(cast(ctx, ILongcharArrayHolder))).
    end method.
    
end class.
