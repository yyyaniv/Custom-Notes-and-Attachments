trigger ContentDocumentLinkTrigger on ContentDocumentLink(after insert, after update, after delete) {
    if (Trigger.isafter && (Trigger.isupdate || Trigger.isinsert)) {
        AttachmentsHelper.updateAccountsSOW(Trigger.new);
    }
    if (Trigger.isafter && Trigger.isdelete) {
        AttachmentsHelper.updateAccountsSOW(Trigger.old);
    }

}