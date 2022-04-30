pageextension 50102 HelixCustomerCardExtension extends "Customer Card"
{
    layout
    {
        addafter(Statistics)
        {
            group(Helix)
            {
                field(CrmContactSchemaId; rec.CrmContactSchemaId)
                {
                    ApplicationArea = All;
                }
                field(SyncSource; rec.SyncSource)
                {
                    ApplicationArea = All;
                }
                field(SyncStatus; rec.SyncStatus)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}