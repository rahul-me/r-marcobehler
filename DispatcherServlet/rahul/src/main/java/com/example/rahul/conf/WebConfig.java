package com.example.rahul.conf;

import javax.servlet.ServletContextListener;

import org.springframework.boot.web.servlet.ServletListenerRegistrationBean;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.example.rahul.listner.CustomListener;
import com.example.rahul.servlet.CustomServlet;

@Configuration
public class WebConfig {
	
	@Bean
	public ServletRegistrationBean customServletBean() {
		ServletRegistrationBean bean = new ServletRegistrationBean(new CustomServlet(), "/servlet");
		return bean;
	}
	
	@Bean
	public ServletListenerRegistrationBean customListenerBean() {
		ServletListenerRegistrationBean<ServletContextListener> bean = new ServletListenerRegistrationBean<>();
		bean.setListener(new CustomListener());
		return bean;
	}
}
