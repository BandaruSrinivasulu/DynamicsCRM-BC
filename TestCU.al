// codeunit 50100 MyCodeunit
// {
//     trigger OnRun()
//     var
//         itm: Record Item;
//         isModified: Boolean;
//     begin
//         itm.FindFirst();
//         itm."Lot Size" := 10.25;
//         isModified := itm.Modify(false);
//     end;

//     var
//         myInt: Integer;
// }

// pageextension 50101 MyExtension extends "Customer List"
// {
//     layout
//     {
//         // Add changes to page layout here
//     }

//     actions
//     {
//         // Add changes to page actions here
//     }

//     trigger OnOpenPage()
//     var
//         itm: Record Item;
//         isModified: Boolean;
//     begin
//         itm.FindFirst();
//         itm."Lot Size" := 10.25;
//         isModified := itm.Modify(false);
//     end;
// }

codeunit 50120 SpecialCharsTest
{
    trigger OnRun()
    var
        itm: Record Item;
        res: Boolean;
    begin
        // Clear(itm);
        // //itm.SetRange("No.", 'ITEM(ONE');
        // res := itm.Get('ITEM(ONE');
        // itm.SetFilter("No.", 'ITEM(ONE');
        // if itm.FindFirst() then begin
        //     Message('Item Reading is done');
        // end;
    end;

    [TryFunction]
    procedure ReadProducts()
    var
        itm: Record Item;
        res: Boolean;
    begin
        Clear(itm);
        //itm.SetRange("No.", 'ITEM(ONE');
        res := itm.Get('ITEM(ONE');
        itm.SetFilter("No.", 'ITEM(ONE');
        if itm.FindFirst() then begin
            Message('Item Reading is done');
        end;
    end;
}