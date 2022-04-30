// page 50101 CustomCues
// {
//     PageType = CardPart;
//     SourceTable = Customer;

//     layout
//     {
//         area(Content)
//         {
//             // Display data as cue tiles
//             cuegroup(Overview)
//             {
//                 CuegroupLayout = Wide;

//                 field("No. of Quotes"; Rec."No. of Quotes")
//                 {
//                     ApplicationArea = All;
//                     // Make the cue interactive
//                     DrillDownPageID = "Sales Quotes";
//                     AboutText = 'Number of Quotes';
//                     AboutTitle = 'Title for the Quotes';
//                 }
//                 field("No. of Orders"; Rec."No. of Orders")
//                 {
//                     ApplicationArea = All;
//                     DrillDownPageID = "Sales Order List";
//                     AboutText = 'Number of Orders';
//                     AboutTitle = 'Title for the Orders';
//                 }
//                 field("No. of Invoices"; Rec."No. of Invoices")
//                 {
//                     ApplicationArea = All;
//                     DrillDownPageID = "Sales Invoice List";
//                     AboutText = 'Number of Invoices';
//                     AboutTitle = 'Title for the Invoices';
//                 }

//                 actions
//                 {
//                     action(Action1)
//                     {
//                         Image = TileBlue;
//                         RunObject = page "Customer Card";
//                         ApplicationArea = Alll;
//                         trigger OnAction()
//                         begin

//                         end;
//                     }
//                     action(Action2)
//                     {
//                         Image = TileCloud;
//                         RunObject = page "Item Card";
//                         ApplicationArea = Alll;

//                         trigger OnAction()
//                         begin

//                         end;
//                     }
//                 }
//             }

//             field(Field1; Rec."No.")
//             {
//                 ApplicationArea = all;
//             }
//             field(Field2; Rec.Name)
//             {
//                 ApplicationArea = all;
//             }
//         }
//     }
// }
// page 50102 "WorkingOnCardPageParts"
// {
//     PageType = Card;
//     SourceTable = Customer;
//     UsageCategory = Administration;
//     ApplicationArea = All;

//     layout
//     {
//         area(Content)
//         {
//             group(General)
//             {
//                 field("No."; Rec."No.")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(Name; Rec.Name)
//                 {
//                     ApplicationArea = All;
//                 }

//             }
//         }

//         // Display the card part in the Factbox area
//         area(FactBoxes)
//         {
//             part("Customer Sales History"; CustomCues)
//             {
//                 ApplicationArea = All;
//                 // Filter on the sales history that relate to the customer in the card page.
//                 SubPageLink = "No." = FIELD("No.");
//             }
//         }
//     }
// }