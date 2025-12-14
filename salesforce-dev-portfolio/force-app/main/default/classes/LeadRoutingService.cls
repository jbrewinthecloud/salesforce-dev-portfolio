public with sharing class LeadRoutingService {

    // Change these defaults per org if needed.
    public static final String DEFAULT_LEAD_STATUS = 'New';
    public static final String DEFAULT_LEAD_SOURCE = 'Web';

    public static void applyDefaults(List<Lead> newList, Map<Id, Lead> oldMap) {
        Boolean isInsert = (oldMap == null);

        for (Lead l : newList) {
            List<String> changes = new List<String>();

            // 1) INSERT ONLY: default Status if blank
            if (isInsert && String.isBlank(l.Status)) {
                l.Status = DEFAULT_LEAD_STATUS;
                changes.add('Status set to ' + DEFAULT_LEAD_STATUS);
            }

            // 2) INSERT + UPDATE: default LeadSource if blank
            if (String.isBlank(l.LeadSource)) {
                l.LeadSource = DEFAULT_LEAD_SOURCE;
                changes.add('Lead Source set to ' + DEFAULT_LEAD_SOURCE);
            }

            // 3) INSERT + UPDATE: normalize phone
            if (!String.isBlank(l.Phone)) {
                String normalized = normalizePhone(l.Phone);
                if (normalized != l.Phone) {
                    l.Phone = normalized;
                    changes.add('Phone normalized');
                }
            }

            // 4) Stamp Routing Notes if we changed anything
            if (!changes.isEmpty()) {
                String prefix = isInsert ? 'Lead Guardrails (Insert): ' : 'Lead Guardrails (Update): ';
                l.Routing_Notes__c = prefix + String.join(changes, ' | ');
            }
        }
    }

    /**
     * Basic phone normalization:
     * - Keep digits only
     * - If 10 digits, format (XXX) XXX-XXXX
     * - Otherwise, return digits-only string
     */
    private static String normalizePhone(String input) {
        String digits = '';
        for (Integer i = 0; i < input.length(); i++) {
            String c = input.substring(i, i + 1);
            if (c >= '0' && c <= '9') digits += c;
        }

        if (digits.length() == 10) {
            return '(' + digits.substring(0, 3) + ') ' +
                   digits.substring(3, 6) + '-' +
                   digits.substring(6, 10);
        }
        return digits;
    }
}