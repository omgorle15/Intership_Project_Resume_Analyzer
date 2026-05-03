package com.smartresume.jobs;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;

import org.json.JSONArray;
import org.json.JSONObject;

import com.smartresume.config.APIConfig;

@WebServlet("/GenerateJobs")
public class JobRecommendationServlet extends HttpServlet {

	private static final String apiKey = APIConfig.OPENROUTER_API_KEY;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        doPost(request, response);
    }
    
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String resumeAnalysis = (String) session.getAttribute("aiResponse");

        List<String[]> jobs = new ArrayList<>();

        try {

            URL url = new URL("https://openrouter.ai/api/v1/chat/completions");

            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + apiKey);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            String prompt =
                    "You are an AI job recommendation engine.\n\n" +

                    "Based on the following resume analysis recommend at least 20 relevant jobs.\n\n" +

                    "Return ONLY in this format:\n\n" +

                    "Job Title | Company Type | Location | Skills Needed\n\n" +

                    "Provide each job on a new line.\n\n" +

                    "Resume Analysis:\n" + resumeAnalysis;

            JSONObject body = new JSONObject();
            body.put("model", "openai/gpt-4o-mini");

            JSONArray messages = new JSONArray();

            JSONObject msg = new JSONObject();
            msg.put("role", "user");
            msg.put("content", prompt);

            messages.put(msg);

            body.put("messages", messages);

            OutputStream os = conn.getOutputStream();
            os.write(body.toString().getBytes());
            os.close();

            BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getInputStream()));

            String line;
            StringBuilder sb = new StringBuilder();

            while ((line = br.readLine()) != null) {
                sb.append(line);
            }

            br.close();

            JSONObject json = new JSONObject(sb.toString());

            String aiResponse = json
                    .getJSONArray("choices")
                    .getJSONObject(0)
                    .getJSONObject("message")
                    .getString("content");

            // Parse Jobs
            String[] lines = aiResponse.split("\n");

            for (String l : lines) {

            	if (l.contains("|")) {

            	    String cleaned = l.replaceAll("^\\d+\\.\\s*", "");

            	    String[] parts = cleaned.split("\\|");

            	    if (parts.length >= 4) {

            	        String title = parts[0].trim();
            	        String company = parts[1].trim();
            	        String location = parts[2].trim();
            	        String skills = parts[3].trim();

            	        jobs.add(new String[]{title, company, location, skills});
            	    }
            	}
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("jobs", jobs);

        RequestDispatcher rd =
                request.getRequestDispatcher("UserDashboard/Jobs.jsp");

        rd.forward(request, response);
    }
}