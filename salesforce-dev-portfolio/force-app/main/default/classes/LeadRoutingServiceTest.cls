@IsTest
private class LeadRoutingServiceTest {

    @IsTest
    static void setsStatusToNew_whenBlank_onInsert() {
        Lead l = new Lead(LastName = 'Test', Company = 'JB Consulting');
        insert l;

        Lead inserted = [SELECT Status FROM Lead WHERE Id = :l.Id];
        System.assertEquals('New', inserted.Status, 'Status should default to New when blank');
    }

    @IsTest
    static void doesNotOverride_whenStatusProvided_onInsert() {
        Lead l = new Lead(LastName = 'Test2', Company = 'JB Consulting', Status = 'Working - Contacted');
        insert l;

        Lead inserted = [SELECT Status FROM Lead WHERE Id = :l.Id];
        System.assertEquals('Working - Contacted', inserted.Status, 'Should not override a provided Status');
    }

    @IsTest
    static void setsStatusToNew_whenCleared_onUpdate() {
        Lead l = new Lead(LastName = 'Test3', Company = 'JB Consulting', Status = 'Working - Contacted');
        insert l;

        l.Status = null;
        update l;

        Lead updated = [SELECT Status FROM Lead WHERE Id = :l.Id];
        System.assertEquals('New', updated.Status, 'Status should revert to New when cleared');
    }
}
