tableextension 50102 HelixCustomerTableExt extends Customer
{
    fields
    {
        field(50100; CrmContactSchemaId; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50101; CrmOtherId1; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50102; CrmOtherId2; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50103; SyncSource; Enum HelixSyncSource)
        {
            DataClassification = ToBeClassified;
        }

        field(50110; SyncStatus; Enum HelixEntitySyncStatus)
        {
            DataClassification = ToBeClassified;
        }
    }

    trigger OnAfterModify()
    begin
        //if Rec.SyncStatus <> HelixEntitySyncStatus::Complete then begin
        SyncStatus := HelixEntitySyncStatus::Pending;
        Rec.Modify(false);
        //end;
    end;
}