package com.rvcode.mytodo.service;

import com.rvcode.mytodo.model.ToDo;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class ToDoService {
    List<String> todos = new CopyOnWriteArrayList<>();

    public ToDo add(String name){
        todos.add(name);
        return new ToDo(name);
    }

    public List<String> findAll(){
        return  this.todos;
    }
}
