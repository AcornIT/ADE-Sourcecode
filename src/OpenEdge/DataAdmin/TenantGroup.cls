/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : TenantGroup
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Jun 12 21:20:19 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using OpenEdge.DataAdmin.AbstractPartitionOwner.
using OpenEdge.DataAdmin.Binding.IContextTree.
using OpenEdge.DataAdmin.Binding.IDataAdminModel.
using OpenEdge.DataAdmin.Binding.PartitionContext.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext.
using OpenEdge.DataAdmin.Binding.Query.IPartitionQuery.
using OpenEdge.DataAdmin.Binding.TenantGroupContext.
using OpenEdge.DataAdmin.Core.CodeWriter.
using OpenEdge.DataAdmin.Core.JSONLoader.
using OpenEdge.DataAdmin.Core.JSONWriter.
using OpenEdge.DataAdmin.DataAdminService.
using OpenEdge.DataAdmin.Error.CreateOnlyPropertyError.
using OpenEdge.DataAdmin.Error.IllegalArgumentError.
using OpenEdge.DataAdmin.Error.IllegalOperationError.
using OpenEdge.DataAdmin.Error.InvalidPropertyValueError.
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError.
using OpenEdge.DataAdmin.Error.UnknownValueError.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError.
using OpenEdge.DataAdmin.IArea.
using OpenEdge.DataAdmin.IDataAdminCollection.
using OpenEdge.DataAdmin.IDataAdminElement.
using OpenEdge.DataAdmin.IDataAdminExporter.
using OpenEdge.DataAdmin.IDataAdminSerializable.
using OpenEdge.DataAdmin.IPartitionMap.
using OpenEdge.DataAdmin.IRequestInfo.
using OpenEdge.DataAdmin.ITable.
using OpenEdge.DataAdmin.ITenantGroup.
using OpenEdge.DataAdmin.ITenantGroupMemberSet.
using OpenEdge.DataAdmin.ITenantSet.
using OpenEdge.DataAdmin.TenantGroup.
using Progress.Lang.Error.
using Progress.Lang.Object.

class OpenEdge.DataAdmin.TenantGroup inherits AbstractPartitionOwner implements ITenantGroup:
     
    define private variable mPartitionTable as handle no-undo. 
    define private variable mTenantGroupMembersTable as handle no-undo. 
       
    define private variable mChild as logical no-undo.    
         
    define public property Table as ITable no-undo                 
        get():
            if valid-object(this-object:Table) = false 
            and valid-handle(mBuffer) 
            and valid-object(Service) then
            do:
                if mBuffer::TableName > "" then
                    return Service:GetTable(mBuffer::TableName).
                else
                    return Service:GetTable(mBuffer::ObjectNumber).
            end.
            return this-object:Table. 
        end.
        
        set(pTable as ITable):
            if not valid-object(pTable) then 
                undo, throw new UnknownValueError("TenantGroup:Table").
            
            if valid-object(Service) then
                undo, throw new CreateOnlyPropertyError("TenantGroup",Name,"Table").
                
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::TableName = pTable:Name.
            end.
            this-object:Table = pTable.
        end. 
 
      define public property Tenants as ITenantSet no-undo                 
          get():
              if not valid-object(Tenants) then
              do:
                  Tenants = cast(GetChildCollection("tenants"),ITenantSet).    
              end.
              return Tenants.
          end.
          private set.
      
      define public property TenantGroupMembers as ITenantGroupMemberSet no-undo                 
        get():
            if not valid-object(TenantGroupMembers) then
            do:
                TenantGroupMembers = cast(GetChildCollection("tenantGroupMembers"),ITenantGroupMemberSet).
/*                TenantGroupMembers:Tenant = this-object.*/
            end.
            return TenantGroupMembers.
        end.
        private set .
       
    define public override property DefaultAllocation as char no-undo                 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::DefaultAllocation.
            else
                return DefaultAllocation. 
        end.
        set(pDefaultAllocation as char):
            if lookup(pDefaultAllocation,ValidDefaultAllocationList) = 0 then 
                undo, throw new InvalidPropertyValueError("TenantGroup",Name,"DefaultAllocation",pDefaultAllocation,ValidDefaultAllocationList).   
            
            if valid-handle(mBuffer) then
            do:
                Context:SetProperty(mBuffer:rowid,"DefaultAllocation",pDefaultAllocation).
            end.
            DefaultAllocation = pDefaultAllocation.
        end.    
    
      define public override property IsDataEnabled as logical no-undo  
          init true get.     
          
/*        get():*/
/*            if valid-handle(mBuffer) then     */
/*                return mBuffer::IsDataEnabled.*/
/*            else                              */
/*                return IsDataEnabled.         */
/*        end.                                                   */
        set(pIsDataEnabled as logical):
             /* @todo explain why. Not needed on table group, block tenant instead? ? or fix to work... */
             undo, throw new UnsupportedOperationError("Cannot set IsDataEnabled in TenantGroup.").
/*            if valid-handle(mBuffer) then                      */
/*            do:                                                */
/*                mDefaultBuffer:find-by-rowid(mBuffer:rowid).   */
/*                mdefaultbuffer::IsDataEnabled = pIsDataEnabled.*/
/*            end.                                               */
/*            else                                               */
/*                IsDataEnabled = pIsDataEnabled.                */
        end.
              
 
    define public override property DefaultDataArea as IArea no-undo   
        get():
            if not valid-object(DefaultDataArea) then
            do: 
                /* do NOT assign since the setter changes data and will set row-modified
                      (the area is cached in the service) */
                if valid-handle(mBuffer) and valid-object(Service) then do:
                    if mBuffer::DefaultDataAreaNumber <> 0 then 
                        return Service:GetArea(mBuffer::DefaultDataAreaNumber).
                    else if mBuffer::DefaultDataAreaName > "" then
                        return Service:GetArea(mBuffer::DefaultDataAreaName).
                end.                    
            end.
            return DefaultDataArea.
        end.
        set(pDefaultDataArea as IArea):
            if not valid-object(pDefaultDataArea) then 
            do:
                undo, throw new UnknownValueError("DefaultDataArea").          
            end.
            if valid-handle(mBuffer) then
                 Context:SetProperty(mBuffer:rowid,"DefaultDataAreaName",pDefaultDataArea:Name).
            DefaultDataArea = pDefaultDataArea.
        end. 
    
    define public override property DefaultIndexArea as IArea no-undo     
        get():
            if not valid-object(DefaultIndexArea) then
            do: 
               /* do NOT assign since the setter changes data and will set row-modified
                  (the area is cached in the service) */
                if valid-handle(mBuffer) and valid-object(Service) then do:
                    if mBuffer::DefaultIndexAreaNumber <> 0 then 
                        return Service:GetArea(mBuffer::DefaultIndexAreaNumber).
                    else if mBuffer::DefaultIndexAreaName > "" then
                        return Service:GetArea(mBuffer::DefaultIndexAreaName).
                end.                    
            end.
            return DefaultIndexArea. 
        end.
        set(pDefaultIndexArea as IArea):
            if not valid-object(pDefaultIndexArea) then 
            do:
                undo, throw new UnknownValueError("DefaultIndexArea").          
            end.   
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::DefaultIndexAreaName = pDefaultIndexArea:Name.
            end.
            DefaultIndexArea = pDefaultIndexArea.
        end. 
        
    define public override property DefaultLobArea   as IArea no-undo    
        get():
            if not valid-object(DefaultLobArea) then
            do: 
               /* do NOT assign since the setter changes data and will set row-modified
                  (the area is cached in the service) */
                if valid-handle(mBuffer) and valid-object(Service) then do:
                    if mBuffer::DefaultLobAreaNumber <> 0 then 
                        return  Service:GetArea(mBuffer::DefaultLobAreaNumber).
                    else if mBuffer::DefaultDataAreaName > "" then
                        return Service:GetArea(mBuffer::DefaultLobAreaName).
                end.                   
            end.
            return DefaultLobArea. 
        end.
        set(pDefaultLobArea as IArea):
            if not valid-object(pDefaultLobArea) then 
            do:
               undo, throw new UnknownValueError("DefaultLobArea").          
            end.         
            if valid-handle(mBuffer) then
                Context:SetProperty(mBuffer:rowid,"DefaultLobAreaName",pDefaultLobArea:Name).
            DefaultLobArea = pDefaultLobArea.
        end. 
        
        
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
        
    constructor public TenantGroup (cntxt as IDataAdminModel):
        super (cntxt).
    end constructor.
    
    constructor public TenantGroup (cntxt as IDataAdminModel,preq as IRequestInfo):
        super (cntxt,preq).
    end constructor.
      
    constructor public TenantGroup (cname as character):
        super (cname).             
    end constructor. 
    
    constructor public TenantGroup (cname as character, service as DataAdminService):
        this-object(cname).
    end constructor. 
    
    /* local context needed - child collections   */ 
    method protected  override IDataAdminModel CreateLocalContext():
        return new TenantGroupContext().
    end method.
     
   /* if lazy datasource none of the arename fields will have data 
      it is sufficient to check one of them  */ 
    method protected override logical NeedsRefresh():
        return valid-handle(mBuffer) and mBuffer::DefaultDataAreaName = "".
    end method.    
  
    method public override logical Allocate():
        IsAllocated = true.
        return Partitions:Allocate(). 
    end method.        
        
/*    method override logical Equals(obj as Object):   */
/*        define variable tnt as TenantGroup no-undo.  */
/*        if super:Equals(obj) then                    */
/*            return true.                             */
/*        else do:                                     */
/*            tnt = cast(obj,TenantGroup).             */
/*            if  this-object:ContextId = tnt:ContextId*/
/*            and this-object:Name = tnt:Name then     */
/*                return true.                         */
/*        end.                                         */
/*        return false.                                */
/*        catch e as Error :                           */
/*            return false.                            */
/*        end catch.                                   */
/*    end method.                                      */
    
    method public override void Export():
        Export("tenantGroup.json").
    end method.          
    
    method protected character GetCreateError():
        return "TenantGroup" + Name + " was not " 
               + (if valid-object(Service) 
                  then "created in service " + quoter(Service:Name) 
                  else "added to TenantGroupSet")
               + ".". 
    end method.
    
    method public override void WriteTree(tree as IContextTree):
        WriteTree(tree,"tenantGroupMembers,partitions").        
    end method.
    
    /* write specified collections (default all)
       See override in ExportTree(file,collection) that deals with tenants versus TenantGroupMembers for .p */
    method public override void WriteTree(tree as IContextTree,pcCollections as char):
        define variable i as integer no-undo.
        define variable cColl as character no-undo.
        
        tree:SetHandle(SerializeName,mBuffer,mBuffer:rowid).   
        
        do i = 1 to num-entries(pccollections):
           ccoll = entry(i,pccollections).
           case ccoll:
               when "partitions" then 
               do:
                   tree:SetJoin(SerializeName,"partitions","Name,TenantGroupName").
                   if valid-object(Partitions) then 
                        Partitions:WriteTree(tree,"").
               end.  
               when "tenantGroupMembers"  then 
               do:
                   tree:SetJoin(SerializeName,"tenantGroupMembers","Name,TenantGroupName").
                   if valid-object(TenantGroupMembers) then 
                        TenantGroupMembers:WriteTree(tree,"").
               end.
               when "tenants" then 
               do:
                   undo, throw new UnsupportedOperationError("Export or import of Tenants collection. Use TenantGroupMembers instead.").
/*                                                                                */
/*                   tree:SetJoin(SerializeName,"tenants","Name,TenantGroupName").*/
/*                   Tenants:WriteTree(tree,"").                                  */
               end.
               otherwise 
                   undo, throw new IllegalArgumentError("WriteTree collection " + quoter(ccoll)). 
 
           end.    
        end.
       
    end method.
    
    
   /*
      /* write specified collections (default all) */
    method public override void  WriteTree(tree as IContextTree,pcCollections as char):
        define variable i as integer no-undo.
        define variable cntxt as TenantGroupContext no-undo.
        define variable cColl as character no-undo.
        define variable hCopy as handle no-undo. 
        if not valid-object(Context) then
        do:
            cntxt = new TenantGroupContext().
            Attach(cntxt).
        end.
        
        tree:SetHandle(SerializeName,mDefaultBuffer,mDefaultBuffer:rowid).   
        
        do i = 1 to num-entries(pccollections):
           ccoll = entry(i,pccollections).
           case ccoll:
               when "partitions" then 
               do:
                   tree:SetJoin(SerializeName,"partitions","Name,TenantGroupName").
                   if valid-handle(mPartitionTable) then
                   do:
                       tree:SetHandle("partitions",mPartitionTable:default-buffer-handle).
                   end.
                   else do:                      
                       Partitions:WriteTree(tree,"").
                   end.
               end.  
               when "tenantgroupmembers" then 
               do:
                    tree:SetJoin(SerializeName,"tenantGroupMembers","Name,TenantGroupName"). 
                    if valid-handle(mTenantGroupMembersTable) then
                    do:
                        tree:SetHandle("tenantGroupMembers",mTenantGroupMembersTable:default-buffer-handle).
                    end.
                    else do:    
                        TenantGroupMembers:WriteTree(tree).                        
                    end.
               end.    
           end.    
        end.
        
    end method.
     */
    
    /** override to get codewriter if .p and to handle collections for this */
    method public override void ExportTree(pcfile as char,pcCollectionlist as char):
        define variable writer as IDataAdminExporter no-undo.
        define variable iPos as integer no-undo.
        define variable cExt as character no-undo.
        /* The code writer support this, but it writes tenants, so externally 
            we give error if actually asking for it (see below) */ 
        iPos = lookup("TenantGroupMembers",pcCollectionList).
        if iPos > 0 then
        do:
            cExt = GetFileExtension(pcfile).
            if cExt = "p" or cExt = CodeExtension  then
                undo, throw new UnsupportedOperationError("Cannot generate code for TenantGroupMembers. Use Tenants instead.").
        end.
        
        /* This will give error in writeTree, but code writer actually exports 
           code for Tenants when passing "TenantGroupMembers", so we just change it here */
        iPos = lookup("Tenants",pcCollectionList).
        if iPos > 0 then
        do:
            cExt = GetFileExtension(pcfile).
            if cExt = "p" or cExt = CodeExtension  then
                entry(iPos,pcCollectionList) = "TenantGroupMembers".
        end.
        
        super:ExportTree(pcfile,pcCollectionlist).
    end method.     
    
    
    
    method protected override void AssertPartitions():
        if Created and not valid-object(this-object:Table) then
            undo, throw new IllegalOperationError("Partitions are not available in a new TenantGroup that has no Table assigned.").  
     
    end method.         
   
end class.
