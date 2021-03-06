/*************************************************************/
/* Copyright (c) 2010-2016 by progress Software Corporation  */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
 /*------------------------------------------------------------------------
    File        : TableContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :   2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

/*using OpenEdge.DataAdmin.Binding.IContextWriter from propath.*/
using OpenEdge.DataAdmin.Binding.ContextTree.
using OpenEdge.DataAdmin.Binding.DataAdminContext.
using OpenEdge.DataAdmin.Binding.Factory.ISchemaScope.
using OpenEdge.DataAdmin.Binding.FieldContext.
using OpenEdge.DataAdmin.Binding.IContextTree.
using OpenEdge.DataAdmin.Binding.IDataAdminContext.
using OpenEdge.DataAdmin.Binding.IDataAdminModel.
using OpenEdge.DataAdmin.Binding.IndexContext.
using OpenEdge.DataAdmin.Binding.PartitionContext.
using OpenEdge.DataAdmin.Binding.ServiceAdapter.
using OpenEdge.DataAdmin.DataAdminService.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError.
using OpenEdge.DataAdmin.IDataAdminCollection.
using OpenEdge.DataAdmin.IDataAdminElement.
using OpenEdge.DataAdmin.IRequestInfo.
using OpenEdge.DataAdmin.Message.FetchRequest.
using OpenEdge.DataAdmin.Message.IFetchRequest.
using OpenEdge.DataAdmin.Message.IFetchResponse.
using OpenEdge.DataAdmin.Message.ISaveRequest.
using OpenEdge.DataAdmin.Message.SaveRequest.
using OpenEdge.DataAdmin.TableImpl.
using OpenEdge.DataAdmin.TableSet.
using Progress.Lang.*.
using OpenEdge.DataAdmin.Binding.Factory.IContextScope from propath.

class OpenEdge.DataAdmin.Binding.TableContext inherits DataAdminContext : 
    
    {daschema/table.i}
    
    define private dataset dsTable serialize-name "root" for ttTable.
  
    define buffer btable for ttTable.
    define temp-table copytable reference-only like ttTable .  
    
    define variable mpartitions     as PartitionContext no-undo.
    define variable mpartitionCache as PartitionContext no-undo. 
    define variable mLastSavedTable as handle no-undo.
    
    define temp-table ttTablePartitionRequest no-undo
        field tablename as char
        index partname as  unique tablename .
      
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttTable:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "Name". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bTable for ttTable.
            if Count = ? then
            do:
                Count = 0.
                for each bTable:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public TableContext ():
        super ("Table").
    end constructor.
        
    constructor protected TableContext (pname as char):
        super (pname).
    end constructor.
   
    constructor protected TableContext (pname as char,pScope as ISchemaScope):
      
        super (pname,pScope).
   end constructor.
        
 	constructor public TableContext ( pScope as ISchemaScope): 
        this-object("Table",pScope).                        
    end constructor.    
    
    method protected override void initChildren(pScope as IContextScope):
         initchildren(cast(pScope,ISchemaScope)).
    end method.  
    
    method protected void initChildren(pScope as ISchemaScope):
        mPartitions = pScope:PartitionContext.
        AddChild(pScope:IndexContext).
        if this-object:name eq "AllTable" then 
            AddChild(pScope:AllFieldContext).
        else AddChild(pScope:FieldContext).
    end method.  
    
    method override protected handle InitDataset ():
        return dataset dsTable:handle. 
    end method.
                
    method protected override character GetIntegerKey():
        return "id".
    end.                                       
	
	method public override void CopyTable(cntxt as IDataAdminModel).
        undo, throw new UnsupportedOperationError("Copy Schema").
    end method. 
     
    method public override void CreateRow(entity as IDataAdminElement):
        undo, throw new UnsupportedOperationError("Create Schema row").
    end method. 
	
    method public override character GetJoinFields(parentid as char):
        case parentid:
            when "schemas" then 
                return "Name,SchemaName".
            when "areas" then 
                return "Name,AreaName".
        end.
     end method. 
    
    method public override character GetServerJoinFields(parentid as char):
        case parentid:
            when "areas" then /* AreaNumber is not mapped - handled by PartitionDataSource:ColumnSource*/
                return "Number,AreaNumber".        
        end.
        return super:GetServerJoinFields(parentid).
    end method. 
     
    /* return partitions if requested (not in default tree)*/
    method public override IDataAdminModel GetNamedChild(child as char):
        if child = "partitions" then 
             return mpartitions.  
        return super:GetNamedChild(child).     
    end method.     
    
    method public logical NeedPartitionRefresh():
        return can-find(first ttTablePartitionRequest).        
    end method.     
    
    /* Called from merge with the changes returned from server to keep track of 
       which partitions that will need to be refreshed. */        
    method private logical CreatePartitionRefreshIds (pdsChanged as handle):
        define variable hQuery     as handle no-undo.
        define variable hBuffer    as handle no-undo.
        define variable hBefore    as handle no-undo.
        define variable lok        as logical no-undo.
        define variable lRefresh   as logical no-undo.
        define variable hPartition as handle no-undo.
        
        hbuffer = pdsChanged:get-buffer-handle ("ttTable"). 
        if not valid-handle(hBuffer) then
            return false.
        create query hQuery.
        
        hquery:add-buffer (hbuffer).
        hQuery:query-prepare ("for each ttTable").
        hquery:query-open().
        hquery:get-first.
        do while hbuffer:avail:
            if hbuffer:row-state = row-created then
                lRefresh = true.
            else if hbuffer:row-state = row-modified then
            do:     
                hBefore = hbuffer:before-buffer.
                hbefore:find-by-rowid(hBuffer:before-rowid). 
                if hBuffer::isMultitenant and hBefore::isMultitenant = false then 
                   lRefresh = true.  
            end.            
            if lRefresh then 
            do:
                create ttTablePartitionRequest.
                ttTablePartitionRequest.Tablename = hBuffer::name.
            end.
            hQuery:get-next.
            lok = true.
        end.
    end method.
    
    method public logical HasTableChanges():
        define variable hBuffer as handle no-undo.
        hbuffer =  Tablehandle:default-buffer-handle. 
        return hBuffer:before-buffer:table-handle:has-records. 
    end method.    
    
    method public logical HasPartitionChanges():
        define variable hBuffer as handle no-undo.
        hbuffer = mpartitions:Tablehandle:default-buffer-handle. 
        return hBuffer:before-buffer:table-handle:has-records. 
    end method.     
    
    method private void DeletePartitionsBeforeRequest ():
        define variable hQuery     as handle no-undo.
        define variable hBuffer    as handle no-undo.
        create query hQuery.
        
         /* now workaround the fact that fill cannot replace (even if it should? ) */
        hbuffer = mPartitions:Tablehandle:default-buffer-handle. 
        hquery:set-buffers (buffer  ttTablePartitionRequest:handle).
        hquery:add-buffer (hbuffer).
        hQuery:query-prepare ("for each ttTablePartitionRequest, each ttPartition of ttTablePartitionRequest").
        hquery:query-open().
        hquery:get-first.
        
/*        hBuffer:table-handle:tracking-changes = false.*/
        do while hbuffer:avail:
            hBuffer:buffer-delete ().
            hQuery:get-next.
        end.    
/*        hBuffer:table-handle:tracking-changes = true.*/
        delete object hQuery.
      
    end method.    
    
    method private IFetchRequest CreatePartitionRefreshRequest ():
        define variable tree as IContextTree no-undo.
        define variable msg  as IFetchRequest no-undo.
        tree = new ContextTree().  
        tree:Parse = true.   
        tree:SetHandle("requests",buffer ttTablePartitionRequest:handle).    
        mPartitions:AddTableTo(tree).         
        msg = new FetchRequest("Partition",Id,tree:GetReadHandle(),no).
        return msg. 
    end method.    
    
    method private logical EmptyPartitionRefresh():
        empty temp-table ttTablePartitionRequest.        
    end method.     
    
    method protected override handle CreateSaveDataset():
        define variable tree as IContextTree no-undo.    
        tree = new ContextTree().                        
        tree:Parse = true.                               
        AddTreeTo(tree).   
        /* tables (if ismultitenant is set to true) must be committed separately from partitions 
           the service UpdateTables will use GetPartitionSaveRequest and issue a second request if HasPartitionChanges()
           (issue OE00215975 fix include a change to add partitions unconditionally here. 
            This broke the split transaction req for isMultiTenant save with partitions.
            This condition check keeps both behaviors. Note that it is not known why/whether OE00215975 rwas not picked up 
             by the secind save, but it is conceivable that the second save did not happen with only partitions.  it also seems 
             more correct to not do two saves with no cahnges in the first save) */    
        if HasTableChanges() = false and HasPartitionChanges() then
            mpartitions:AddTableTo(tree). 
        return tree:GetReadHandle().                     
    end method.                                         
    
    
     /* used by UpdateTable(s) to perform a second transaction */
    method public ISaveRequest GetPartitionSaveRequest():
        define variable hchanges as handle no-undo.
        define variable savemsg as ISaveRequest no-undo.
        define variable tree as IContextTree no-undo.
        tree = new ContextTree().  
        tree:Parse = true.        
        mPartitions:AddTableTo(tree).  
        SaveDataset = tree:GetReadHandle(). 
        hchanges = GetChanges(SaveDataset).  
        savemsg = new SaveRequest(Name,Id,hchanges).
/*        mCreate = true.*/
        return savemsg.
    end method.
    
    method public override void ExportLastSavedTree( pcfile as char ):
        define variable hDs as handle no-undo.
        define variable tree as IContextTree no-undo.
        tree = new ContextTree().
        if valid-handle(mLastSavedTable) then  
            tree:SetHandle("tables",mLastSavedTable).
        tree:SetJoin("tables","partitions","Name,TableName").    
        mPartitions:AddTableTo(tree).  
        hDs = tree:GetReadHandle().
        hDs:write-json ("File",pcFile,yes).    
        
    end method.
    
    method override public void MergeChanges( pResponse as ISaveRequest ):
        define variable lok as logical no-undo.
        define variable hbuffer  as handle no-undo.
        define variable msg as IFetchRequest no-undo.
        if not NeedPartitionRefresh() then    
        do: 
            CreatePartitionRefreshIds(pResponse:DataHandle).    
        end.
        
        hbuffer = pResponse:DataHandle:get-buffer-handle ("ttTable"). 
        if valid-handle(hBuffer) then
            mLastSavedTable = hBuffer.
            
        hbuffer = pResponse:DataHandle:get-buffer-handle ("ttPartitions"). 
        if valid-handle(hBuffer) then
            EmptyPartitionRefresh().    
           
        super:MergeChanges(pResponse).
        
        if NeedPartitionRefresh() then 
        do: 
            mPartitionCache = new PartitionContext().
            mPartitionCache:CopyTable(mPartitions).
            DeletePartitionsBeforeRequest().
            msg = CreatePartitionRefreshRequest().
            msg:UseReplaceOnClient = false.
            FetchData(msg).
            mPartitions:CopyTable(mPartitionCache).
        end.    
        
    end method.
    
    /** Allocate new partitions 
        Called from service after save and before partition save if table/tableset ForceAllocation 
        Used by REST api
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None */
    method public void AllocateNewPartitions (pcAllocationState as char):
        for each ttTablePartitionRequest:
            mpartitions:AllocateTableTenants(ttTablePartitionRequest.tablename,pcAllocationState).   
        end.
    end method.    
    /*
    /** Allocate  
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None */
    method public void Allocate (pcAllocationState as char):
        for each ttTable:
            mpartitions:AllocateTable(ttTable.name,pcAllocationState).   
        end.
    end method.    
    */
       
    method public override void AddTreeTo(tree as IContextTree,pcCollections as char,pReq as IRequestInfo ):
        define variable i as integer no-undo.
        define variable childreq   as IRequestInfo no-undo.
        super:AddTreeTo(tree,pcCollections,pReq).
        
        if lookup("partitions",pcCollections) > 0 then
        do:
            tree:SetJoin("tables","partitions","Name,TableName").
            if valid-object(pReq) then 
                childreq = preq:Get("partitions").
            mpartitions:AddTableTo(tree,childreq).
        
        end.
    end method.    
       
    method public override void AddTreeTo(tree as IContextTree,parent as IDataAdminContext,pReq as IRequestInfo).
        if parent:SerializeName = "schemas" then 
        do:
            AddTreeTo(tree,parent,"lobFields,indexes",pReq).
        end.
        else 
            super:AddTreeTo(tree,parent,pReq).
                     
    end method. 
   
	method public override logical CanFind(name as character):
        return can-find(ttTable where ttTable.name = name).            
    end.    
     
    method public override logical Find(name as character):
        find ttTable where ttTable.name = name no-error.
        return avail ttTable.            
    end.  
    
    method public override logical Find(pid as integer):
        find ttTable where ttTable.id = pid no-error.
        return avail ttTable.            
    end.  
    
    /** update policy info if record avail */
    method public logical UpdatePolicyName(name as character,pcPolicyName as char):
        define variable lTrack  as logical no-undo.
        find ttTable where ttTable.name = name no-error.
        if avail ttTable then
        do on error undo,throw:
            lTrack = temp-table ttTable:tracking-changes.
            temp-table ttTable:tracking-changes = false. 
            assign
                ttTable.PartitionPolicyName = pcPolicyName
                ttTable.IsPartitioned = true.
/*            message "updated  ttTable.PartitionPolicyName "  ttTable.PartitionPolicyName*/
/*            view-as alert-box.                                                          */
            FireContextRefreshed().
            finally:
                temp-table ttTable:tracking-changes	= lTrack.	
            end finally.        
        end.
    end. 
    
    /** update policy info if record avail */
    method public logical UpdateCdcPolicyName(name as character,pcPolicyName as char):
        define variable lTrack  as logical no-undo.
        find ttTable where ttTable.name = name no-error.
        if avail ttTable then
        do on error undo,throw:
            lTrack = temp-table ttTable:tracking-changes.
            temp-table ttTable:tracking-changes = false. 
            assign
                ttTable.CdcTablePolicyName = pcPolicyName.
                //ttTable.IsPartitioned = true.
            FireContextRefreshed().
            finally:
                temp-table ttTable:tracking-changes = lTrack.   
            end finally.        
        end.
    end.     
      
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
          return new TableSet(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(pReq as IRequestInfo):
       return new TableImpl(this-object,pReq).
    end method.
    
    method public override character ColumnSource(pcColumn as char):
        define variable cField  as character no-undo.
        define variable cBuffer as character no-undo.
        
        define variable cMsg as character no-undo. 
        
        if num-entries(pcColumn,".") > 1 then
        do:
            cBuffer = entry(1,pcColumn,".").
            cField  = entry(2,pcColumn,".").
            if cBuffer = "Area" and cField = "name" then
            do:
                return "ttTable.AreaName". 
            end. 
            if cBuffer = "Schema" and cField = "name" then
            do:
                return "ttTable.SchemaName". 
            end.          
        end.
        return super:ColumnSource(pcColumn).
    end method.
    
       /** DataRefreshed Override to handle requests for indexfields  */
    method public override void DataRefreshed(pResponse as IFetchResponse):
        define variable i as integer no-undo.
        define variable hBuffer  as handle no-undo.
/*        define variable ldone as logical no-undo.*/
        if /*not mRefresh  and*/ pResponse:Entityname = "Table" then
        do:
            hBuffer = pResponse:DataHandle:get-buffer-handle ("ttArea").
            if valid-handle(hBuffer) then
            do:
/*                mRefresh = true. /* this will fire back here - avoid endless loop,      */
/*                                    but ensure call to super below when it happens */   */
                ContextScope:GetContext("Area"):DataRefreshed(pResponse).
/*                ldone = true.                                                           */
            end.
        end.
/*        if not ldone then*/
/*        do:              */
        super:DataRefreshed(pResponse).       
/*            mRefresh = false.*/
/*        end.*/
     end method.
    
     
end class.
