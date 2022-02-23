package com.marcobehler.myfancypdfinvoices.service;

import com.marcobehler.myfancypdfinvoices.model.User;
import org.springframework.stereotype.Controller;

import java.util.UUID;

@Controller
public class UserService {

    public User findById(String id){
        String randomName = UUID.randomUUID().toString();
        return new User(id, randomName);
    }
}
