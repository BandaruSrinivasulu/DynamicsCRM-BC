page 50104 HelixAPIConfiguration
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = HelixAPiConfigurationTable;
    Caption = 'Helix API Configuration';

    layout
    {
        area(Content)
        {
            repeater("Helix API Configuration")
            {
                field(APIName; Rec.APIName)
                {
                    ApplicationArea = All;
                    Caption = 'API Name';
                }
                field(APIURL; Rec.APIURL)
                {
                    ApplicationArea = All;
                    Caption = 'API URL';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }
}