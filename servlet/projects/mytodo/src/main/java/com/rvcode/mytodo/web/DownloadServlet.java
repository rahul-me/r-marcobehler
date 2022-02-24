package com.rvcode.mytodo.web;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

@WebServlet(urlPatterns = "/download", loadOnStartup = 1)
public class DownloadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("Local port "+request.getLocalPort());
        System.out.println("Server port "+request.getServerPort());
        System.out.println("Remote port "+request.getRemotePort());

        // IMP: Difference between getServerPort and getLocalPort()
        // getServerPort() says

        response.setContentType("application/jar");
        ServletContext ctx = getServletContext();
        InputStream is = ctx.getResourceAsStream("/WEB-INF/jars/bootstrap.jar");

        int read = 0;
        byte[] bytes = new byte[1024];

        OutputStream os = response.getOutputStream();
        while((read = is.read(bytes)) != -1){
            os.write(bytes, 0, read);
        }

        os.flush();
        os.close();

    }
}
