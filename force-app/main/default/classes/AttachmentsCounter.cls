public with sharing class AttachmentsCounter {
    private SObjectType sobjectTypeToUpdate;
    private SObjectField sobjectFieldToUpdate;

    private Map<Id, ContentDocumentLink> documentLinkByDocumentId;
    private Map<Id, ContentVersion> documentVersionByDocumentId;
    private Map<Id, Integer> documentsCountByEntity = new Map<Id, Integer>();
    private Set<Id> documentsIdsToExclude = new Set<Id>();
    private Set<Id> linkedEntityIds = new Set<Id>();

    public AttachmentsCounter(
        SObjectType sobjectTypeToUpdate,
        SObjectField sobjectFieldToUpdate,
        List<ContentDocumentLink> documentLinks
    ) {
        this.sobjectTypeToUpdate = sobjectTypeToUpdate;
        this.sobjectFieldToUpdate = sobjectFieldToUpdate;
        setDocumentLinkByDocumentId(documentLinks);
    }

    public AttachmentsCounter(
        SObjectType sobjectTypeToUpdate,
        SObjectField sobjectFieldToUpdate,
        List<ContentDocumentLink> documentLinks,
        List<ContentDocument> documentsToExclude
    ) {
        this(sobjectTypeToUpdate, sobjectFieldToUpdate, documentLinks);

        Map<Id, ContentDocument> documents = new Map<Id, ContentDocument>(documentsToExclude);
        documentsIdsToExclude.addAll(documents.keySet());
    }

    private void setDocumentLinkByDocumentId(List<ContentDocumentLink> documentLinks) {
        Map<Id, ContentDocumentLink> documentLinkByDocumentId = new Map<Id, ContentDocumentLink>();

        for (ContentDocumentLink documentLink : documentLinks) {
            if (this.isSameType(documentLink.LinkedEntityId)) {
                documentLinkByDocumentId.put(documentLink.ContentDocumentId, documentLink);
            }
        }
        this.documentLinkByDocumentId = documentLinkByDocumentId;
    }

    private Boolean isSameType(Id recordId) {
        return this.sobjectTypeToUpdate == recordId?.getSobjectType();
    }

    public void updateRelatedRecords(Set<String> documentTypes) {
        addLinkedEntityIds();
        setDocumentLinkByDocumentId(new ContentDocumentLinkSelector().getByEntityId(this.linkedEntityIds));
        setDocumentVersionsByDocumentId(documentTypes);
        setDocumentsCountByEntity();
        updateRelatedRecords();
    }

    private void setDocumentVersionsByDocumentId(Set<String> documentTypes) {
        List<ContentVersion> documentVersions = new ContentVersionSelector()
            .getByDocumentsIdAndTypes(this.documentLinkByDocumentId.keySet(), documentTypes);
        Map<Id, ContentVersion> documentVersionByContentDocumentId = new Map<Id, ContentVersion>();
        for (ContentVersion documentVersion : documentVersions) {
            documentVersionByContentDocumentId.put(documentVersion.ContentDocumentId, documentVersion);
        }
        this.documentVersionByDocumentId = documentVersionByContentDocumentId;
    }

    private void addLinkedEntityIds() {
        for (Id documentId : documentLinkByDocumentId.keySet()) {
            Id entityId = documentLinkByDocumentId.get(documentId)?.LinkedEntityId;
            this.linkedEntityIds.add(entityId);
        }
    }

    private void setDocumentsCountByEntity() {
        for (Id documentId : documentLinkByDocumentId.keySet()) {
            Id entityId = documentLinkByDocumentId.get(documentId)?.LinkedEntityId;
            if (!this.documentsCountByEntity.containsKey(entityId)) {
                this.documentsCountByEntity.put(entityId, 0);
            }
            if (documentVersionByDocumentId.containsKey(documentId) && !this.documentsIdsToExclude.contains(documentId)) {
                this.documentsCountByEntity.put(entityId, documentsCountByEntity.get(entityId) + 1);
            }
        }
    }

    private void updateRelatedRecords() {
        List<SObject> relatedSObjects = new List<SObject>();
        for (Id sobjectId : this.documentsCountByEntity.keySet()) {
            SObject relatedSObject = this.sobjectTypeToUpdate.newSObject(sobjectId);
            relatedSObject.put(this.sobjectFieldToUpdate, this.documentsCountByEntity.get(sobjectId));
            relatedSObjects.add(relatedSObject);
        }
        update relatedSObjects;
    }
}