codeunit 50102 APICalls
{
    #region CRM to BC Flow

    /// <summary>
    /// Pull Contacts from CRM to BC
    /// </summary>
    /// <param name="RequestUrl">The Request URL.</param>
    /// <param name="AccessToken">The Access Token.</param>
    /// <returns>Returns</returns>
    procedure GetContacts(RequestUrl: Text; AccessToken: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        JObject: JsonObject;
        ResponseStream: InStream;
        APICallResponseMessage: Text;
        StatusCode: Integer;
        IsSuccessful: Boolean;

        cust: Record Customer;
        cust1: Record Customer;
        jObject1: JsonObject;
        jArray: JsonArray;
        jToken: JsonToken;
        jToken1: JsonToken;
        jToken2: JsonToken;
        jValue: JsonValue;
        i: Integer;
        isCustomerInserted: Boolean;
        numberSeriesManagement: Codeunit NoSeriesManagement;
        salesAndReceivable: Record "Sales & Receivables Setup";
        crmContactId: Text;
        genBusPostingGroup: Record "Gen. Business Posting Group";
        custPostingGroup: Record "Customer Posting Group";
        custPriceGroup: Record "Customer Price Group";
        msg: Text;
    begin
        msg := '';
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);
        RequestMessage.SetRequestUri(RequestUrl);
        RequestMessage.Method('GET');

        Clear(TempBlob);
        TempBlob.CreateInStream(ResponseStream);

        IsSuccessful := Client.Send(RequestMessage, ResponseMessage);

        if not IsSuccessful then
            exit('An API call with the provided header has failed.');

        if not ResponseMessage.IsSuccessStatusCode() then begin
            StatusCode := ResponseMessage.HttpStatusCode();
            exit('The request has failed with status code ' + Format(StatusCode));
        end;

        if not ResponseMessage.Content().ReadAs(ResponseStream) then
            exit('The response message cannot be processed.');


        if not JObject.ReadFrom(ResponseStream) then
            exit('Cannot read JSON response.');


        JObject.Get('value', jToken);
        jArray := jToken.AsArray();
        foreach jToken1 in jArray do begin
            cust.Init();
            salesAndReceivable.Get();
            cust.Validate("No.", numberSeriesManagement.GetNextNo(salesAndReceivable."Customer Nos.", 0D, true));

            jObject1 := jToken1.AsObject();

            Clear(jToken2);
            jObject1.get('contactid', jToken2);
            cust.CrmContactSchemaId := jToken2.AsValue().AsText();
            Clear(jToken2);

            Clear(jToken2);
            jObject1.get('emailaddress1', jToken2);
            cust."E-Mail" := jToken2.AsValue().AsText();
            Clear(jToken2);

            cust1.SetRange("E-Mail", cust."E-Mail");
            if not cust1.FindFirst() then begin

                jObject1.get('fullname', jToken2);
                cust.Name := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('creditlimit', jToken2);
                if not jToken2.AsValue().IsNull() then begin
                    cust."Credit Limit (LCY)" := jToken2.AsValue().AsDecimal();
                    Clear(jToken2);
                end;

                jObject1.get('address1_line1', jToken2);
                cust.Address := jToken2.AsValue().AsText();
                Clear(jToken2);

                //jObject1.get('telephone1', jToken2); //Business Phone In CRM
                jObject1.get('mobilephone', jToken2); //Mobile Phone In CRM
                //cust."Phone No." := jToken2.AsValue().AsText();
                cust."Phone No." := GetJsonTokenValueAsText(jToken2);
                Clear(jToken2);

                jObject1.get('address1_city', jToken2);
                cust.City := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('address1_stateorprovince', jToken2);
                cust.County := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('address1_postalcode', jToken2);
                cust."Post Code" := jToken2.AsValue().AsCode();
                Clear(jToken2);

                jObject1.get('address1_country', jToken2);
                cust."Country/Region Code" := jToken2.AsValue().AsCode();
                //cust."Country/Region Code" := 'US';
                Clear(jToken2);

                cust.SyncSource := HelixSyncSource::CRM;

                genBusPostingGroup.FindFirst();
                custPostingGroup.FindFirst();
                custPriceGroup.FindFirst();
                cust."Gen. Bus. Posting Group" := genBusPostingGroup.Code;
                cust."Customer Posting Group" := custPostingGroup.Code;
                cust."Customer Price Group" := custPriceGroup.Code;

                isCustomerInserted := cust.Insert(false);

                if isCustomerInserted then begin
                    msg := msg + '\' + cust.Name;
                end;
            end;
        end;

        Message('Synced Customers:\\' + msg);

        JObject.WriteTo(APICallResponseMessage);
        APICallResponseMessage := APICallResponseMessage.Replace(',', '\');
        exit(APICallResponseMessage);
    end;

    local procedure GetJsonTokenValueAsText(var jToken: JsonToken): Text
    var
        jValue: JsonValue;
    begin
        if jToken.IsValue then begin
            jValue := jToken.AsValue();
            if not jValue.IsNull then begin
                exit(jValue.AsText());
            end;
            exit('');
        end;
    end;

    local procedure GetJsonTokenValueAsCode(var jToken: JsonToken): Code[100]
    var
        jValue: JsonValue;
    begin
        if jToken.IsValue then begin
            jValue := jToken.AsValue();
            if not jValue.IsNull then begin
                exit(jValue.AsCode());
            end;
            exit('');
        end;
    end;

    local procedure GetJsonTokenValueAsInteger(var jToken: JsonToken): Integer
    var
        jValue: JsonValue;
    begin
        if jToken.IsValue then begin
            jValue := jToken.AsValue();
            if not jValue.IsNull then begin
                exit(jValue.AsInteger());
            end;
            exit(0);
        end;
    end;

    local procedure GetJsonTokenValueAsDecimal(var jToken: JsonToken): Decimal
    var
        jValue: JsonValue;
    begin
        if jToken.IsValue then begin
            jValue := jToken.AsValue();
            if not jValue.IsNull then begin
                exit(jValue.AsDecimal());
            end;
            exit(0);
        end;
    end;

    /// <summary>
    /// Pull Products from CRM to BC
    /// </summary>
    /// <param name="RequestUrl">The Request URL.</param>
    /// <param name="AccessToken">The Access Token.</param>
    /// <returns>Returns</returns>
    procedure GetProducts(RequestUrl: Text; AccessToken: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        JObject: JsonObject;
        ResponseStream: InStream;
        APICallResponseMessage: Text;
        StatusCode: Integer;
        IsSuccessful: Boolean;

        item: Record Item;
        item1: Record Item;
        jObject1: JsonObject;
        jArray: JsonArray;
        jToken: JsonToken;
        jToken1: JsonToken;
        jToken2: JsonToken;
        jValue: JsonValue;
        i: Integer;
        isProductInserted: Boolean;
        crmProductId: Text;
        genProductPostingGroup: Record "Gen. Product Posting Group";
        invPostingGroup: Record "Inventory Posting Group";
        uofm: Record "Unit of Measure";
        //location: Record Location;
        msg: Text;
    begin
        msg := '';
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);
        RequestMessage.SetRequestUri(RequestUrl);
        RequestMessage.Method('GET');

        Clear(TempBlob);
        TempBlob.CreateInStream(ResponseStream);

        IsSuccessful := Client.Send(RequestMessage, ResponseMessage);

        if not IsSuccessful then
            exit('An API call with the provided header has failed.');

        if not ResponseMessage.IsSuccessStatusCode() then begin
            StatusCode := ResponseMessage.HttpStatusCode();
            exit('The request has failed with status code ' + Format(StatusCode));
        end;

        if not ResponseMessage.Content().ReadAs(ResponseStream) then
            exit('The response message cannot be processed.');


        if not JObject.ReadFrom(ResponseStream) then
            exit('Cannot read JSON response.');


        JObject.Get('value', jToken);
        jArray := jToken.AsArray();
        foreach jToken1 in jArray do begin
            item.Init();
            jObject1 := jToken1.AsObject();

            Clear(jToken2);
            jObject1.get('productid', jToken2);
            item.CrmItemSchemaId := jToken2.AsValue().AsText();
            Clear(jToken2);

            Clear(jToken2);
            jObject1.get('_defaultuomscheduleid_value', jToken2);
            item.CrmUofmScheduleId := jToken2.AsValue().AsText();
            Clear(jToken2);

            Clear(jToken2);
            jObject1.get('_defaultuomid_value', jToken2);
            item.CrmUofmId := jToken2.AsValue().AsText();
            Clear(jToken2);

            Clear(jToken2);
            jObject1.get('productnumber', jToken2);
            item."No." := jToken2.AsValue().AsText();
            Clear(jToken2);

            item1.SetRange("No.", item."No.");
            if not item1.FindFirst() then begin

                jObject1.get('productnumber', jToken2);
                item."No." := jToken2.AsValue().AsCode();
                Clear(jToken2);

                jObject1.get('name', jToken2);
                item.Description := jToken2.AsValue().AsText();
                Clear(jToken2);

                //Unique Product Id, which is used at order line item level
                jObject1.get('productid', jToken2);
                //item."Description 2" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('price', jToken2);
                item."Unit Price" := jToken2.AsValue().AsDecimal();
                Clear(jToken2);

                item.SyncSource := HelixSyncSource::CRM;

                genProductPostingGroup.FindFirst();
                invPostingGroup.FindFirst();
                uofm.SetRange(Code, 'PCS');
                uofm.FindFirst();
                // location.SetRange(Code, 'BLUE');
                // location.FindFirst();
                item."Gen. Prod. Posting Group" := genProductPostingGroup.Code;
                item."Inventory Posting Group" := invPostingGroup.Code;
                item."Base Unit of Measure" := uofm.Code;

                isProductInserted := item.Insert(false);

                if isProductInserted then begin
                    msg := msg + '\' + item."No.";
                end;
            end;
        end;
        Message('Synced Products:\\' + msg);

        JObject.WriteTo(APICallResponseMessage);
        APICallResponseMessage := APICallResponseMessage.Replace(',', '\');
        exit(APICallResponseMessage);
    end;

    /// <summary>
    /// Pull Sales Orders from CRM to BC
    /// </summary>
    /// <param name="RequestUrl">The Request URL.</param>
    /// <param name="AccessToken">The Access Token.</param>
    /// <returns>Returns</returns>
    procedure GetSalesOrders(RequestUrl: Text; AccessToken: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        JObject: JsonObject;
        ResponseStream: InStream;
        APICallResponseMessage: Text;
        StatusCode: Integer;
        IsSuccessful: Boolean;

        cust: Record Customer;
        sHeader: Record "Sales Header";
        sHeader1: Record "Sales Header";
        sLine: Record "Sales Line";
        jObject1: JsonObject;
        jArray: JsonArray;
        jToken: JsonToken;
        jToken1: JsonToken;
        jToken2: JsonToken;
        jValue: JsonValue;
        i: Integer;
        isSalesHeaderInserted: Boolean;
        lineNo: Integer;
        isSalesLineInserted: Boolean;
        crmSalesOrderUniqueId: Text;
        jObjectLine: JsonObject;
        jObjectLine1: JsonObject;
        jArrayLine: JsonArray;
        jTokenLine: JsonToken;
        jTokenLine1: JsonToken;
        jTokenLine2: JsonToken;
        uniqueProductId: Text;
        itm: Record Item;
        helixSalesTable: Record HelixSalesTable;
        crmCustomerSchemaId: Text;
        msg: Text;
        location: Record Location;
        ordNumber: Text;
    begin
        msg := '';
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);
        RequestMessage.SetRequestUri(RequestUrl);
        RequestMessage.Method('GET');

        Clear(TempBlob);
        TempBlob.CreateInStream(ResponseStream);

        IsSuccessful := Client.Send(RequestMessage, ResponseMessage);

        if not IsSuccessful then
            exit('An API call with the provided header has failed.');

        if not ResponseMessage.IsSuccessStatusCode() then begin
            StatusCode := ResponseMessage.HttpStatusCode();
            exit('The request has failed with status code ' + Format(StatusCode));
        end;

        if not ResponseMessage.Content().ReadAs(ResponseStream) then
            exit('The response message cannot be processed.');


        if not JObject.ReadFrom(ResponseStream) then
            exit('Cannot read JSON response.');


        JObject.Get('value', jToken);
        jArray := jToken.AsArray();
        foreach jToken1 in jArray do begin
            sHeader.Init();
            jObject1 := jToken1.AsObject();

            sHeader."Document Type" := sHeader."Document Type"::Order;

            Clear(jToken2);
            jObject1.get('ordernumber', jToken2);
            sHeader."No." := jToken2.AsValue().AsText();
            Clear(jToken2);

            Clear(jToken2);
            Clear(crmSalesOrderUniqueId);
            jObject1.get('salesorderid', jToken2);
            crmSalesOrderUniqueId := jToken2.AsValue().AsText();
            Clear(jToken2);
            Clear(helixSalesTable);
            //helixSalesTable.Reset();
            //helixSalesTable.Init();
            helixSalesTable.SalesOrderType := HelixSalesTypes::SalesOrder;
            helixSalesTable.CRMSalesId := sHeader."No.";
            helixSalesTable.CRMSalesSchemaId := crmSalesOrderUniqueId;
            jObject1.get('_customerid_value', jToken2);
            crmCustomerSchemaId := jToken2.AsValue().AsText();
            helixSalesTable.CRMSalesCustomerId := crmCustomerSchemaId;
            helixSalesTable.SalesSyncSource := HelixSyncSource::CRM;
            helixSalesTable.Insert(true);
            Commit();
            Clear(jToken2);

            sHeader1.SetRange("No.", sHeader."No.");
            if not sHeader1.FindFirst() then begin

                jObject1.get('ordernumber', jToken2);
                sHeader."No." := jToken2.AsValue().AsCode();
                sHeader."External Document No." := jToken2.AsValue().AsCode();
                ordNumber := sHeader."No.";
                Clear(jToken2);

                jObject1.get('_customerid_value', jToken2);
                cust.Reset();
                //cust.SetRange("Home Page", jToken2.AsValue().AsText());
                cust.SetRange(CrmContactSchemaId, jToken2.AsValue().AsText());
                if cust.FindFirst() then begin
                    sHeader."Sell-to Customer No." := cust."No.";
                    sHeader."Bill-to Customer No." := cust."No.";
                end else begin
                    Error('Customer Not Found');
                end;
                Clear(jToken2);

                jObject1.get('name', jToken2);
                sHeader."Sell-to Customer Name" := jToken2.AsValue().AsText();
                sHeader."Bill-to Name" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('billto_line1', jToken2);
                sHeader."Sell-to Address" := jToken2.AsValue().AsText();
                sHeader."Bill-to Address" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('billto_line2', jToken2);
                sHeader."Sell-to Address 2" := jToken2.AsValue().AsText();
                sHeader."Bill-to Address 2" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('billto_city', jToken2);
                sHeader."Sell-to City" := jToken2.AsValue().AsText();
                sHeader."Bill-to City" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('billto_stateorprovince', jToken2);
                sHeader."Sell-to County" := jToken2.AsValue().AsText();
                sHeader."Bill-to County" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('billto_postalcode', jToken2);
                sHeader."Sell-to Post Code" := jToken2.AsValue().AsCode();
                sHeader."Bill-to Post Code" := jToken2.AsValue().AsCode();
                Clear(jToken2);

                jObject1.get('billto_country', jToken2);
                sHeader."Sell-to Country/Region Code" := jToken2.AsValue().AsCode();
                sHeader."Bill-to Country/Region Code" := jToken2.AsValue().AsCode();
                Clear(jToken2);


                jObject1.get('name', jToken2);
                sHeader."Ship-to Name" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('shipto_line1', jToken2);
                sHeader."Ship-to Address" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('shipto_line2', jToken2);
                sHeader."Ship-to Address 2" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('shipto_city', jToken2);
                sHeader."Ship-to City" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('shipto_stateorprovince', jToken2);
                sHeader."Ship-to County" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('shipto_postalcode', jToken2);
                sHeader."Ship-to Post Code" := jToken2.AsValue().AsCode();
                Clear(jToken2);

                jObject1.get('shipto_country', jToken2);
                sHeader."Ship-to Country/Region Code" := jToken2.AsValue().AsCode();
                Clear(jToken2);

                //Based on CRM Shipping Method Code need to fill Shipping Agent Code in BC
                //Here Shipping Agent Code hardcoded
                jObject1.get('shippingmethodcode', jToken2);
                sHeader."Shipping Agent Code" := 'DHL';
                Clear(jToken2);

                //sHeader."Your Reference" := crmSalesOrderUniqueId;
                sHeader."Document Date" := Today;
                sHeader."Order Date" := Today;
                sHeader."Posting Date" := Today;
                isSalesHeaderInserted := sHeader.Insert(false);


                Clear(RequestMessage);
                Clear(RequestUrl);
                Clear(ResponseMessage);
                RequestUrl := 'https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/salesorderdetails?$filter=_salesorderid_value eq ' + crmSalesOrderUniqueId;
                RequestMessage.GetHeaders(RequestHeaders);
                RequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);
                RequestMessage.SetRequestUri(RequestUrl);
                RequestMessage.Method('GET');

                Clear(TempBlob);
                TempBlob.CreateInStream(ResponseStream);

                IsSuccessful := Client.Send(RequestMessage, ResponseMessage);

                if not IsSuccessful then
                    exit('An API call with the provided header has failed.');

                if not ResponseMessage.IsSuccessStatusCode() then begin
                    StatusCode := ResponseMessage.HttpStatusCode();
                    exit('The request has failed with status code ' + Format(StatusCode));
                end;

                if not ResponseMessage.Content().ReadAs(ResponseStream) then
                    exit('The response message cannot be processed.');


                if not jObjectLine.ReadFrom(ResponseStream) then
                    exit('Cannot read JSON response.');

                jObjectLine.Get('value', jTokenLine);
                jArrayLine := jTokenLine.AsArray();

                foreach jTokenLine1 in jArrayLine do begin
                    sLine.Init();
                    jObjectLine1 := jTokenLine1.AsObject();

                    sLine.Validate("Document Type", sLine."Document Type"::Order);
                    sLine.Validate("Document No.", sHeader."No.");
                    sline.Validate("Sell-to Customer No.", sHeader."Sell-to Customer No.");
                    sLine.Validate("Line No.", lineNo + 1000);
                    sline.Insert();
                    sLine.Validate(Type, sLine.Type::Item);

                    Clear(jTokenLine2);

                    jObjectLine1.get('_productid_value', jTokenLine2);
                    uniqueProductId := jTokenLine2.AsValue().AsText();
                    itm.Reset();
                    //itm.SetRange("Description 2", uniqueProductId);
                    itm.SetRange(CrmItemSchemaId, uniqueProductId);
                    if itm.FindFirst() then begin
                        sLine.Validate("No.", itm."No.");
                    end;
                    Clear(jTokenLine2);

                    jObjectLine1.get('quantity', jTokenLine2);
                    sLine.Validate(Quantity, jTokenLine2.AsValue().AsDecimal());
                    Clear(jTokenLine2);

                    jObjectLine1.get('priceperunit', jTokenLine2);
                    sLine.Validate("Unit Price", jTokenLine2.AsValue().AsDecimal());
                    Clear(jTokenLine2);

                    //sLine."Unit of Measure" := 'PCS';
                    location.SetRange(Code, 'MAIN');
                    location.FindFirst();
                    sLine."Location Code" := location.Code;

                    isSalesLineInserted := sLine.Modify(true);
                    lineNo := sLine."Line No.";
                end;
                msg := msg + '\' + ordNumber;
            end;
        end;

        if msg <> '' then begin
            Message('Synced Sales Orders:\\' + msg);
        end;


        JObject.WriteTo(APICallResponseMessage);
        APICallResponseMessage := APICallResponseMessage.Replace(',', '\');
        exit(APICallResponseMessage);
    end;

    /// <summary>
    /// Pull Sales Quotes from CRM to BC
    /// </summary>
    /// <param name="RequestUrl">The Request URL.</param>
    /// <param name="AccessToken">The Access Token.</param>
    /// <returns>Returns</returns>
    procedure GetSalesQuotes(RequestUrl: Text; AccessToken: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        JObject: JsonObject;
        ResponseStream: InStream;
        APICallResponseMessage: Text;
        StatusCode: Integer;
        IsSuccessful: Boolean;

        cust: Record Customer;
        sQuoteHeader: Record "Sales Header";
        sQuoteHeader1: Record "Sales Header";
        sQuoteLine: Record "Sales Line";
        jObject1: JsonObject;
        jArray: JsonArray;
        jToken: JsonToken;
        jToken1: JsonToken;
        jToken2: JsonToken;
        jValue: JsonValue;
        i: Integer;
        isSalesQuoteHeaderInserted: Boolean;
        lineNo: Integer;
        isSalesQuoteLineInserted: Boolean;
        crmSalesQuoteUniqueId: Text;
        jObjectLine: JsonObject;
        jObjectLine1: JsonObject;
        jArrayLine: JsonArray;
        jTokenLine: JsonToken;
        jTokenLine1: JsonToken;
        jTokenLine2: JsonToken;
        uniqueProductId: Text;
        itm: Record Item;
        helixSalesTable: Record HelixSalesTable;
        crmCustomerSchemaId: Text;
        msg: Text;
        location: Record Location;
        quoteNumber: Text;

    begin
        msg := '';
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);
        RequestMessage.SetRequestUri(RequestUrl);
        RequestMessage.Method('GET');

        Clear(TempBlob);
        TempBlob.CreateInStream(ResponseStream);

        IsSuccessful := Client.Send(RequestMessage, ResponseMessage);

        if not IsSuccessful then
            exit('An API call with the provided header has failed.');

        if not ResponseMessage.IsSuccessStatusCode() then begin
            StatusCode := ResponseMessage.HttpStatusCode();
            exit('The request has failed with status code ' + Format(StatusCode));
        end;

        if not ResponseMessage.Content().ReadAs(ResponseStream) then
            exit('The response message cannot be processed.');


        if not JObject.ReadFrom(ResponseStream) then
            exit('Cannot read JSON response.');


        JObject.Get('value', jToken);
        jArray := jToken.AsArray();
        foreach jToken1 in jArray do begin
            sQuoteHeader.Init();
            jObject1 := jToken1.AsObject();

            sQuoteHeader."Document Type" := sQuoteHeader."Document Type"::Quote;

            Clear(jToken2);
            jObject1.get('quotenumber', jToken2);
            sQuoteHeader."No." := jToken2.AsValue().AsText();
            Clear(jToken2);

            Clear(jToken2);
            Clear(crmSalesQuoteUniqueId);
            jObject1.get('quoteid', jToken2);
            crmSalesQuoteUniqueId := jToken2.AsValue().AsText();
            Clear(jToken2);
            Clear(helixSalesTable);
            //helixSalesTable.Reset();
            //helixSalesTable.Init();
            helixSalesTable.SalesOrderType := HelixSalesTypes::SalesOrder;
            helixSalesTable.CRMSalesId := sQuoteHeader."No.";
            helixSalesTable.CRMSalesSchemaId := crmSalesQuoteUniqueId;
            jObject1.get('_customerid_value', jToken2);
            crmCustomerSchemaId := jToken2.AsValue().AsText();
            helixSalesTable.CRMSalesCustomerId := crmCustomerSchemaId;
            helixSalesTable.SalesSyncSource := HelixSyncSource::CRM;
            helixSalesTable.Insert(true);
            Commit();
            Clear(jToken2);

            sQuoteHeader1.SetRange("No.", sQuoteHeader."No.");
            if not sQuoteHeader1.FindFirst() then begin

                jObject1.get('quotenumber', jToken2);
                sQuoteHeader."No." := jToken2.AsValue().AsCode();
                sQuoteHeader."External Document No." := jToken2.AsValue().AsCode();
                quoteNumber := sQuoteHeader."No.";
                Clear(jToken2);

                jObject1.get('_customerid_value', jToken2);
                cust.Reset();
                //cust.SetRange("Home Page", jToken2.AsValue().AsText());
                cust.SetRange(CrmContactSchemaId, jToken2.AsValue().AsText());
                if cust.FindFirst() then begin
                    sQuoteHeader."Sell-to Customer No." := cust."No.";
                    sQuoteHeader."Bill-to Customer No." := cust."No.";
                end else begin
                    Error('Customer Not Found');
                end;
                Clear(jToken2);

                jObject1.get('name', jToken2);
                sQuoteHeader."Sell-to Customer Name" := jToken2.AsValue().AsText();
                sQuoteHeader."Bill-to Name" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('billto_line1', jToken2);
                sQuoteHeader."Sell-to Address" := jToken2.AsValue().AsText();
                sQuoteHeader."Bill-to Address" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('billto_line2', jToken2);
                sQuoteHeader."Sell-to Address 2" := jToken2.AsValue().AsText();
                sQuoteHeader."Bill-to Address 2" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('billto_city', jToken2);
                sQuoteHeader."Sell-to City" := jToken2.AsValue().AsText();
                sQuoteHeader."Bill-to City" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('billto_stateorprovince', jToken2);
                sQuoteHeader."Sell-to County" := jToken2.AsValue().AsText();
                sQuoteHeader."Bill-to County" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('billto_postalcode', jToken2);
                sQuoteHeader."Sell-to Post Code" := jToken2.AsValue().AsCode();
                sQuoteHeader."Bill-to Post Code" := jToken2.AsValue().AsCode();
                Clear(jToken2);

                jObject1.get('billto_country', jToken2);
                sQuoteHeader."Sell-to Country/Region Code" := jToken2.AsValue().AsCode();
                sQuoteHeader."Bill-to Country/Region Code" := jToken2.AsValue().AsCode();
                Clear(jToken2);


                jObject1.get('name', jToken2);
                sQuoteHeader."Ship-to Name" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('shipto_line1', jToken2);
                sQuoteHeader."Ship-to Address" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('shipto_line2', jToken2);
                sQuoteHeader."Ship-to Address 2" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('shipto_city', jToken2);
                sQuoteHeader."Ship-to City" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('shipto_stateorprovince', jToken2);
                sQuoteHeader."Ship-to County" := jToken2.AsValue().AsText();
                Clear(jToken2);

                jObject1.get('shipto_postalcode', jToken2);
                sQuoteHeader."Ship-to Post Code" := jToken2.AsValue().AsCode();
                Clear(jToken2);

                jObject1.get('shipto_country', jToken2);
                sQuoteHeader."Ship-to Country/Region Code" := jToken2.AsValue().AsCode();
                Clear(jToken2);

                //Based on CRM Shipping Method Code need to fill Shipping Agent Code in BC
                //Here Shipping Agent Code hardcoded
                // jObject1.get('shippingmethodcode', jToken2);
                // sQuoteHeader."Shipping Agent Code" := 'DHL';
                // Clear(jToken2);

                //sHeader."Your Reference" := crmSalesOrderUniqueId;

                sQuoteHeader."Document Date" := Today;
                sQuoteHeader."Order Date" := Today;
                sQuoteHeader."Posting Date" := Today;
                isSalesQuoteHeaderInserted := sQuoteHeader.Insert(false);


                Clear(RequestMessage);
                Clear(RequestUrl);
                Clear(ResponseMessage);
                RequestUrl := 'https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/quotedetails?$filter=_quoteid_value eq ' + crmSalesQuoteUniqueId;
                RequestMessage.GetHeaders(RequestHeaders);
                RequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);
                RequestMessage.SetRequestUri(RequestUrl);
                RequestMessage.Method('GET');

                Clear(TempBlob);
                TempBlob.CreateInStream(ResponseStream);

                IsSuccessful := Client.Send(RequestMessage, ResponseMessage);

                if not IsSuccessful then
                    exit('An API call with the provided header has failed.');

                if not ResponseMessage.IsSuccessStatusCode() then begin
                    StatusCode := ResponseMessage.HttpStatusCode();
                    exit('The request has failed with status code ' + Format(StatusCode));
                end;

                if not ResponseMessage.Content().ReadAs(ResponseStream) then
                    exit('The response message cannot be processed.');


                if not jObjectLine.ReadFrom(ResponseStream) then
                    exit('Cannot read JSON response.');

                jObjectLine.Get('value', jTokenLine);
                jArrayLine := jTokenLine.AsArray();

                foreach jTokenLine1 in jArrayLine do begin
                    sQuoteLine.Init();
                    jObjectLine1 := jTokenLine1.AsObject();

                    sQuoteLine.Validate("Document Type", sQuoteLine."Document Type"::Quote);
                    sQuoteLine.Validate("Document No.", sQuoteHeader."No.");
                    sQuoteLine.Validate("Sell-to Customer No.", sQuoteHeader."Sell-to Customer No.");
                    sQuoteLine.Validate("Line No.", lineNo + 1000);
                    sQuoteLine.Insert();
                    sQuoteLine.Validate(Type, sQuoteLine.Type::Item);

                    Clear(jTokenLine2);

                    jObjectLine1.get('_productid_value', jTokenLine2);
                    uniqueProductId := jTokenLine2.AsValue().AsText();
                    itm.Reset();
                    //itm.SetRange("Description 2", uniqueProductId);
                    itm.SetRange(CrmItemSchemaId, uniqueProductId);
                    if itm.FindFirst() then begin
                        sQuoteLine.Validate("No.", itm."No.");
                    end;
                    Clear(jTokenLine2);

                    jObjectLine1.get('quantity', jTokenLine2);
                    sQuoteLine.Validate(Quantity, jTokenLine2.AsValue().AsDecimal());
                    Clear(jTokenLine2);

                    jObjectLine1.get('priceperunit', jTokenLine2);
                    sQuoteLine.Validate("Unit Price", jTokenLine2.AsValue().AsDecimal());
                    Clear(jTokenLine2);

                    //sLine."Unit of Measure" := 'PCS';
                    location.SetRange(Code, 'MAIN');
                    location.FindFirst();
                    sQuoteLine."Location Code" := location.Code;

                    isSalesQuoteLineInserted := sQuoteLine.Modify(true);
                    lineNo := sQuoteLine."Line No.";
                end;
                msg := msg + '\' + quoteNumber;
            end;
        end;

        if msg <> '' then begin
            Message('Synced Sales Quotes:\\' + msg);
        end;


        JObject.WriteTo(APICallResponseMessage);
        APICallResponseMessage := APICallResponseMessage.Replace(',', '\');
        exit(APICallResponseMessage);
    end;

    #endregion

    #region BC to CRM Flow

    /// <summary>
    /// Push Customers from BC to CRM
    /// </summary>
    /// <param name="RequestUrl">The Request URL.</param>
    /// <param name="AccessToken">The Access Token.</param>
    /// <returns>Returns</returns>
    procedure PushCustomersFromBC(RequestUrl: Text; AccessToken: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        httpbodyContent: HttpContent;
        JObject: JsonObject;
        ResponseStream: InStream;
        APICallResponseMessage: Text;
        StatusCode: Integer;
        IsSuccessful: Boolean;

        cust: Record Customer;
        cust1: Record Customer;
        jObject1: JsonObject;
        jArray: JsonArray;
        jToken: JsonToken;
        jToken1: JsonToken;
        jToken2: JsonToken;
        jValue: JsonValue;
        i: Integer;
        isCustomerInserted: Boolean;
        isCustomerUpdated: Boolean;
        custInfo: Text;
        customerResponse: Text;
        crmCustomerSchemaId: Text;
        syncStatus: Enum HelixEntitySyncStatus;
    begin
        //The below line should be automate using JobQueue
        //cust.FindLast();

        //Picking the record based on the status
        cust.Reset();
        Clear(cust);
        cust.SetRange(SyncStatus, syncStatus::Pending);
        if cust.FindSet() then begin
            repeat begin
                if cust."No." <> '' then begin
                    cust.SyncStatus := HelixEntitySyncStatus::InProcess;

                    JObject.Add('firstname', cust.Name);
                    JObject.Add('lastname', cust.Name);
                    JObject.Add('emailaddress1', cust."E-Mail");
                    JObject.Add('telephone1', cust."Phone No.");
                    jObject.WriteTo(custInfo);

                    httpbodyContent.Clear();
                    httpbodyContent.WriteFrom(custInfo);
                    httpbodyContent.GetHeaders(RequestHeaders);

                    RequestHeaders.Remove('Content-Type');
                    RequestHeaders.Add('Content-Type', 'application/json');
                    RequestHeaders.Add('Prefer', 'return=representation');

                    RequestMessage.Method := 'POST';
                    RequestMessage.SetRequestUri(RequestUrl);
                    RequestMessage.GetHeaders(RequestHeaders);
                    RequestMessage.Content := httpbodyContent;

                    Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);

                    isCustomerInserted := Client.Post(RequestUrl, httpbodyContent, ResponseMessage);

                    if isCustomerInserted then begin
                        if ResponseMessage.IsSuccessStatusCode then begin
                            if ResponseMessage.ReasonPhrase = 'Created' then begin
                                Message('Customer %1 Created Successfully in Dynamics CRM', cust.Name);

                                cust.SyncStatus := HelixEntitySyncStatus::Complete;

                                ResponseMessage.Content().ReadAs(customerResponse);
                                Clear(jObject1);
                                jObject1.ReadFrom(customerResponse);
                                jObject1.get('contactid', jToken);
                                crmCustomerSchemaId := jToken.AsValue().AsText();
                                cust.CrmContactSchemaId := crmCustomerSchemaId;
                                cust.SyncSource := HelixSyncSource::BC;
                                cust1.Init();
                                cust1 := cust;
                                isCustomerUpdated := cust1.Modify(false);
                            end;
                        end;
                    end;
                end;
            end until cust.Next() = 0;
        end;
    end;

    /// <summary>
    /// Push Products from BC to CRM
    /// </summary>
    /// <param name="RequestUrl">The Request URL.</param>
    /// <param name="AccessToken">The Access Token.</param>
    /// <returns>Returns</returns>
    procedure PushProductsFromBC(RequestUrl: Text; AccessToken: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        httpbodyContent: HttpContent;
        JObject: JsonObject;
        ResponseStream: InStream;
        APICallResponseMessage: Text;
        StatusCode: Integer;
        IsSuccessful: Boolean;

        item: Record Item;
        item1: Record Item;
        jObject1: JsonObject;
        jArray: JsonArray;
        jToken: JsonToken;
        jToken1: JsonToken;
        jToken2: JsonToken;
        jValue: JsonValue;
        i: Integer;
        isProductPostCallSuccess: Boolean;
        itemInfo: Text;
        itemResponse: Text;
        crmProductSchemaId: Text;
        isItemUpdated: Boolean;
        crmUofmId: Text;
        crmUofmScheduleId: Text;
        syncStatus: Enum HelixEntitySyncStatus;
    begin
        //The below line should be automate through JobQueue
        //item.FindLast();

        //Picking the record based on the status
        item.Reset();
        Clear(item);
        item.SetRange(SyncStatus, syncStatus::Pending);
        if item.FindSet() then begin
            repeat begin
                if item."No." <> '' then begin
                    item.SyncStatus := HelixEntitySyncStatus::InProcess;

                    JObject.Add('productnumber', item."No.");
                    JObject.Add('name', item.Description);
                    JObject.Add('price', item."Unit Price");
                    JObject.Add('description', item."Description 2");
                    //the below two properties are called as navigational or relational properties
                    //To create a product in CRM through api, these fields are required to pass.
                    //the uoms endpoint will provide values for these two properties.
                    //JObject.Add('defaultuomscheduleid@odata.bind', '/uoms(371e8a7e-7728-4edf-a0db-e3a87b04967e)');
                    JObject.Add('defaultuomscheduleid@odata.bind', '/uoms(d86b8caa-fb0d-4c0e-920e-aeecbad54403)');
                    //JObject.Add('defaultuomid@odata.bind', '/uoms(5c5f4f66-b1a7-ec11-983f-000d3a5b777d)');
                    JObject.Add('defaultuomid@odata.bind', '/uoms(be04cdbc-78c0-4e21-bb3f-4fd345373db4)');
                    jObject.WriteTo(itemInfo);

                    httpbodyContent.Clear();
                    httpbodyContent.WriteFrom(itemInfo);
                    httpbodyContent.GetHeaders(RequestHeaders);

                    RequestHeaders.Remove('Content-Type');
                    RequestHeaders.Add('Content-Type', 'application/json');
                    RequestHeaders.Add('Prefer', 'return=representation');

                    RequestMessage.Method := 'POST';
                    RequestMessage.SetRequestUri(RequestUrl);
                    RequestMessage.GetHeaders(RequestHeaders);
                    RequestMessage.Content := httpbodyContent;

                    Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);

                    isProductPostCallSuccess := Client.Post(RequestUrl, httpbodyContent, ResponseMessage);

                    if isProductPostCallSuccess then begin
                        if ResponseMessage.IsSuccessStatusCode then begin
                            if ResponseMessage.ReasonPhrase = 'Created' then begin
                                ResponseMessage.Content().ReadAs(itemResponse);
                                Clear(jObject1);
                                jObject1.ReadFrom(itemResponse);
                                jObject1.get('productid', jToken);
                                crmProductSchemaId := jToken.AsValue().AsText();
                                item.CrmItemSchemaId := crmProductSchemaId;

                                Clear(jToken);
                                jObject1.Get('_defaultuomid_value', jToken);
                                crmUofmId := jToken.AsValue().AsText();
                                item.CrmUofmId := crmUofmId;

                                Clear(jToken);
                                jObject1.Get('_defaultuomscheduleid_value', jToken);
                                crmUofmScheduleId := jToken.AsValue().AsText();
                                item.CrmUofmScheduleId := crmUofmScheduleId;

                                item.SyncSource := HelixSyncSource::BC;
                                item.SyncStatus := HelixEntitySyncStatus::Complete;

                                Clear(jToken);
                                item1.Init();
                                item1 := item;
                                isItemUpdated := item1.Modify(false);

                                Message('Product %1 Created Successfully in Dynamics CRM', item."No.");
                            end;
                        end;
                    end;
                end;
            end until item.Next() = 0;
        end;
    end;

    /// <summary>
    /// Push Sales Orders from BC to CRM
    /// </summary>
    /// <param name="RequestUrl">The Request URL.</param>
    /// <param name="AccessToken">The Access Token.</param>
    /// <returns>Returns</returns>
    procedure PushSalesOrdersFromBC(RequestUrl: Text; AccessToken: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestHeaders1: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        RequestMessage1: HttpRequestMessage;
        httpbodyContent: HttpContent;
        httpbodyContent1: HttpContent;
        JObject: JsonObject;
        ResponseStream: InStream;
        APICallResponseMessage: Text;
        StatusCode: Integer;
        IsSuccessful: Boolean;

        sheader: Record "Sales Header";
        sline: Record "Sales Line";
        jObject1: JsonObject;
        jArray: JsonArray;
        jToken: JsonToken;
        jToken1: JsonToken;
        jToken2: JsonToken;
        jToken3: JsonToken;
        jValue: JsonValue;
        i: Integer;
        isSalesOrderPostCallSuccess: Boolean;
        isSalesOrderLinesPostCallSuccess: Boolean;
        salesOrderInfo: Text;
        salesLinesInfo: Text;
        cust: Record Customer;
        salesOrderResponse: Text;
        crmSalesOrderSchemaId: Text;
        jObject2: JsonObject;
        item: Record Item;
        crmItemSchemaId: Text;
        productApi: Text;
        helixSalesTable: Record HelixSalesTable;
        bcSalesOrderNo: Text;
        crmitemuofmid: Text;
        crmitemuofmscheduleid: Text;
        uofmApi: Text;
        syncStatus: Enum HelixEntitySyncStatus;
    begin
        sheader.Init();
        sheader.SetRange("Document Type", sheader."Document Type"::Order);

        //The below line should be automate using JobQueue.
        //sheader.FindLast();

        sheader.SetRange(SyncStatus, syncStatus::Pending);
        if sheader.FindSet() then begin
            repeat begin
                Clear(JObject);
                Clear(httpbodyContent);
                Clear(RequestHeaders);
                Clear(RequestMessage);
                Clear(Client);
                Clear(ResponseMessage);
                Clear(isSalesOrderPostCallSuccess);
                Clear(jToken);
                Clear(sline);
                if sheader."No." <> '' then begin
                    sheader.Validate(SyncStatus, syncStatus::InProcess);

                    //JObject.Add('ordernumber', Random(9999));
                    bcSalesOrderNo := sheader."No.";
                    JObject.Add('ordernumber', sheader."No.");
                    cust.Reset();
                    cust.SetRange("No.", sheader."Sell-to Customer No.");
                    cust.FindFirst();
                    //JObject.Add('customerid_contact@odata.bind', 'contacts/' + cust."Home Page");
                    JObject.Add('customerid_contact@odata.bind', 'contacts/' + cust.CrmContactSchemaId);
                    JObject.Add('name', cust.Name);
                    JObject.Add('billto_line1', sheader."Sell-to Address");
                    JObject.Add('billto_line2', sheader."Sell-to Address 2");
                    JObject.Add('billto_city', sheader."Sell-to City");
                    JObject.Add('billto_stateorprovince', sheader."Sell-to County");
                    JObject.Add('billto_postalcode', sheader."Sell-to Post Code");
                    JObject.Add('billto_country', sheader."Sell-to Country/Region Code");

                    JObject.Add('shipto_line1', sheader."Ship-to Address");
                    JObject.Add('shipto_line2', sheader."Ship-to Address 2");
                    JObject.Add('shipto_city', sheader."Ship-to City");
                    JObject.Add('shipto_stateorprovince', sheader."Ship-to County");
                    JObject.Add('shipto_postalcode', sheader."Ship-to Post Code");
                    JObject.Add('shipto_country', sheader."Ship-to Country/Region Code");

                    JObject.Add('shippingmethodcode', 2);

                    jObject.WriteTo(salesOrderInfo);

                    httpbodyContent.Clear();
                    httpbodyContent.WriteFrom(salesOrderInfo);
                    httpbodyContent.GetHeaders(RequestHeaders);

                    RequestHeaders.Remove('Content-Type');
                    RequestHeaders.Add('Content-Type', 'application/json');
                    RequestHeaders.Add('Prefer', 'return=representation');

                    RequestMessage.Method := 'POST';
                    RequestMessage.SetRequestUri(RequestUrl);
                    RequestMessage.GetHeaders(RequestHeaders);
                    RequestMessage.Content := httpbodyContent;

                    Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);

                    isSalesOrderPostCallSuccess := Client.Post(RequestUrl, httpbodyContent, ResponseMessage);

                    ResponseMessage.Content().ReadAs(salesOrderResponse);
                    Clear(jObject1);
                    jObject1.ReadFrom(salesOrderResponse);

                    if isSalesOrderPostCallSuccess then begin
                        if ResponseMessage.IsSuccessStatusCode then begin
                            if ResponseMessage.ReasonPhrase = 'Created' then begin

                                //Sales Lines Cretion from BC to CRM
                                ResponseMessage.Content().ReadAs(salesOrderResponse);
                                Clear(jObject1);
                                jObject1.ReadFrom(salesOrderResponse);
                                jObject1.get('salesorderid', jToken);
                                crmSalesOrderSchemaId := jToken.AsValue().AsText();

                                sline.SetRange("Document Type", sheader."Document Type");
                                sline.SetRange("Document No.", sheader."No.");
                                //sline.Validate("Sell-to Customer No.", sHeader."Sell-to Customer No.");
                                //sline.Validate(Type, sline.Type::Item);
                                sline.FindSet();
                                repeat begin
                                    item.Reset();
                                    item.SetRange("No.", sline."No.");
                                    item.FindFirst();
                                    crmItemSchemaId := item.CrmItemSchemaId;
                                    crmitemuofmid := item.CrmUofmId;
                                    crmitemuofmscheduleid := item.CrmUofmScheduleId;

                                    Clear(jObject2);
                                    jObject2.Add('salesorderid@odata.bind', 'salesorders/' + crmSalesOrderSchemaId);
                                    //jObject2.Add('productid@odata.bind', 'products/ea17d001-7e9f-ec11-b400-000d3a32003b');

                                    productApi := 'products/' + crmItemSchemaId;
                                    jObject2.Add('productid@odata.bind', productApi);

                                    jObject2.Add('description', sline.Description);
                                    jObject2.Add('salesorderdetailname', sline.Description);
                                    jObject2.Add('priceperunit', sline."Unit Price");
                                    jObject2.Add('quantity', sline.Quantity);

                                    uofmApi := 'uoms/' + crmitemuofmid;
                                    //jObject2.Add('uomid@odata.bind', '/uoms(5c5f4f66-b1a7-ec11-983f-000d3a5b777d)');
                                    jObject2.Add('uomid@odata.bind', uofmApi);
                                end until sline.Next() = 0;

                                jObject2.WriteTo(salesLinesInfo);

                                httpbodyContent1.Clear();
                                Clear(RequestHeaders1);
                                httpbodyContent1.WriteFrom(salesLinesInfo);
                                httpbodyContent1.GetHeaders(RequestHeaders1);


                                RequestHeaders1.Remove('Content-Type');
                                RequestHeaders1.Add('Content-Type', 'application/json');
                                RequestHeaders1.Add('Prefer', 'return=representation');

                                Clear(RequestMessage1);
                                RequestMessage1.Method := 'POST';
                                RequestMessage1.SetRequestUri(RequestUrl);
                                RequestMessage1.GetHeaders(RequestHeaders1);
                                RequestMessage1.Content := httpbodyContent1;

                                Client.Clear();
                                Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);

                                RequestUrl := 'https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/salesorderdetails';
                                isSalesOrderLinesPostCallSuccess := Client.Post(RequestUrl, httpbodyContent1, ResponseMessage);

                                helixSalesTable.Init();
                                helixSalesTable.CRMSalesId := bcSalesOrderNo;
                                helixSalesTable.CRMSalesSchemaId := crmSalesOrderSchemaId;
                                helixSalesTable.CRMSalesCustomerId := cust.CrmContactSchemaId;
                                helixSalesTable.BCSalesOrderId := bcSalesOrderNo;
                                helixSalesTable.SalesOrderType := HelixSalesTypes::SalesOrder;
                                helixSalesTable.SalesSyncSource := HelixSyncSource::BC;
                                helixSalesTable.Insert();

                                sheader.SyncStatus := syncStatus::Complete;
                                sheader.Modify(false);

                                Message('Sales Order %1 Created Successfully in Dynamics CRM', sheader."No.");
                            end;
                        end;
                    end;
                end;
            end until sheader.Next() = 0;
        end;



    end;

    /// <summary>
    /// Push Sales Invoices from BC to CRM
    /// </summary>
    /// <param name="RequestUrl">The Request URL.</param>
    /// <param name="AccessToken">The Access Token.</param>
    /// <returns>Returns</returns>
    procedure PushInvoicesFromBC(RequestUrl: Text; AccessToken: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestHeaders1: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        RequestMessage1: HttpRequestMessage;
        httpbodyContent: HttpContent;
        httpbodyContent1: HttpContent;
        JObject: JsonObject;
        ResponseStream: InStream;
        APICallResponseMessage: Text;
        StatusCode: Integer;
        IsSuccessful: Boolean;

        sInvoice: Record "Sales Invoice Header";
        sline: Record "Sales Invoice Line";
        jObject1: JsonObject;
        jArray: JsonArray;
        jToken: JsonToken;
        jToken1: JsonToken;
        jToken2: JsonToken;
        jToken3: JsonToken;
        jValue: JsonValue;
        i: Integer;
        isSalesInvoicePostCallSuccess: Boolean;
        isSalesOrderLinesPostCallSuccess: Boolean;
        salesInvoiceInfo: Text;
        salesLinesInfo: Text;
        cust: Record Customer;
        salesInvoiceResponse: Text;
        salesInvoiceSchemaId: Text;
        jObject2: JsonObject;
        sOrder: Record "Sales Header";
        helixSalesTable: Record HelixSalesTable;
        item: Record Item;
    begin
        sInvoice.Init();
        sInvoice.FindLast();

        helixSalesTable.SetRange(SalesOrderType, helixSalesTable.SalesOrderType::SalesOrder);
        helixSalesTable.SetRange(CRMSalesId, sInvoice."Order No.");
        helixSalesTable.FindFirst();

        //JObject.Add('salesorderid@odata.bind', 'salesorders/' + sOrder."Your Reference");
        JObject.Add('salesorderid@odata.bind', 'salesorders/' + helixSalesTable.CRMSalesSchemaId);
        JObject.Add('customerid_contact@odata.bind', 'contacts/' + helixSalesTable.CRMSalesCustomerId);
        JObject.Add('name', sInvoice."Sell-to Customer Name");
        JObject.Add('billto_line1', sInvoice."Sell-to Address");
        JObject.Add('billto_line2', sInvoice."Sell-to Address 2");
        JObject.Add('billto_city', sInvoice."Sell-to City");
        JObject.Add('billto_stateorprovince', sInvoice."Sell-to County");
        JObject.Add('billto_postalcode', sInvoice."Sell-to Post Code");
        JObject.Add('billto_country', sInvoice."Sell-to Country/Region Code");

        JObject.Add('shipto_line1', sInvoice."Ship-to Address");
        JObject.Add('shipto_line2', sInvoice."Ship-to Address 2");
        JObject.Add('shipto_city', sInvoice."Ship-to City");
        JObject.Add('shipto_stateorprovince', sInvoice."Ship-to County");
        JObject.Add('shipto_postalcode', sInvoice."Ship-to Post Code");
        JObject.Add('shipto_country', sInvoice."Ship-to Country/Region Code");

        JObject.Add('shippingmethodcode', 2);

        jObject.WriteTo(salesInvoiceInfo);

        httpbodyContent.Clear();
        httpbodyContent.WriteFrom(salesInvoiceInfo);
        httpbodyContent.GetHeaders(RequestHeaders);

        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/json');
        RequestHeaders.Add('Prefer', 'return=representation');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(RequestUrl);
        RequestMessage.GetHeaders(RequestHeaders);
        RequestMessage.Content := httpbodyContent;

        Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);

        isSalesInvoicePostCallSuccess := Client.Post(RequestUrl, httpbodyContent, ResponseMessage);

        ResponseMessage.Content().ReadAs(salesInvoiceResponse);
        Clear(jObject1);
        jObject1.ReadFrom(salesInvoiceResponse);

        if isSalesInvoicePostCallSuccess then begin
            if ResponseMessage.IsSuccessStatusCode then begin
                if ResponseMessage.ReasonPhrase = 'Created' then begin

                    //Sales Invoice Lines Creation from BC to CRM
                    ResponseMessage.Content().ReadAs(salesInvoiceResponse);
                    Clear(jObject1);
                    jObject1.ReadFrom(salesInvoiceResponse);
                    jObject1.get('invoiceid', jToken);
                    salesInvoiceSchemaId := jToken.AsValue().AsText();

                    //sline.SetRange("Document Type", sheader."Document Type");
                    sline.Reset();
                    sline.SetRange(sline."Document No.", sInvoice."No.");
                    //sline.Validate("Sell-to Customer No.", sInvoice."Sell-to Customer No.");
                    sline.Validate(sline.Type, sline.Type::Item);
                    sline.SetFilter(Quantity, '>%1', 0);
                    sline.FindSet();
                    repeat begin
                        item.Reset();
                        item.SetRange("No.", sline."No.");
                        item.FindFirst();

                        Clear(jObject2);
                        jObject2.Add('invoiceid@odata.bind', 'invoices/' + salesInvoiceSchemaId);
                        jObject2.Add('productid@odata.bind', 'products/' + item.CrmItemSchemaId);
                        //jObject2.Add('uomid@odata.bind', '/uoms(5c5f4f66-b1a7-ec11-983f-000d3a5b777d)');
                        jObject2.Add('uomid@odata.bind', 'uoms/' + item.CrmUofmId);
                        jObject2.Add('priceperunit', sline."Unit Price");
                        jObject2.Add('quantity', sline.Quantity);
                    end until sline.Next() = 0;

                    jObject2.WriteTo(salesLinesInfo);

                    httpbodyContent1.Clear();
                    httpbodyContent1.WriteFrom(salesLinesInfo);
                    httpbodyContent1.GetHeaders(RequestHeaders1);

                    RequestHeaders1.Remove('Content-Type');
                    RequestHeaders1.Add('Content-Type', 'application/json');
                    RequestHeaders1.Add('Prefer', 'return=representation');

                    RequestMessage1.Method := 'POST';
                    RequestMessage1.SetRequestUri(RequestUrl);
                    RequestMessage1.GetHeaders(RequestHeaders1);
                    RequestMessage1.Content := httpbodyContent1;

                    Client.Clear();
                    Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);

                    RequestUrl := 'https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/invoicedetails';
                    isSalesOrderLinesPostCallSuccess := Client.Post(RequestUrl, httpbodyContent1, ResponseMessage);


                    Message('Sales Invoice %1 Created Successfully in Dynamics CRM', sInvoice."No.");
                end;
            end;
        end;
    end;

    /// <summary>
    /// Push Sales Quottes from BC to CRM
    /// </summary>
    /// <param name="RequestUrl">The Request URL.</param>
    /// <param name="AccessToken">The Access Token.</param>
    /// <returns>Returns</returns>
    procedure PushSalesQuotesFromBC(RequestUrl: Text; AccessToken: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestHeaders1: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        RequestMessage1: HttpRequestMessage;
        httpbodyContent: HttpContent;
        httpbodyContent1: HttpContent;
        JObject: JsonObject;
        ResponseStream: InStream;
        APICallResponseMessage: Text;
        StatusCode: Integer;
        IsSuccessful: Boolean;

        sheader: Record "Sales Header";
        sline: Record "Sales Line";
        jObject1: JsonObject;
        jArray: JsonArray;
        jToken: JsonToken;
        jToken1: JsonToken;
        jToken2: JsonToken;
        jToken3: JsonToken;
        jValue: JsonValue;
        i: Integer;
        isSalesOrderPostCallSuccess: Boolean;
        isSalesOrderLinesPostCallSuccess: Boolean;
        salesOrderInfo: Text;
        salesLinesInfo: Text;
        cust: Record Customer;
        salesOrderResponse: Text;
        crmSalesOrderSchemaId: Text;
        jObject2: JsonObject;
        item: Record Item;
        crmItemSchemaId: Text;
        productApi: Text;
        helixSalesTable: Record HelixSalesTable;
        bcSalesOrderNo: Text;
        crmitemuofmid: Text;
        crmitemuofmscheduleid: Text;
        uofmApi: Text;
    begin
        sheader.Init();
        sheader.SetRange("Document Type", sheader."Document Type"::Quote);
        sheader.FindLast();

        //JObject.Add('ordernumber', Random(9999));
        bcSalesOrderNo := sheader."No.";
        JObject.Add('quotenumber', sheader."No.");
        cust.Reset();
        cust.SetRange("No.", sheader."Sell-to Customer No.");
        cust.FindFirst();
        //JObject.Add('customerid_contact@odata.bind', 'contacts/' + cust."Home Page");
        JObject.Add('customerid_contact@odata.bind', 'contacts/' + cust.CrmContactSchemaId);
        JObject.Add('name', cust.Name);
        JObject.Add('billto_line1', sheader."Sell-to Address");
        JObject.Add('billto_line2', sheader."Sell-to Address 2");
        JObject.Add('billto_city', sheader."Sell-to City");
        JObject.Add('billto_stateorprovince', sheader."Sell-to County");
        JObject.Add('billto_postalcode', sheader."Sell-to Post Code");
        JObject.Add('billto_country', sheader."Sell-to Country/Region Code");

        JObject.Add('shipto_line1', sheader."Ship-to Address");
        JObject.Add('shipto_line2', sheader."Ship-to Address 2");
        JObject.Add('shipto_city', sheader."Ship-to City");
        JObject.Add('shipto_stateorprovince', sheader."Ship-to County");
        JObject.Add('shipto_postalcode', sheader."Ship-to Post Code");
        JObject.Add('shipto_country', sheader."Ship-to Country/Region Code");

        //JObject.Add('shippingmethodcode', 2);

        jObject.WriteTo(salesOrderInfo);

        httpbodyContent.Clear();
        httpbodyContent.WriteFrom(salesOrderInfo);
        httpbodyContent.GetHeaders(RequestHeaders);

        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/json');
        RequestHeaders.Add('Prefer', 'return=representation');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(RequestUrl);
        RequestMessage.GetHeaders(RequestHeaders);
        RequestMessage.Content := httpbodyContent;

        Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);

        isSalesOrderPostCallSuccess := Client.Post(RequestUrl, httpbodyContent, ResponseMessage);

        ResponseMessage.Content().ReadAs(salesOrderResponse);
        Clear(jObject1);
        jObject1.ReadFrom(salesOrderResponse);

        if isSalesOrderPostCallSuccess then begin
            if ResponseMessage.IsSuccessStatusCode then begin
                if ResponseMessage.ReasonPhrase = 'Created' then begin

                    //Sales Lines Cretion from BC to CRM
                    ResponseMessage.Content().ReadAs(salesOrderResponse);
                    Clear(jObject1);
                    jObject1.ReadFrom(salesOrderResponse);
                    jObject1.get('quoteid', jToken);
                    crmSalesOrderSchemaId := jToken.AsValue().AsText();

                    sline.SetRange("Document Type", sheader."Document Type"::Quote);
                    //sline.SetRange("Document No.", sheader."No.");
                    sline.Validate("Document No.", sheader."No.");
                    sline.SetRange("Document No.", sheader."No.");
                    sline.Validate("Sell-to Customer No.", sHeader."Sell-to Customer No.");
                    sline.Validate(Type, sline.Type::Item);
                    sline.FindSet();
                    repeat begin
                        item.Reset();
                        item.SetRange("No.", sline."No.");
                        item.FindFirst();
                        crmItemSchemaId := item.CrmItemSchemaId;
                        crmitemuofmid := item.CrmUofmId;
                        crmitemuofmscheduleid := item.CrmUofmScheduleId;

                        Clear(jObject2);
                        jObject2.Add('quoteid@odata.bind', 'quotes/' + crmSalesOrderSchemaId);
                        //jObject2.Add('productid@odata.bind', 'products/ea17d001-7e9f-ec11-b400-000d3a32003b');

                        productApi := 'products/' + crmItemSchemaId;
                        jObject2.Add('productid@odata.bind', productApi);

                        jObject2.Add('description', sline.Description);
                        jObject2.Add('quotedetailname', sline.Description);
                        jObject2.Add('priceperunit', sline."Unit Price");
                        jObject2.Add('quantity', sline.Quantity);

                        uofmApi := 'uoms/' + crmitemuofmid;
                        //jObject2.Add('uomid@odata.bind', '/uoms(5c5f4f66-b1a7-ec11-983f-000d3a5b777d)');
                        jObject2.Add('uomid@odata.bind', uofmApi);
                    end until sline.Next() = 0;

                    jObject2.WriteTo(salesLinesInfo);

                    httpbodyContent1.Clear();
                    httpbodyContent1.WriteFrom(salesLinesInfo);
                    httpbodyContent1.GetHeaders(RequestHeaders1);

                    RequestHeaders1.Remove('Content-Type');
                    RequestHeaders1.Add('Content-Type', 'application/json');
                    RequestHeaders1.Add('Prefer', 'return=representation');

                    RequestMessage1.Method := 'POST';
                    RequestMessage1.SetRequestUri(RequestUrl);
                    RequestMessage1.GetHeaders(RequestHeaders1);
                    RequestMessage1.Content := httpbodyContent1;

                    Client.Clear();
                    Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);

                    RequestUrl := 'https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/quotedetails';
                    isSalesOrderLinesPostCallSuccess := Client.Post(RequestUrl, httpbodyContent1, ResponseMessage);

                    helixSalesTable.Init();
                    helixSalesTable.CRMSalesId := bcSalesOrderNo;
                    helixSalesTable.CRMSalesSchemaId := crmSalesOrderSchemaId;
                    helixSalesTable.CRMSalesCustomerId := cust.CrmContactSchemaId;
                    helixSalesTable.BCSalesOrderId := bcSalesOrderNo;
                    helixSalesTable.SalesOrderType := HelixSalesTypes::SalesQuote;
                    helixSalesTable.SalesSyncSource := HelixSyncSource::BC;
                    helixSalesTable.Insert();

                    Message('Sales Quote %1 Created Successfully in Dynamics CRM', sheader."No.");
                end;
            end;
        end;
    end;

    #endregion

}