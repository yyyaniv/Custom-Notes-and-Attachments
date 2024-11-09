@isTest
private class AttachmentsControllerTest {
    @TestSetup
    static void testSetup() {
        Account testAccount = new Account(Name = 'Test Account', SOW_Count__c = 0);
        insert testAccount;

        ContentVersion cv = new ContentVersion(
            Title = 'SOW Document',
            VersionData = Blob.valueOf('Test SOW Content'),
            PathOnClient = 'sow.pdf',
            Type__c = 'SOW'
        );
        insert cv;

        ContentVersion cv2 = new ContentVersion(
            Title = 'SOW Document2',
            VersionData = Blob.valueOf('Test SOW Content'),
            PathOnClient = 'sow.pdf',
            Type__c = 'SOW'
        );
        insert cv2;

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink documentLink = new ContentDocumentLink();
        documentLink.ContentDocumentId = cv.ContentDocumentId;
        documentLink.LinkedEntityId = testAccount.Id;
        documentLink.ShareType = 'V';
        insert documentLink;
    }

    @isTest
    static void testGetRelatedAttachments() {
        Account testAccount = [SELECT Id, SOW_Count__c FROM Account];

        Test.startTest();
        List<ContentVersion> contentVersionList = AttachmentsController.getRelatedAttachments(testAccount.Id);
        Test.stopTest();

        Assert.areEqual(1, contentVersionList.size(), 'Expected 1 to be returned');
    }

    @isTest
    static void testCreateContentLink() {
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title='SOW Document2'];
        Account testAccount = [SELECT Id, SOW_Count__c FROM Account];
        Test.startTest();
        ContentDocumentLink documentLink = AttachmentsController.createContentLink(cv.Id, testAccount.Id);
        Test.stopTest();
        Assert.isNotNull(documentLink, 'Expected value to be returned');
    }

    @isTest
    static void testCreateContentLinkNull() {
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title='SOW Document2'];
        Test.startTest();
        ContentDocumentLink documentLink = AttachmentsController.createContentLink(cv.Id, null);
        Test.stopTest();
        Assert.isNull(documentLink, 'Expected null to be returned');
    }
}