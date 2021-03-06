 
 /*------------------------------------------------------------------------
    File        : FetchResponse
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sun Sep 04 03:21:48 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Message.DataAdminMessage.
using OpenEdge.DataAdmin.Message.IFetchResponse.
/*using OpenEdge.DataAdmin.Message.ITableResponse from propath.*/
/*using OpenEdge.DataAdmin.Message.TableResponse from propath. */
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Message.FetchResponse inherits DataAdminMessage implements IFetchResponse: 
    define variable KeepDataset as logical no-undo.
	constructor public FetchResponse ( pname as character,phds as handle,phMsg as handle,plkeep as logical ):
		super ( pname, phds, phMsg).		
		KeepDataset = plkeep.
	end constructor.	
	
	constructor public FetchResponse ( pname as character,phds as handle,phMsg as handle):
        super ( pname, phds, phMsg).        
    end constructor.
    
       /** Set total (response after fill) */   
    method public void SetTableTotal (pcTable as char, piTotal as int):     
        find ttTableMessage where ttTableMessage.TableName   = pctable no-error.
        if not avail ttTableMessage then 
           undo, throw new IllegalArgumentError("Invalid table name " + quoter(pctable) + " passed to SetTableTotal"). 
        ttTableMessage.Total = pitotal. 
    
    end method.   
    
	destructor public FetchResponse ( ):
        if KeepDataset = false and valid-handle(DataHandle) and DataHandle:dynamic then
        do: 
            delete object DataHandle no-error. 
        end.
            
    end destructor.
	 
end class.