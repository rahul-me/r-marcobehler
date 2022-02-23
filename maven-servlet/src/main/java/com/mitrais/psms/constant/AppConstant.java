package com.mitrais.psms.constant;

public interface AppConstant {
	String FIND_STUFF = "select stuff_id, name, description, quantity, location from stuff where stuff_id = ?";
	
	String FIND_ALL = "select stuff_id, name, description, quantity, location from stuff";
	
	String SAVE = "insert into stuff (name, description, quantity, location) values (?,?,?,?)";
	
	String UPDATE = "update stuff set name = ?, description = ?, quantity = ?, location = ? where stuff_id = ?";
	
	String DELETE = "delete from stuff where stuff_id = ?";
}
