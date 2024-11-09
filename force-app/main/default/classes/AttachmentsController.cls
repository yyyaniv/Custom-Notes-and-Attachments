public with sharing class AttachmentsController {
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getRelatedAttachments(String recordId) {
        try {
            List<ContentDocumentLink> contentDocumentList = new ContentDocumentLinkSelector()
                .getByEntityId(new Set<Id>{ recordId });
            Set<Id> documentIds = new Set<Id>();

            for (ContentDocumentLink cdl : contentDocumentList) {
                documentIds.add(cdl.ContentDocumentId);
            }

            List<ContentVersion> contentVersionList = new ContentVersionSelector().getByDocumentsId(documentIds);
            return contentVersionList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) {
            return null;
        }
        ContentDocumentLink documentLink = new ContentDocumentLink();
        documentLink.ContentDocumentId = new ContentVersionSelector()
            .getByIds(new Set<Id>{ contentVersionId })
            ?.get(0)
            ?.ContentDocumentId;
        documentLink.LinkedEntityId = recordId;
        documentLink.ShareType = 'V';
        try {
            insert documentLink;
            return documentLink;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}