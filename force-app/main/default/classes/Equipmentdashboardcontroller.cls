/**
 * Powers the equipmentDashboard LWC.
 * Returns equipment records plus rollup-style summary stats for the header bar.
 */
public with sharing class Equipmentdashboardcontroller {

    public class EquipmentWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String status;
        @AuraEnabled public String category;
        @AuraEnabled public Date warrantyExpiry;
        @AuraEnabled public Decimal totalMaintenanceCost;
        @AuraEnabled public Boolean warrantyAlert;
        @AuraEnabled public Integer openRequestCount;
    }

    public class DashboardData {
        @AuraEnabled public List<EquipmentWrapper> equipmentList;
        @AuraEnabled public Integer totalEquipment;
        @AuraEnabled public Integer underRepairCount;
        @AuraEnabled public Integer warrantyAlertCount;
        @AuraEnabled public Decimal totalMaintenanceCost;
    }

    @AuraEnabled(cacheable=true)
    public static DashboardData getDashboardData() {
        DashboardData result = new DashboardData();
        result.equipmentList = new List<EquipmentWrapper>();
        result.totalEquipment = 0;
        result.underRepairCount = 0;
        result.warrantyAlertCount = 0;
        result.totalMaintenanceCost = 0;

        // Adjust field API names below to match your org if they differ.
        List<Equipment__c> records = [
            SELECT Id, Name, Status__c, Category__c, Warranty_Expiry__c,
                   Total_Maintenance_Cost__c, Warranty_Alert__c,
                   (SELECT Id FROM Service_Requests__r WHERE Status__c != 'Closed')
            FROM Equipment__c
            ORDER BY Name ASC
            LIMIT 200
        ];

        for (Equipment__c eq : records) {
            EquipmentWrapper w = new EquipmentWrapper();
            w.id = eq.Id;
            w.name = eq.Name;
            w.status = eq.Status__c;
            w.category = eq.Category__c;
            w.warrantyExpiry = eq.Warranty_Expiry__c;
            w.totalMaintenanceCost = eq.Total_Maintenance_Cost__c == null ? 0 : eq.Total_Maintenance_Cost__c;
            w.warrantyAlert = eq.Warranty_Alert__c == true;
            w.openRequestCount = eq.Service_Requests__r != null ? eq.Service_Requests__r.size() : 0;

            result.equipmentList.add(w);
            result.totalEquipment++;
            if (eq.Status__c == 'Under Repair') {
                result.underRepairCount++;
            }
            if (w.warrantyAlert) {
                result.warrantyAlertCount++;
            }
            result.totalMaintenanceCost += w.totalMaintenanceCost;
        }

        return result;
    }
}