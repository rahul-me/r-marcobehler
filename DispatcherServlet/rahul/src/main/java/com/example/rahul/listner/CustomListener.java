package com.example.rahul.listner;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CustomListener implements ServletContextListener {
	
	Logger logger = LoggerFactory.getLogger(CustomListener.class);
	
	@Override
	public void contextInitialized(ServletContextEvent sce) {
		logger.info("CustomListener is initialized");
	}
	
	public void contextDestroyed(ServletContextEvent sce) {
		logger.info("CustomListener is destroyed");
	}
}
