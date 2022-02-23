package com.rvcode.appointments.service;

import com.rvcode.appointments.model.Appointment;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.function.Function;

public class AppointmentService {

    @Autowired
    private Function<String, BotService> beanFactory;

    private List<Appointment> appointments = new CopyOnWriteArrayList<>();

    public Appointment createAppointment(String client){
        LocalDateTime start = LocalDateTime.now();
        LocalDateTime end = start.plusHours(3);
        String with = getBotService("name").getAppointmentWithBotName();
        String startTime = start.format(DateTimeFormatter.ISO_DATE_TIME);
        String endTime = end.format(DateTimeFormatter.ISO_DATE_TIME);
        Appointment ap = new Appointment(client, startTime, endTime, with);
        appointments.add(ap);
        return  ap;
    }

    public BotService getBotService(String name){
        return beanFactory.apply(name);
    }
}
