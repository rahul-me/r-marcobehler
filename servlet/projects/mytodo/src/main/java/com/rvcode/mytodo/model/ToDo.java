package com.rvcode.mytodo.model;

public class ToDo {
    private String name;

    public ToDo(String todo){
        this.name = todo;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
