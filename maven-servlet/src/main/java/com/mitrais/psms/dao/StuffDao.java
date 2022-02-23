package com.mitrais.psms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import com.mitrais.psms.constant.AppConstant;
import com.mitrais.psms.model.Stuff;

public class StuffDao implements DAO<Stuff, String> {
	
	private StuffDao() {
	}
	
	private static class SingletonHelper {
		private static final StuffDao INSTACE = new StuffDao();
	}
	
	public static StuffDao getInstance() {
		return SingletonHelper.INSTACE;
	}

	@Override
	public Optional<Stuff> find(String id) throws SQLException {
		
		int stuff_id = 0, quantity = 0; 
		String name = "", description = "", location = "";
		
		Connection con = DataSourceFactory.getConnection();
		PreparedStatement pstmt = con.prepareStatement(AppConstant.FIND_STUFF);
		pstmt.setString(1, id);
		ResultSet rs = pstmt.executeQuery();
		
		if(rs.next()) {
			stuff_id = rs.getInt("stuff_id");
			name = rs.getString("name");
			description = rs.getString("description");
			quantity = rs.getInt("quantity");
			location = rs.getString("location");
		}
		return Optional.of(new Stuff(stuff_id, name, description, quantity, location));
	}

	@Override
	public List<Stuff> findAll() throws SQLException {
		
		int stuff_id = 0, quantity = 0; 
		String name = "", description = "", location = "";
		List<Stuff> stuffs = new ArrayList<Stuff>();
		
		PreparedStatement st = DataSourceFactory.getConnection().prepareStatement(AppConstant.FIND_ALL);
		ResultSet rs = st.executeQuery();
		
		while(rs.next()) {
			stuff_id = rs.getInt("stuff_id");
			name = rs.getString("name");
			description = rs.getString("description");
			quantity = rs.getInt("quantity");
			location = rs.getString("location");
			
			Stuff stuff = new Stuff(stuff_id, name, description, quantity, location);
			stuffs.add(stuff);
		}
		return stuffs;
	}

	@Override
	public boolean save(Stuff o) throws SQLException {
		PreparedStatement st = DataSourceFactory.getConnection().prepareStatement(AppConstant.SAVE);
		st.setString(1, o.getName());
		st.setString(2, o.getDescription());
		st.setInt(3, o.getQuantity());
		st.setString(4, o.getLocation());
		int rowInserted = st.executeUpdate();
		return rowInserted > 0;
	}

	@Override
	public boolean update(Stuff o) throws SQLException {
		PreparedStatement st = DataSourceFactory.getConnection().prepareStatement(AppConstant.UPDATE);
		st.setString(1, o.getName());
		st.setString(2, o.getDescription());
		st.setInt(3, o.getQuantity());
		st.setString(4, o.getLocation());
		st.setInt(5, o.getId());
		int rowInse = st.executeUpdate();
		
		return rowInse > 0;
	}

	@Override
	public boolean delete(Stuff o) throws SQLException {
		PreparedStatement st = DataSourceFactory.getConnection().prepareStatement(AppConstant.DELETE);
		st.setInt(1, o.getId());
		int rowDeleted = st.executeUpdate();
		
		return rowDeleted > 0;
	}

}
