package com.app.maidattendance.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class JoinHouseholdRequestDto {

    @NotNull(message = "Maid ID is required")
    private Long maidId;

    @NotBlank(message = "Invite code is required")
    private String inviteCode;

    public JoinHouseholdRequestDto() {}

    public JoinHouseholdRequestDto(Long maidId, String inviteCode) {
        this.maidId = maidId;
        this.inviteCode = inviteCode;
    }

    public Long getMaidId() {
        return maidId;
    }

    public void setMaidId(Long maidId) {
        this.maidId = maidId;
    }

    public String getInviteCode() {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode) {
        this.inviteCode = inviteCode;
    }
}
