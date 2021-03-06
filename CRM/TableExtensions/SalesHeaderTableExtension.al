tableextension 50104 HelixSalesHeaderTableExt extends "Sales Header"
{
    fields
    {
        field(50110; SyncStatus; Enum HelixEntitySyncStatus)
        {
            DataClassification = ToBeClassified;
        }
    }

    trigger OnAfterModify()
    begin
        Rec.SyncStatus := HelixEntitySyncStatus::Pending;
        rec.Modify(false);
    end;
}