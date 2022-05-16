tableextension 50103 HelixItemTableExt extends Item
{
    fields
    {
        field(50100; CrmItemSchemaId; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50101; CrmUofmId; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50102; CrmUofmScheduleId; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50103; CrmOtherId1; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50104; CrmOtherId2; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(50105; SyncSource; Enum HelixSyncSource)
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
        //end;
    end;
}