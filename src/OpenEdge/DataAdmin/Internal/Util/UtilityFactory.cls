 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : UtilityFactory
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Apr 29  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.*.
/*                                                  */
/*using OpenEdge.DataAdmin.Internal.Util.SequenceValueReader.*/
/*using OpenEdge.DataAdmin.Internal.Util.SequenceValueWriter.*/
/*using OpenEdge.DataAdmin.Internal.Util.TableDataReader.    */
/*using OpenEdge.DataAdmin.Internal.Util.TableDataWriter.    */
using OpenEdge.DataAdmin.Util.IDataAdminUtility.
using OpenEdge.DataAdmin.Error.NotFoundError.

class OpenEdge.DataAdmin.Internal.Util.UtilityFactory: 
     
    method public IDataAdminUtility GetUtility(pcUtil as char):
        define variable util as IDataAdminUtility no-undo.
        define variable cmsg as character no-undo.
        util = dynamic-new "OpenEdge.DataAdmin.Internal.Util." + pcUtil + "" ( ).
        return util.
        catch e as Progress.Lang.Error :
/*            if e:GetMessageNum(1) = 14758 then                                    */
/*                cmsg = " does not have a public constructor with name parameter.".*/
/*            else                                                                  */
/*                cmsg = " not found." .                                            */
        	undo, throw new NotFoundError("Utility " + quoter(pcUtil) + " not found.").	
        end catch.
    end method.     
     
end class.