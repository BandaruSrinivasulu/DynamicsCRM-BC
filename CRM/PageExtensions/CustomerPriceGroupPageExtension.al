pageextension 50105 HelixCustPriceGroupPageExt extends "Customer Price Groups"
{
    layout
    {
        addafter("VAT Bus. Posting Gr. (Price)")
        {
            field(SyncStatus; rec.SyncStatus)
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}