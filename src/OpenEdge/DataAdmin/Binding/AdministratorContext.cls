 /*************************************************************/
  /* Copyright (c) 2011,2013 by progress Software Corporation. */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : AdministratorContext
    Purpose     : keep track of administrator(s).  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : Currently holds the single record used to transport
                  datadmin through service to database.
                  Could in theory hold user records that matches.
  ----------------------------------------------------------------------*/
block-level on error undo, throw.  
using OpenEdge.DataAdmin.Administrator.
using OpenEdge.DataAdmin.Binding.DataAdminContext.
using OpenEdge.DataAdmin.Binding.Factory.IContextScope.
using OpenEdge.DataAdmin.Binding.IDataAdminContext.
using OpenEdge.DataAdmin.Binding.IDataAdminModel.
using OpenEdge.DataAdmin.Binding.ServiceAdapter.
using OpenEdge.DataAdmin.DataAdminService.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError.
using OpenEdge.DataAdmin.IDataAdminCollection.
using OpenEdge.DataAdmin.IDataAdminElement.
using OpenEdge.DataAdmin.IRequestInfo.
using Progress.Lang.*.  
  
class OpenEdge.DataAdmin.Binding.AdministratorContext inherits DataAdminContext: 
    {daschema/administrator.i}
    
    define dataset dsAdmin for ttAdministrator.
    
     /*   temporary until converted to use createDataset  */
    method override protected handle InitDataset ():
        return dataset dsAdmin:handle.
    end method.
     
    define public override property TableHandle as handle no-undo 
        get():
           return temp-table ttAdministrator:handle.
        end.
        private set.
        
    define public override property KeyFields as character  no-undo  
        get():
            return TableHandle:default-buffer-handle:keys. 
        end.   
        
    define public override property Count as integer init ? no-undo  
        get():         
            return 1.
        end.
        protected set.      
		
 	constructor public AdministratorContext (pscope as IContextScope):
        super ("Administrator",pScope).    
    end constructor.
    
	
	method public override character GetJoinFields(parentid as char):
        return "".
    end.
    
    method public override void CopyTable(cntxt as IDataAdminModel).
        undo, throw new UnsupportedOperationError("Copy Administrator context. There is only one keyless instance").
    end method. 
     
    method public override void CreateRow(entity as IDataAdminElement):
        undo, throw new UnsupportedOperationError("Create Administrator context row. There is only one row").
    end method. 
    
    method public override logical CanFind(name as character):
        return can-find(ttAdministrator where ttAdministrator.name = name).
    end.    
     
    method public override logical Find(name as character):
        find ttAdministrator where ttAdministrator.name = name no-error.
        return avail ttAdministrator.
    end.    
    
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        undo, throw new UnsupportedOperationError("CreateCollection in Dummy context. There is only one keyless instance").
    end method.
    
    method protected override IDataAdminElement CreateEntity(pReq as IRequestInfo):
        return new Administrator(this-object,pReq).
    end method.  
		
end class.