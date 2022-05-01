pageextension 50106 HelixSalesQuoteExtension extends "Sales Quote"
{
    layout
    {
        addafter("Foreign Trade")
        {
            group(Helix)
            {
                field(SyncStatus; rec.SyncStatus)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}