trigger LeadRoutingTrigger on Lead (before insert, before update) {
    LeadRoutingService.applyDefaults(Trigger.new, Trigger.isInsert ? null : Trigger.oldMap);
}