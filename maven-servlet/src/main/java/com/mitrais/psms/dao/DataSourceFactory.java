package com.mitrais.psms.dao;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Objects;
import java.util.Properties;

import javax.sql.DataSource;

import com.mysql.cj.jdbc.MysqlDataSource;

public class DataSourceFactory {
	private final DataSource daso;
	
	public DataSourceFactory() {
		MysqlDataSource daso = new MysqlDataSource();
		String rootPath = Objects.requireNonNull(Thread.currentThread().getContextClassLoader().getResource("database.properties")).getPath();
		
		InputStream input = null;
		try {
			input = new FileInputStream(rootPath);
			Properties prop = new Properties();
			prop.load(input);
			daso.setDatabaseName(prop.getProperty("database"));
			daso.setServerName(prop.getProperty("serverName"));
			daso.setPort(Integer.parseInt(prop.getProperty("port")));
			daso.setUser(prop.getProperty("user"));
			daso.setPassword(prop.getProperty("password"));
			
		} catch (FileNotFoundException fnfe) {
			fnfe.printStackTrace();
		} catch (IOException ioe) {
			ioe.printStackTrace();
		} finally {
			if(input != null) {
				try {
					input.close();
				} catch(IOException e) {
					e.printStackTrace();
				}
			}
		}
		this.daso = daso;
	}
	
	public static Connection getConnection() throws SQLException {
		return SingletonHelper.INSTANCE.daso.getConnection();
	}
	
	private static class SingletonHelper {
		private static final DataSourceFactory INSTANCE = new DataSourceFactory();
	}
}
