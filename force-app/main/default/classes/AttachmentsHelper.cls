public inherited sharing class AttachmentsHelper {
    public static void updateAccountsSOW(List<ContentDocumentLink> documentLinks) {
        new AttachmentsCounter(Schema.Account.SObjectType, Schema.Account.SOW_Count__c, documentLinks)
            .updateRelatedRecords(new Set<String>{ 'SOW' });
    }

    public static void updateAccountsSOW(List<ContentDocument> documentsToExclude) {
        Map<Id, ContentDocument> documentsToExcludeMap = new Map<Id, ContentDocument>(documentsToExclude);
        List<ContentDocumentLink> documentLinks = new ContentDocumentLinkSelector()
            .getByDocumentId(documentsToExcludeMap.keySet());
        new AttachmentsCounter(
                Schema.Account.SObjectType,
                Schema.Account.SOW_Count__c,
                documentLinks,
                documentsToExclude
            )
            .updateRelatedRecords(new Set<String>{ 'SOW' });
    }
}