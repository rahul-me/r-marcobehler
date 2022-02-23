package com.rvcode.appointments.service;

public class BotService {

    private String name;

    public BotService(String name){
        this.name = name;
    }

    public String getAppointmentWithBotName(){
        int botNo = (int)(5 * Math.random());
        return botNo+"bot";
    }
}
