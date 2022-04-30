codeunit 50104 HelixJobQueue
{
    trigger OnRun()
    var
        apiCalls: Codeunit APICalls;
        helixSetup: Record HelixSetupTable;
    begin
        if helixSetup.FindFirst() then begin
            apiCalls.PushCustomersFromBC('https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/contacts/', helixSetup.AccessToken);
            apiCalls.PushProductsFromBC('https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/products/', helixSetup.AccessToken);
            APICalls.PushSalesOrdersFromBC('https://org6a8b2e1b.crm.dynamics.com/api/data/v8.1/salesorders/', helixSetup.AccessToken)
        end;
    end;
}