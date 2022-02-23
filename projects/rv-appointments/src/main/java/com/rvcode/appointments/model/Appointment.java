package com.rvcode.appointments.model;

public class Appointment {
    private String clientName;

    private String startTime;

    private String endTime;

    private String with;

    public Appointment(){

    }

    public Appointment(String clientName, String startTime, String endTime, String with){
        this.clientName = clientName;
        this.startTime = startTime;
        this.endTime = endTime;
        this.with = with;
    }

    public String getClientName() {
        return clientName;
    }

    public void setClientName(String clientName) {
        this.clientName = clientName;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public String getWith() {
        return with;
    }

    public void setWith(String with) {
        this.with = with;
    }

    @Override
    public String toString() {
        return "Appointment{" +
                "clientName='" + clientName + '\'' +
                ", startTime='" + startTime + '\'' +
                ", endTime='" + endTime + '\'' +
                ", with='" + with + '\'' +
                '}';
    }
}
