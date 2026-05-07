package com.smartresume.Resume;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;

import com.smartresume.analysis.ResumeAnalyzer;

@WebServlet("/UploadResume")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5 MB limit
public class UploadResumeServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Part filePart = request.getPart("resumeFile");
        if (filePart == null || filePart.getSize() == 0) {
            session.setAttribute("uploadError", "No file selected. Please choose a PDF, DOCX, or DOC file.");
            response.sendRedirect("UserDashboard/UploadResume.jsp");
            return;
        }

        String fileName  = filePart.getSubmittedFileName();
        String lowerName = fileName.toLowerCase();

        // ✅ Validate file type
        if (!lowerName.endsWith(".pdf") && !lowerName.endsWith(".docx") && !lowerName.endsWith(".doc")) {
            session.setAttribute("uploadError", "Invalid file type. Please upload a PDF, DOCX, or DOC file.");
            response.sendRedirect("UserDashboard/UploadResume.jsp");
            return;
        }

        // ✅ Validate file size (5 MB)
        if (filePart.getSize() > 5 * 1024 * 1024) {
            session.setAttribute("uploadError", "File too large. Maximum allowed size is 5 MB.");
            response.sendRedirect("UserDashboard/UploadResume.jsp");
            return;
        }

        // Save uploaded file to /uploads folder
        String uploadPath = getServletContext().getRealPath("") + "uploads";
        File dir = new File(uploadPath);
        if (!dir.exists()) dir.mkdir();

        String filePath = uploadPath + File.separator + fileName;
        filePart.write(filePath);

        String userQuery = request.getParameter("userQuery");
        if (userQuery == null || userQuery.trim().isEmpty()) {
            userQuery = "No specific question asked. Provide general career advice based on the resume.";
        }

        // ✅ extractText() now handles PDF, DOCX, and DOC
        String resumeText = ResumeAnalyzer.extractText(filePath);

        // Guard: if text extraction failed
        if (resumeText == null || resumeText.trim().isEmpty() || resumeText.startsWith("[Error")) {
            session.setAttribute("uploadError",
                "Could not read the file. Make sure it is a valid PDF, DOCX, or DOC and not password-protected.");
            response.sendRedirect("UserDashboard/UploadResume.jsp");
            return;
        }

        // AI Analysis
        String aiResult = ResumeAnalyzer.analyzeResume(resumeText, userQuery);

        // Extract ATS Score
        int atsScore = 0;
        try {
            java.util.regex.Pattern pattern =
                    java.util.regex.Pattern.compile("ATS SCORE[: ]*(\\d+)",
                            java.util.regex.Pattern.CASE_INSENSITIVE);
            java.util.regex.Matcher matcher = pattern.matcher(aiResult);
            if (matcher.find()) {
                atsScore = Integer.parseInt(matcher.group(1));
            }
        } catch (Exception e) {
            atsScore = 0;
        }

        session.setAttribute("aiResponse",  aiResult);
        session.setAttribute("atsScore",    atsScore);
        session.setAttribute("userQuery",   userQuery);
        session.setAttribute("uploadedFileName", fileName); // ✅ pass filename to result page

        response.sendRedirect("UserDashboard/ATSResult.jsp");
    }
}
