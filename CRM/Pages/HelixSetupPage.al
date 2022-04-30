page 50105 HelixSetupPage
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = HelixSetupTable;
    //InsertAllowed = false;
    //DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(BaseURl; Rec.APIBaseURL)
                {
                    ApplicationArea = All;
                }
                field(AccessToken; Rec.AccessToken)
                {
                    ApplicationArea = All;
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