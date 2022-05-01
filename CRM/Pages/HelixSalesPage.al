page 50106 HelixSalesPage
{
    Caption = 'Helix Sales Relation Page';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = HelixSalesTable;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(SalesOrderType; Rec.SalesOrderType)
                {
                    ApplicationArea = All;
                }
                field(SalesSyncSource; Rec.SalesSyncSource)
                {
                    ApplicationArea = All;
                }
                field(CRMSalesId; Rec.CRMSalesId)
                {
                    ApplicationArea = All;
                }
                field(BCSalesOrderId; Rec.BCSalesOrderId)
                {
                    ApplicationArea = All;
                }
                field(CRMSalesCustomerId; Rec.CRMSalesCustomerId)
                {
                    ApplicationArea = All;
                }
                field(CRMSalesSchemaId; Rec.CRMSalesSchemaId)
                {
                    ApplicationArea = All;

                }
            }
        }
    }
}