package com.smartresume.analysis;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import org.json.JSONArray;
import org.json.JSONObject;

import com.smartresume.config.APIConfig;


public class ResumeAnalyzer {
	
		private static final String apiKey = APIConfig.OPENROUTER_API_KEY;

    // Extract text from PDF
    public static String extractText(String filePath) {

        String text = "";

        try {

            File file = new File(filePath);

            PDDocument document = Loader.loadPDF(file);

            PDFTextStripper stripper = new PDFTextStripper();

            text = stripper.getText(document);

            document.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return text;
    }

    // Call AI
    public static String analyzeResume(String resumeText ,  String userQuery) {

        String result = "";

        try {

            URL url = new URL("https://openrouter.ai/api/v1/chat/completions");

            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            conn.setRequestMethod("POST");

            conn.setRequestProperty("Authorization", "Bearer " + apiKey);

            conn.setRequestProperty("Content-Type", "application/json");

            conn.setDoOutput(true);

            String prompt =
            		"You are an expert AI career advisor and resume analyzer.\n\n"+

            		"Analyze the following resume and generate a detailed career report.\n\n"+

            		"Your response must contain:\n"+
            		"1. ATS SCORE (out of 100)\n"+
            		"2. Resume Overview\n"+
            		"3. Detected Skills\n"+
            		"4. Recommended Career Domain\n"+
            		"5. Suggested Job Roles\n"+
            		"6. Companies that hire these roles\n"+
            		"7. Skills the candidate should learn next\n"+
            		"8. Career Roadmap\n"+
            		"9. Answer the User Query\n\n"+

            		"User Query:\n" + userQuery + "\n\n"+

            		"Resume:\n"+resumeText;

            JSONObject body = new JSONObject();

            body.put("model", "openai/gpt-4o-mini");

            JSONArray messages = new JSONArray();

            JSONObject message = new JSONObject();

            message.put("role", "user");

            message.put("content", prompt);

            messages.put(message);

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

            result = json
                    .getJSONArray("choices")
                    .getJSONObject(0)
                    .getJSONObject("message")
                    .getString("content");

        } catch (Exception e) {

            e.printStackTrace();

        }

        return result;
    }

}