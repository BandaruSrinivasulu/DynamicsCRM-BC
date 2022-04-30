pageextension 50103 HelixItemCardExtension extends "Item Card"
{
    layout
    {

        addafter(Warehouse)
        {
            group(Helix)
            {
                field(CrmItemSchemaId; rec.CrmItemSchemaId)
                {
                    ApplicationArea = All;
                }

                field(CrmUofmId; rec.CrmUofmId)
                {
                    ApplicationArea = All;
                }

                field(CrmUofmScheduleId; rec.CrmUofmScheduleId)
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