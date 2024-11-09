public inherited sharing class ContentVersionSelector {
    public ContentVersionSelector() {
    }

    public List<ContentVersion> getByIds(Set<Id> ids) {
        return [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :ids
        ];
    }

    public List<ContentVersion> getByDocumentsId(Set<Id> documentIds) {
        return [
            SELECT Id, Type__c, Title, FileExtension, ContentSize, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :documentIds AND IsLatest = TRUE
            ORDER BY CreatedDate DESC
        ];
    }

    public List<ContentVersion> getByDocumentsIdAndTypes(Set<Id> documentIds, Set<String> types) {
        return [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :documentIds AND isLatest = TRUE AND Type__c IN :types
        ];
    }
}