package com.rvcode.appointments.context;

import com.rvcode.appointments.service.AppointmentService;
import com.rvcode.appointments.service.BotService;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;

import java.util.function.Function;

@Configuration
public class MyAppointmentConfiguration {

    @Bean
    public Function<String, BotService> beanFactory(){
        return name -> botService(name);
    }

    @Bean
    @Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
    public BotService botService(String name){
        return new BotService(name);
    }
    @Bean
    public AppointmentService appointmentService(){
        return new AppointmentService();
    }
}
