@isTest
private class LeadShareManagerTest {

    @testSetup
    static void setupTestData() {
        
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Usuário Nortis e Vibra' LIMIT 1];

        User sdrUser = new User(
            FirstName = 'SDR',
            LastName = 'User',
            Username = 'sdr.user@test.com',
            Email = 'sdr.user@test.com',
            Alias = 'sdrusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = userProfile.Id,
            TipoUsuario__c = 'SDR'
        );
        insert sdrUser;

        User ownerUser = new User(
            FirstName = 'Owner',
            LastName = 'User',
            Username = 'owner.user@test.com',
            Email = 'owner.user@test.com',
            Alias = 'ownerusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = userProfile.Id
        );
        insert ownerUser;
        
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'lead@test.com',
            Company = 'Test Company',
            OwnerId = ownerUser.Id
        );
        insert testLead;
    }

    @isTest
    static void testManageLeadSharing() {
       
        Lead testLead = [SELECT Id, OwnerId FROM Lead LIMIT 1];
        User sdrUser = [SELECT Id FROM User WHERE TipoUsuario__c = 'SDR' LIMIT 1];
        Map<Id, Lead> oldLeadMap = new Map<Id, Lead> { testLead.Id => testLead };

        testLead.OwnerId = sdrUser.Id;
        update testLead;

        Test.startTest();
        LeadShareManager.manageLeadSharing(new List<Lead>{testLead}, oldLeadMap);
        Test.stopTest();
    }

    @isTest
    static void testUpdateSDROwnerField() {
        Lead testLead = [SELECT Id, OwnerId, SDRProprietario__c FROM Lead LIMIT 1];
        User sdrUser = [SELECT Id FROM User WHERE TipoUsuario__c = 'SDR' LIMIT 1];

        Map<Id, Lead> oldLeadMap = new Map<Id, Lead> { testLead.Id => testLead };
        testLead.OwnerId = sdrUser.Id;

        Test.startTest();
        LeadShareManager.updateSDROwnerField(new List<Lead>{testLead}, oldLeadMap);
        Test.stopTest();

    }

    @isTest
    static void testNoSharingIfOwnerUnchanged() {
        Lead testLead = [SELECT Id, OwnerId FROM Lead LIMIT 1];
        Map<Id, Lead> oldLeadMap = new Map<Id, Lead> { testLead.Id => testLead };

        Test.startTest();
        LeadShareManager.manageLeadSharing(new List<Lead>{testLead}, oldLeadMap);
        Test.stopTest();

    }
}