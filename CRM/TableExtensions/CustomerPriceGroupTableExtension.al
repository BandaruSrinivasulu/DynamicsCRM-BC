tableextension 50105 HelixCustPriceGroupTableExt extends "Customer Price Group"
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
        SyncStatus := HelixEntitySyncStatus::Pending;
    end;

    trigger OnAfterInsert()
    begin
        SyncStatus := HelixEntitySyncStatus::Pending;
    end;

    trigger OnAfterRename()
    begin
        SyncStatus := HelixEntitySyncStatus::Pending;
    end;
}