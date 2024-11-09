public inherited sharing class ContentDocumentLinkSelector {
    public ContentDocumentLinkSelector() {
    }
    public List<ContentDocumentLink> getByDocumentId(Set<Id> documentIds) {
        return [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :documentIds
        ];
    }

    public List<ContentDocumentLink> getByEntityId(Set<Id> linkedEntityIds) {
        if (linkedEntityIds.isEmpty()) {
            return new List<ContentDocumentLink>();
        }
        return [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :linkedEntityIds
        ];
    }
}