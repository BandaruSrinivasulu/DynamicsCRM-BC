codeunit 50101 GetData
{
    trigger OnRun()
    var
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        content: HttpContent;
        header: HttpHeaders;
        responseText: Text;
        jsonResponseObject: JsonObject;
        authorization: Text;
    begin

        if client.Get('https://org34dc8529.crm.dynamics.com/api/data/v8.1/accounts/', response) then begin
            if response.IsSuccessStatusCode then begin
                response.Content().ReadAs(responseText);
                jsonResponseObject.ReadFrom(responseText);
            end;
        end;

        request.Method('GET');
        request.SetRequestUri('https://org34dc8529.crm.dynamics.com/api/data/v8.1/accounts/');
        header.Add('Content-Type', 'Application/Json');
        request.GetHeaders(header);
        client.DefaultRequestHeaders().Add('Authorization', authorization);
        client.Get('https://org34dc8529.crm.dynamics.com/api/data/v8.1/accounts/', response);
        response.Content().ReadAs(responseText);
    end;

    var
        myInt: Integer;
}