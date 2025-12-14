public with sharing class LeadRoutingService {
    public static void applyDefaults(List<Lead> newList, Map<Id, Lead> oldMap) {
        for (Lead l : newList) {
            Boolean isInsert = (oldMap == null);
            Boolean statusChanged = !isInsert && oldMap.containsKey(l.Id) && oldMap.get(l.Id).Status != l.Status;

            if (isInsert || statusChanged) {
                if (String.isBlank(l.Status)) {
                    l.Status = 'New';
                }
            }
        }
    }
}
