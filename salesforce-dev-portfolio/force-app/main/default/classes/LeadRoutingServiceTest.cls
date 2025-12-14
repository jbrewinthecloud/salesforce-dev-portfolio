@IsTest
private class LeadRoutingServiceTest {

    @IsTest
    static void insert_setsStatusAndLeadSource_andStampsNotes() {
        Lead l = new Lead(
            LastName = 'Test',
            Company = 'JB Consulting',
            Status = null,
            LeadSource = null,
            Phone = '210-555-1234'
        );

        insert l;

        Lead inserted = [
            SELECT Status, LeadSource, Phone, Routing_Notes__c
            FROM Lead
            WHERE Id = :l.Id
        ];

        System.assertEquals('New', inserted.Status, 'Status should default to New on insert');
        System.assertEquals('Web', inserted.LeadSource, 'LeadSource should default to Web when blank');
        System.assertEquals('(210) 555-1234', inserted.Phone, 'Phone should normalize to (XXX) XXX-XXXX');
        System.assertNotEquals(null, inserted.Routing_Notes__c, 'Routing notes should be stamped');
        System.assert(inserted.Routing_Notes__c.contains('Status set to New'), 'Notes should mention status change');
        System.assert(inserted.Routing_Notes__c.contains('Lead Source set to Web'), 'Notes should mention lead source change');
        System.assert(inserted.Routing_Notes__c.contains('Phone normalized'), 'Notes should mention phone normalization');
    }

    @IsTest
    static void update_setsLeadSource_ifBlank_andUpdatesNotes() {
        Lead l = new Lead(
            LastName = 'Test2',
            Company = 'JB Consulting',
            Status = 'New',
            LeadSource = 'Referral',
            Phone = '(210)5551234'
        );
        insert l;

        // Clear LeadSource to force default on update
        l.LeadSource = null;
        update l;

        Lead updated = [
            SELECT Status, LeadSource, Phone, Routing_Notes__c
            FROM Lead
            WHERE Id = :l.Id
        ];

        System.assertEquals('New', updated.Status, 'Status should not be changed on update by our logic');
        System.assertEquals('Web', updated.LeadSource, 'LeadSource should default to Web on update when blank');
        System.assertEquals('(210) 555-1234', updated.Phone, 'Phone should be normalized');
        System.assert(updated.Routing_Notes__c.contains('Update'), 'Notes should show update prefix');
    }

    @IsTest
    static void bulk_insert_200_isSafe() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            leads.add(new Lead(
                LastName = 'Bulk' + i,
                Company = 'JB Consulting',
                Phone = '210555' + String.valueOf(1000 + i)
            ));
        }

        insert leads;

        // Spot check a couple
        Lead sample = [SELECT LeadSource, Phone, Routing_Notes__c FROM Lead WHERE Id = :leads[0].Id];
        System.assertEquals('Web', sample.LeadSource);
        System.assertNotEquals(null, sample.Routing_Notes__c);
    }
}
