package com.rvcode.mytodo.context;

import com.rvcode.mytodo.service.LoginService;
import com.rvcode.mytodo.service.ToDoService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MyToDoAppConfiguration {

    @Bean
    public LoginService loginService(){
        return new LoginService();
    }

    @Bean
    public ToDoService toDoService(){
        return new ToDoService();
    }

}
