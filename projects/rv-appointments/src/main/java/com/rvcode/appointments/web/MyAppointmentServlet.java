package com.rvcode.appointments.web;

import com.rvcode.appointments.context.MyAppointmentConfiguration;
import com.rvcode.appointments.model.Appointment;
import com.rvcode.appointments.service.AppointmentService;
import com.rvcode.appointments.service.BotService;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class MyAppointmentServlet extends HttpServlet {

    // One appointment looks like it has duration with start time and end time, system will be owner of that
    // appointment. It is like some user makes an appointment for a client using this application
    // client name, start and end time, appointment with.

    private AppointmentService appointmentService;

    @Override
    public void init() throws ServletException {
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(MyAppointmentConfiguration.class);
        this.appointmentService = ctx.getBean(AppointmentService.class);

        AppointmentService s1 = ctx.getBean(AppointmentService.class);
        AppointmentService s2 = ctx.getBean(AppointmentService.class);
        System.out.println("app ser 1"+s1);
        System.out.println("app ser 2"+s2);

        System.out.println(s1.getBotService("name"));
        System.out.println(s2.getBotService("name"));

    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if(req.getRequestURI().equals("/appointment")){
            String cName = req.getParameter("clientName");

            Appointment appointment = appointmentService.createAppointment(cName);

            resp.setContentType("text/html;charset=UTF-8");

            resp.getWriter().print(appointment.toString());

        } else {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}
