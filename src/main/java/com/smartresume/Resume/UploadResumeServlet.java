package com.smartresume.Resume;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;

import com.smartresume.analysis.ResumeAnalyzer;

@WebServlet("/UploadResume")
@MultipartConfig
public class UploadResumeServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Part filePart = request.getPart("resumeFile");

        String fileName = filePart.getSubmittedFileName();

        String uploadPath = getServletContext().getRealPath("") + "uploads";

        File dir = new File(uploadPath);

        if (!dir.exists()) {
            dir.mkdir();
        }

        String filePath = uploadPath + File.separator + fileName;

        filePart.write(filePath);
        
        String userQuery = request.getParameter("userQuery");

		if(userQuery == null || userQuery.trim().isEmpty()){
		    userQuery = "No specific question asked. Provide general career advice based on the resume.";
		}
        // Extract text
        String resumeText = ResumeAnalyzer.extractText(filePath);

        // AI Analysis
        String aiResult = ResumeAnalyzer.analyzeResume(resumeText,userQuery);

        
        // Extract ATS Score
        int atsScore = 0;
        try {

            java.util.regex.Pattern pattern =
                    java.util.regex.Pattern.compile("ATS SCORE[: ]*(\\d+)", java.util.regex.Pattern.CASE_INSENSITIVE);

            java.util.regex.Matcher matcher = pattern.matcher(aiResult);

            if (matcher.find()) {
                atsScore = Integer.parseInt(matcher.group(1));
            }

        } catch (Exception e) {
            atsScore = 0;
        }

        HttpSession session = request.getSession();

        session.setAttribute("aiResponse", aiResult);
        session.setAttribute("atsScore", atsScore);
        session.setAttribute("userQuery", userQuery); 

        response.sendRedirect("UserDashboard/ATSResult.jsp");
    }
}