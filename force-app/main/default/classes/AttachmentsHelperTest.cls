@isTest
private class AttachmentsHelperTest {
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

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink documentLink = new ContentDocumentLink();
        documentLink.ContentDocumentId = cv.ContentDocumentId;
        documentLink.LinkedEntityId = testAccount.Id;
        documentLink.ShareType = 'V';
        insert documentLink;
    }

    @isTest
    static void testUpdateAccountsSOW() {
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion];
        List<ContentDocumentLink> links = [
            SELECT Id, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :cv.Id
        ];

        Test.startTest();
        AttachmentsHelper.updateAccountsSOW(links);
        Test.stopTest();

        Account testAccount = [SELECT Id, SOW_Count__c FROM Account];
        Assert.areEqual(1, testAccount.SOW_Count__c, 'SOW Count should be updated to 1');
    }

    @isTest
    static void testUpdateAccountsSOWContentDocuments() {
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion];
        ContentDocument cd = new ContentDocument(Id = cv.ContentDocumentId);
        Test.startTest();
        AttachmentsHelper.updateAccountsSOW(new List<ContentDocument>{cd});
        Test.stopTest();

        Account testAccount = [SELECT Id, SOW_Count__c FROM Account];
        Assert.areEqual(0, testAccount.SOW_Count__c, 'SOW Count should be updated to 0');
    }
}