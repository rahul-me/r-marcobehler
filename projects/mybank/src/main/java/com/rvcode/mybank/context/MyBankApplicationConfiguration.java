package com.rvcode.mybank.context;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.rvcode.mybank.ApplicationLauncher;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ComponentScan(basePackageClasses = ApplicationLauncher.class)
public class MyBankApplicationConfiguration {

    @Bean
    public ObjectMapper getObjectMapper(){
        return new ObjectMapper();
    }
}
