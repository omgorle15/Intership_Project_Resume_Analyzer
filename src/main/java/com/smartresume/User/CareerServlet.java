package com.smartresume.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import org.json.JSONArray;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

@WebServlet("/CareerServlet")
public class CareerServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get data from form
        String education = request.getParameter("education");
        String skills = request.getParameter("skills");
        String interests = request.getParameter("interests");
        String experience = request.getParameter("experience");

        // Prompt for AI
        String prompt = "Suggest suitable career paths for a student with:\n"
                + "Education: " + education + "\n"
                + "Skills: " + skills + "\n"
                + "Interests: " + interests + "\n"
                + "Experience: " + experience + "\n"
                + "Give clear career suggestions.";

        String apiKey = com.smartresume.config.APIConfig.OPENROUTER_API_KEY;
        URL url = new URL(com.smartresume.config.APIConfig.OPENROUTER_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setRequestMethod("POST");
        conn.setRequestProperty("Authorization", "Bearer " + apiKey);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        // JSON request body
        String jsonInput = "{"
                + "\"model\":\"openai/gpt-4o-mini\","
                + "\"messages\":[{\"role\":\"user\",\"content\":\""
                + prompt.replace("\"", "\\\"")
                + "\"}]"
                + "}";

        // Send request
        OutputStream os = conn.getOutputStream();
        os.write(jsonInput.getBytes());
        os.flush();
        os.close();

        // Read response
        BufferedReader br;

        if (conn.getResponseCode() >= 200 && conn.getResponseCode() < 300) {
            br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        } else {
            br = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
        }

        String line;
        StringBuilder result = new StringBuilder();

        while ((line = br.readLine()) != null) {
            result.append(line);
        }

        br.close();

        // Send result to JSP
        JSONObject json = new JSONObject(result.toString());

        JSONArray choices = json.getJSONArray("choices");

        JSONObject messageObj = choices.getJSONObject(0).getJSONObject("message");

        String aiMessage = messageObj.getString("content");

        request.setAttribute("careerResult", aiMessage);
        RequestDispatcher rd = request.getRequestDispatcher("/UserDashboard/careerResult.jsp");
        rd.forward(request, response);
    }
}