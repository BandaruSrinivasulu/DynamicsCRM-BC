pageextension 50104 HelixSalesHeaderExtension extends "Sales Order"
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