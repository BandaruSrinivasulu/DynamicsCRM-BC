table 50101 HelixSalesTable
{
    DataClassification = ToBeClassified;
    Caption = 'Helix Sales Order Relation Table';

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; SalesOrderType; Enum HelixSalesTypes)
        {
            DataClassification = ToBeClassified;
        }
        field(3; CRMSalesId; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; CRMSalesSchemaId; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; CRMSalesCustomerId; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; BCSalesOrderId; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; CRMSalesOtherId1; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; CRMSalesOtherId2; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; CRMSalesOtherId3; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(10; SalesSyncSource; Enum HelixSyncSource)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}