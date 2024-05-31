public with sharing class lwcController {
    @AuraEnabled
    public static void createContact(String contactFName, String contactLName
    , String contactEmail, String contactDepartment) {
        try {
            // Create Contact record
            Contact newContact = new Contact(
                FirstName = contactFName,
                LastName = contactLName,
                Email = contactEmail,
                Department = contactDepartment
            );
            insert newContact;
        } catch(Exception ex) {
            // Handle exception
            throw new AuraHandledException('Error creating contact: ' + ex.getMessage());
        }
    }
}
