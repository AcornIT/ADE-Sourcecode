 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : UserPermissionContext
    Purpose     : Contains table and field permissions 
                  with the schema as the parent
                      
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       :  
   ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.Binding.Factory.IServiceContextFactory from propath.

using OpenEdge.DataAdmin.Error.* from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Binding.Factory.IContextScope from propath.

class OpenEdge.DataAdmin.Binding.UserPermissionContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/userpermission.i}    
 
    define private dataset dsUserPermission serialize-name "root" for ttUserPermission.
           
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttUserPermission:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "Id". 
        end.   
        
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bPerm for ttUserPermission.
            if Count = ? then
            do:
                Count = 0.
                for each bPerm:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
/*                                                */
/*    constructor public UserPermissionContext ():*/
/*        super ("UserPermission").               */
/*    end constructor.                            */
    
                                                
    constructor public UserPermissionContext ( pScope as IServiceContextFactory):
        super ("UserPermission",pScope).
    end constructor.                                                        
    
    method protected override void initChildren(pScope as IContextScope):
         initchildren(cast(pScope,IServiceContextFactory)).
    end method.  
    
    method protected void initChildren(pScope as IServiceContextFactory):
        define variable cntxt as IDataAdminModel no-undo.
        cntxt = pScope:GetUserTablePermissionContext().
        cntxt:Lazy = false.
        AddChild(cntxt).  
    end method.  
        
	method public override character GetJoinFields(parentid as char):
	   
        return "".
      
    end.
    
    method public override void CopyTable(cntxt as IDataAdminModel):
        undo, throw new UnsupportedOperationError("CopyTable DataSecurity row").
	end method.
	
	method public override void CreateRow(entity as IDataAdminElement):
	    undo, throw new UnsupportedOperationError("Create DataSecurity row").
	end method. 
    
    method public override logical CanFind(pid as character):
        return can-find(ttUserPermission where ttUserPermission.id = right-trim(pid,'@')).            
    end.    
    
    method private void validId(id as char, output pdomain as char,output puser as char): 
        if num-entries(id,"@") > 1 then 
            pdomain = entry(2,id,"@").
        puser = entry(1,id,"@").
    end method.
    
    method protected override char FindExpression(usrid as char):
        define variable cDomain as character no-undo.
        define variable cUserid as character no-undo.
        validId(usrid , output cDomain,output cUserid).  
        return  "ttUserPermission.DomainName = " + quoter(cDomain) 
              + " and "
              + "ttUserPermission.Name = " + quoter(cUserid) .
    end method.
     
    method public override logical Find(pid as character):
        find ttUserPermission where ttUserPermission.id = right-trim(pid,'@') no-error.
        return avail ttUserPermission.            
    end.    
    
/*    method public override void MergeChanges(pResponse as ISaveRequest).*/
/*                                                                        */
/*    end method.                                                         */
    
/*    method public override void MergeChanges(pResponse as ISaveRequest).*/
/*                                                                        */
/*        if not valid-object(pResponse) then                             */
/*            undo, throw new UnknownValueError("MergeChange","response").*/
/*                                                                        */
/*        MergeChanges(SaveDataset,pResponse:DataHandle).                 */
/*    end method.                                                         */
    
    
    method public void showtables():
        define variable cc as character no-undo.
/*        for each ttTable:                                                     */
/*            cc = cc + ttTable.name + chr(10).                                 */
/*                                                                              */
/*        end.                                                                  */
/*        for each ttField:                                                     */
/*            cc = cc + ttField.Tablename + "." + ttfield.name + chr(10).       */
/*        end.                                                                  */
/*        for each ttIndex:                                                     */
/*            cc = cc + "i " + ttindex.Tablename + "." + ttindex.name + chr(10).*/
/*        end.                                                                  */
/*        for each ttSequence:                                                  */
/*            cc = cc + ttSequence.name + chr(10).                              */
/*                                                                              */
/*        end.                                                                  */
        

/*        if not session:batch-mode then   */
/*        do:                              */
/*            message cc view-as alert-box.*/
/*        end.                             */
    end method. 

    /* Override to deal with the fact that id is split into name and domain on client  */ 
    method public override IDataAdminElement GetEntity(pKey as char).
        define variable msg      as IFetchRequest no-undo.
        define variable h        as handle no-undo.
        define variable hDs      as handle no-undo.
        define variable lok      as logical no-undo.
        define variable cField   as character no-undo.
        define variable cFindExp as character no-undo.
        if not this-object:Find(pKey) then
        do:
            cField = KeyFields.
            hDs = getRequestDataset().
            if hDs:num-buffers = 1 and IsDatasetLoaded and DatasetHandle = hDs then do:
                FetchRow(hDs, cField ,pkey, Lazy).
            end.
            else do:
                msg = GetRequest(). 
                msg:SetTableKeyValue(Tablehandle:name, cField ,pKey).
                msg:SetTableLazy(Tablehandle:name,Lazy).
                FetchData(msg). 
            end.
        end.  
        
        return FindEntity(pKey).       
    end method.
      
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new UserPermissionSet(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(pReq as IRequestInfo):
        return new UserPermission(this-object,pReq).
    end method. 
 
       
end class.
