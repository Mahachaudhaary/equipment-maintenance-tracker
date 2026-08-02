public with sharing class ServiceReportController {

    public Service_Request__c serviceRequest { get; set; }

    public ServiceReportController() {

        Id recordId = ApexPages.currentPage().getParameters().get('id');

        serviceRequest = [

            SELECT Name,
                   Priority__c,
                   Status__c,
                   Cost__c,
                   Date_Reported__c,
                   Date_Resolved__c,
                   Description__c,
                   Resolution_Notes__c,
                   Equipment__r.Name,
                   Assigned_Technician__r.Name

            FROM Service_Request__c

            WHERE Id = :recordId

            LIMIT 1

        ];

    }

    public PageReference generateAndSavePDF() {
        // Render this same VF page as PDF
        PageReference pdfPage = Page.ServiceReportPDF;
        pdfPage.getParameters().put('id', serviceRequest.Id);
        pdfPage.setRedirect(false);

        Blob pdfBlob;
        if (Test.isRunningTest()) {
            pdfBlob = Blob.valueOf('Test PDF Content');
        } else {
            pdfBlob = pdfPage.getContentAsPDF();
        }

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Service Report - ' + serviceRequest.Name;
        cv.PathOnClient = 'ServiceReport_' + serviceRequest.Name + '.pdf';
        cv.VersionData = pdfBlob;
        cv.FirstPublishLocationId = serviceRequest.Id; // attaches it directly to the record
        insert cv;

        // Redirect back to the record after saving
        PageReference recordPage = new PageReference('/' + serviceRequest.Id);
        recordPage.setRedirect(true);
        return recordPage;
    }

}