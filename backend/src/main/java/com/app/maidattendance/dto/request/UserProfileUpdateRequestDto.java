package com.app.maidattendance.dto.request;

public class UserProfileUpdateRequestDto {

    private String fullName;
    private String emergencyContact;
    private String servicesOffered;
    private String upiId;
    private String bankAccount;

    public UserProfileUpdateRequestDto() {}

    public UserProfileUpdateRequestDto(String fullName, String emergencyContact, String servicesOffered, String upiId, String bankAccount) {
        this.fullName = fullName;
        this.emergencyContact = emergencyContact;
        this.servicesOffered = servicesOffered;
        this.upiId = upiId;
        this.bankAccount = bankAccount;
    }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmergencyContact() { return emergencyContact; }
    public void setEmergencyContact(String emergencyContact) { this.emergencyContact = emergencyContact; }

    public String getServicesOffered() { return servicesOffered; }
    public void setServicesOffered(String servicesOffered) { this.servicesOffered = servicesOffered; }

    public String getUpiId() { return upiId; }
    public void setUpiId(String upiId) { this.upiId = upiId; }

    public String getBankAccount() { return bankAccount; }
    public void setBankAccount(String bankAccount) { this.bankAccount = bankAccount; }
}
