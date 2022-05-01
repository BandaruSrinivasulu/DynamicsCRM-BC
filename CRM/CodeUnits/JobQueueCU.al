codeunit 50104 HelixJobQueue
{
    trigger OnRun()
    var
        apiCalls: Codeunit APICalls;
        helixSetup: Record HelixSetupTable;
    begin
        if helixSetup.FindFirst() then begin
            apiCalls.PushCustomersFromBC('https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/contacts/', helixSetup.AccessToken);
            Sleep(5000);
            apiCalls.PushProductsFromBC('https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/products/', helixSetup.AccessToken);
            Sleep(5000);
            APICalls.PushSalesOrdersFromBC('https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/salesorders/', helixSetup.AccessToken);
            Sleep(5000);
            APICalls.PushSalesQuotesFromBC('https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/quotes/', helixSetup.AccessToken);
        end;
    end;
}