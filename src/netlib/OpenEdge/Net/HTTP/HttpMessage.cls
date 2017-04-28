/************************************************
Copyright (c)  2014, 2015 by Progress Software Corporation. All rights reserved.
*************************************************/ 
/*------------------------------------------------------------------------
    File        : HttpMessage
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Mon Feb 17 14:34:39 EST 2014
    Notes       : 
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

using OpenEdge.Core.Assert.
using OpenEdge.Core.ISupportInitialize.
using OpenEdge.Net.HTTP.Cookie.
using OpenEdge.Net.HTTP.CookieCollection.
using OpenEdge.Net.HTTP.Filter.Writer.SetHeaderMessageWriterBuilder.
using OpenEdge.Net.HTTP.HttpHeader.
using OpenEdge.Net.HTTP.HttpHeaderBuilder.
using OpenEdge.Net.HTTP.HttpHeaderCollection.
using OpenEdge.Net.HTTP.IHttpMessage.
using OpenEdge.Net.HTTP.IHttpMessageWriter.
using OpenEdge.Net.HTTP.TransferEncodingEnum.
using Progress.Lang.Object.

class OpenEdge.Net.HTTP.HttpMessage 
            implements IHttpMessage, ISupportInitialize
            abstract:
    
    /** Holds headers for this message */
    define protected property Headers as HttpHeaderCollection no-undo get. private set.
    
    /** The cookies only relevant to only this message (request or response) */
    define protected property Cookies as CookieCollection no-undo get. private set.
    
    /** The HTTP version supported. Typically HTTP/1.1  */
    define public property Version as character no-undo
        get.
        set(input pcVersion as character):
            Assert:NotNullOrEmpty(pcVersion, 'Version').
            assign this-object:Version = pcVersion.
        end set.
    
    /** The message's content type (eg text/html). For more detail, see
        http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.7 */
    define public property ContentType as character no-undo
        get():
            /* Content-Type header */
            if HasHeader('Content-Type':u) then
                return GetHeader('Content-Type':u):GetBaseValue().
            else
                return '':u.
        end get.
        set(input pcContentType as character):
            define variable oHeader as HttpHeader no-undo.
            
            Assert:NotNull(pcContentType, 'Content Type').
            
            /* Content-Type */
            if HasHeader('Content-Type':u) then
                assign oHeader = GetHeader('Content-Type':u).
            else
            do:
                assign oHeader = HttpHeaderBuilder:Build('Content-Type':u)
                                    :Header.
                SetHeader(oHeader).
            end.
            
            assign oHeader:Value = pcContentType.
        end set.
        
    /** The message's content type encoding (eg charset='utf-8'). For more detail, see
        http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.7 */
    define public property CharacterEncoding as character no-undo
        get():
            /* Content-Type header */
            if HasHeader('Content-Type':u) then
                return GetHeader('Content-Type':u):GetParameterValue('charset':u).
            else
                return '':u.
        end get.
        set(input pcCharacterEncoding as character):
            define variable oHeader as HttpHeader no-undo.
            
            Assert:NotNull(pcCharacterEncoding, 'Character Encoding').
            
            /* Content-Type */
            if HasHeader('Content-Type':u) then
                assign oHeader = GetHeader('Content-Type':u).
            else
            do:
                assign oHeader = HttpHeaderBuilder:Build('Content-Type':u)
                                    :Header.
                SetHeader(oHeader).
            end.
            
            oHeader:SetParameterValue('charset':u, pcCharacterEncoding).
        end set.
    
    /** Object containing the response body/entity.
        The object can be of any type, which may depend on the content type
        and the body filters it passes through. */
    define public property Entity as Object no-undo get. set.
    
    /**  The length (in bytes/characters) of the payload/entity. */    
    define public property ContentLength as integer no-undo
        get():
            define variable iLength as integer no-undo.
            
            /* Content-Length */
            if HasHeader('Content-Length':u) then
                assign iLength = integer(GetHeader('Content-Length':u):Value).
            else
                assign iLength = 0.
            
            return iLength.
        end get.
        set (input piContentlength as integer):
            Assert:IsZeroOrPositive(piContentlength, 'Content Length').
            
            define variable oHeader as HttpHeader no-undo.
            
            /* Content-Length header */
            if HasHeader('Content-Length':u) then
                assign oHeader = GetHeader('Content-Length':u). 
            else
            do:
                assign oHeader = HttpHeaderBuilder
                                    :Build('Content-Length':u)
                                    :Header.
                SetHeader(oHeader).
            end.
            
            assign oHeader:Value = string(piContentlength).
        end set.
    
    /** The message's Transfer-Encoding. For more detail, see
        http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.6 
        
        This property does not use the same mechanism that the ContentType does,
        since the header name used depends on whether this is a request or response. */ 
    define public property TransferEncoding as character no-undo
        get.
        set(input pcTransferEncoding as character):
            Assert:NotNull(pcTransferEncoding, 'Transfer encoding').
            assign this-object:TransferEncoding = pcTransferEncoding.
        end set.
    
    /**  An MD5 hash of the message's content. */    
    define public property ContentMD5 as raw no-undo get. set.
        
    /** Default constructor. */
    constructor protected HttpMessage():
    end constructor.
    
    destructor HttpMessage():
        Destroy().
    end destructor.
    
    method public void Initialize():
        assign this-object:TransferEncoding = string(TransferEncodingEnum:None)
               this-object:Cookies          = new CookieCollection()
               this-object:Headers          = new HttpHeaderCollection().
    end method.
 
    method public void Destroy():
        ClearHeaders().
        ClearCookies().
        
        assign this-object:Entity  = ?
               this-object:Headers = ?
               this-object:Cookies = ?.
    end method.
    
    /** Adds header info to this message's collection of headers.
        
        @param character The header name
        @param character The complete header value  */
    method public void SetHeader(input poHeader as HttpHeader):
        define variable oWriter as IHttpMessageWriter no-undo.
        Assert:NotNull(poHeader, 'Http Header').
        
        assign oWriter = SetHeaderMessageWriterBuilder:Build(this-object, poHeader).
        
        if valid-object(oWriter) then
        do:
            oWriter:Open().
            oWriter:Write(poHeader).
            oWriter:Close(). 
        end.
        else
            this-object:Headers:Put(poHeader).
    end method.
    
    /** Returns a named header

        @param  character The name of the header to retrieve
        @return HttpHeader The header object. Null if not exists. */
    method public HttpHeader GetHeader(input pcName as character).
        return this-object:Headers:Get(pcName).
    end method.
    
    /** Returns all the headers (Names and values)
        
        @param HttpHeader[] An array of headers
        @return integer The number of headers returned */
    method public integer GetHeaders(output poHeaders as HttpHeader extent):
        return this-object:Headers:GetAll(output poHeaders).
    end method.
        
    /** Indicates whether a header exists for this message or not. 
        
        @param character The name of a header to check
        @return logical True if this message contains the header */
    method public logical HasHeader(input pcName as character):
        Assert:NotNullOrEmpty(pcName, 'Header name').
        
        return this-object:Headers:Has(pcName).
    end method.
    
    /** Removes a header from the collection of message headers.
        No-op if none exists.
        
        This implementation sets the value of the header to ?/unknown,
        passes it down the filter chain, and then removes it from the 
        header collection.
        
        @param character The name of the header to remove */    
    method public void RemoveHeader(input pcName as character):
        this-object:Headers:Remove(pcName).
    end method.
    
    /** COOKIES **/
    /** Removes a cookie from this request 
    
        @param Cookie The cookie to remove. */
    method public void RemoveCookie(input poCookie as Cookie):
        Assert:NotNull(poCookie, 'Cookie').
        
        this-object:Cookies:Remove(poCookie).
    end method.
    
    /** Indicates whether a cookie exists for this message
        
        @param Cookie The cookie to check 
        @return logical True if this message contains the cookie */
    method public logical HasCookie(input poCookie as Cookie):
        Assert:NotNull(poCookie, 'Cookie').
        
        return this-object:Cookies:Contains(poCookie).
    end method.
    
    /** Returns all the cookies for this message
        
        @param Cookie[] An array of cookies 
        @return integer The number of cookies returned */
    method public integer GetCookies(output poCookies as Cookie extent):
        assign poCookies = cast(this-object:Cookies:ToArray(), Cookie).
        
        return this-object:Cookies:Size.
    end method.
    
    /** Adds a cookie to this request 
    
        @param Cookie The cookie to add. */
    method public void SetCookie(input poCookie as Cookie):
        Assert:NotNull(poCookie, 'Cookie').
        this-object:Cookies:Add(poCookie).
    end method.
    
    /** Removes all cookies from this message */ 
    method public void ClearCookies():
        this-object:Cookies:Clear().
    end method.
    
    /** Removes all headers from this message */ 
    method public void ClearHeaders().
        this-object:Headers:Clear().
    end method.
    
end class.