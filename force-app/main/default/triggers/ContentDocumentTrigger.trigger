trigger ContentDocumentTrigger on ContentDocument(before delete) {
    if (Trigger.isbefore && Trigger.isdelete) {
        AttachmentsHelper.updateAccountsSOW(Trigger.old);
    }
}