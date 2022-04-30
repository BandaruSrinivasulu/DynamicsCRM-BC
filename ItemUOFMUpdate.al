codeunit 50100 ItemUOFMUpdate
{
    trigger OnRun()
    var
        itm: Record Item;
        cust: Record Customer;
        custGroup: Text[20];
        custGroup1: Text[20];
        itmResult: Boolean;
        crmOrder: Record "CRM Salesorder";
        crmOrderDetails: Record "CRM Salesorderdetail";
    begin
        itm.SetRange("Base Unit of Measure", 'PCS');
        itm.FindFirst();
        itm.Validate("Base Unit of Measure", 'PCS');
        itmResult := itm.Modify(false);

        custGroup := 'Hello Worldss';
        if StrLen(custGroup) > 10 then begin
            custGroup := CopyStr(custGroup, 1, 10);
        end;
        cust.Validate("Customer Price Group", custGroup);
    end;
}

pageextension 50100 CustPageExtension extends "Customer List"
{
    trigger OnOpenPage()
    var
        testCU: Codeunit ItemUOFMUpdate;
    begin
        testCU.Run();
    end;
}

table 50100 MyTable
{
    DataClassification = ToBeClassified;
    TableType = CRM;

    fields
    {
        field(1; MyField; Integer)
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(Key1; MyField)
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