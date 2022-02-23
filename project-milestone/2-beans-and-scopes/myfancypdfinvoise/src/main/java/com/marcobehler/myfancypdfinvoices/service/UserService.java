package com.marcobehler.myfancypdfinvoices.service;

import com.marcobehler.myfancypdfinvoices.model.User;

import java.util.UUID;

public class UserService {

    public User findById(String id){
        String randomName = UUID.randomUUID().toString();
        return new User(id, randomName);
    }
}
