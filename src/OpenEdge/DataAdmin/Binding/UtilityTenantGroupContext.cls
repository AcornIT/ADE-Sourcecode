 /*************************************************************/
USING OpenEdge.DataAdmin.Binding.IDataAdminContext.
USING OpenEdge.DataAdmin.Binding.UtilityContext.
USING OpenEdge.DataAdmin.Error.IllegalArgumentError.
USING OpenEdge.DataAdmin.IDataAdminCollection.
USING OpenEdge.DataAdmin.IDataAdminElement.
USING OpenEdge.DataAdmin.IRequestInfo.
USING OpenEdge.DataAdmin.ITenantGroup.
USING OpenEdge.DataAdmin.Internal.Util.UtilityTenantGroupSet.
USING Progress.Lang.*.
 /* Copyright (c) 2012 by Progress Software Corporation.      */
 /*                                                           */
 /* All rights reserved.  No part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from Progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : UtilityTenantGroupContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed May 09 22:32:23 EDT 2012
    Notes       : 
  ----------------------------------------------------------------------*/

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.UtilityTenantGroupContext inherits UtilityContext: 
	{daschema/groupdata.i reference-only}
	
	define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bgrp for ttGroupData.
            if Count = ? then
            do:
                Count = 0.
                for each bgrp:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
        
	constructor public UtilityTenantGroupContext ( ds as handle):
		super ( ds, "TenantGroup").
	end constructor.
    
    method protected override void Bind(pHdl as handle).
        Bind(table-handle phdl bind).
    end method.    
    
    method private void Bind(table ttGroupData bind):
    end method.
    
    method public override void AssignRow(pinst as IDataAdminElement,phBuffer as handle):
        define variable inst as ITenantGroup no-undo. 
        inst = cast(pinst,ITenantGroup).
        AssignRow(inst,phBuffer). 
    end method.
    
    method public void AssignRow(inst as ITenantGroup,hBuffer as handle):
        hBuffer::name = inst:name. 
    end method.
  
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new UtilityTenantGroupSet(cntxt).
    end method.
    
     method protected override IDataAdminElement CreateEntity(pReq as IRequestInfo):
        if valid-object(TargetService) then
        do:
            if this-object:Find(this-object:TableHandle::name) then 
                return TargetService:GetTenantGroup(this-object:TableHandle::name).
        end.   
    end method.
    
    method public override logical Find(pid as integer):
        define variable tnt as ITenantGroup no-undo.
        if valid-object(TargetService) then
        do:
            tnt = TargetService:GetTenantGroup(pid).
            if valid-object(tnt) then 
                return this-object:Find(tnt:name).
        end.
        return false.
    end.    
	
	method public override logical CanFind(pid as integer):
        define variable tnt as ITenantGroup no-undo.
        if valid-object(TargetService) then
        do:
            tnt = TargetService:GetTenantGroup(pid).
            if valid-object(tnt) then 
                return this-object:CanFind(tnt:name).
        end.
        return false.
    end.    

end class.