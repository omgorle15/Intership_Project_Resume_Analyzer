package com.smartresume.analysis;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

// PDFBox — existing PDF support
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

// Apache POI — DOCX (Word 2007+)
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.extractor.XWPFWordExtractor;

// Apache POI — DOC (Word 97-2003) — needs poi-scratchpad jar
import org.apache.poi.hwpf.HWPFDocument;
import org.apache.poi.hwpf.extractor.WordExtractor;

import org.json.JSONArray;
import org.json.JSONObject;

import com.smartresume.config.APIConfig;


public class ResumeAnalyzer {

    private static final String apiKey = APIConfig.OPENROUTER_API_KEY;

    /**
     * Extract text from PDF, DOCX, or DOC files.
     */
    public static String extractText(String filePath) {

        String text      = "";
        String lowerPath = filePath.toLowerCase();

        try {

            if (lowerPath.endsWith(".pdf")) {
                // ── PDF ──────────────────────────────────────────────────────
                File file = new File(filePath);
                PDDocument document = Loader.loadPDF(file);
                PDFTextStripper stripper = new PDFTextStripper();
                text = stripper.getText(document);
                document.close();

            } else if (lowerPath.endsWith(".docx")) {
                // ── DOCX (Word 2007+) ─────────────────────────────────────
                // XWPFDocument implements Closeable — safe for try-with-resources
                try (FileInputStream fis  = new FileInputStream(filePath);
                     XWPFDocument    docx = new XWPFDocument(fis)) {
                    XWPFWordExtractor extractor = new XWPFWordExtractor(docx);
                    text = extractor.getText();
                    extractor.close();
                }

            } else if (lowerPath.endsWith(".doc")) {
                // ── DOC (Word 97-2003) ────────────────────────────────────
                // ✅ FIX: WordExtractor does NOT implement AutoCloseable,
                //         so we close manually in finally block
                FileInputStream fis = null;
                HWPFDocument    doc = null;
                WordExtractor   ext = null;
                try {
                    fis  = new FileInputStream(filePath);
                    doc  = new HWPFDocument(fis);
                    ext  = new WordExtractor(doc);
                    text = ext.getText();
                } finally {
                    if (ext != null) try { ext.close(); } catch (Exception ignored) {}
                    if (doc != null) try { doc.close(); } catch (Exception ignored) {}
                    if (fis != null) try { fis.close(); } catch (Exception ignored) {}
                }

            } else {
                text = "[Unsupported file format. Please upload PDF, DOCX, or DOC.]";
            }

        } catch (Exception e) {
            e.printStackTrace();
            text = "[Error reading file: " + e.getMessage() + "]";
        }

        return text;
    }

    // ── AI Analysis — unchanged ───────────────────────────────────────────────
    public static String analyzeResume(String resumeText, String userQuery) {

        String result = "";

        try {

            URL url = new URL("https://openrouter.ai/api/v1/chat/completions");

            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + apiKey);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            String prompt =
                "You are an expert AI career advisor and resume analyzer.\n\n" +
                "Analyze the following resume and generate a detailed career report.\n\n" +
                "Your response must contain:\n" +
                "1. ATS SCORE (out of 100)\n" +
                "2. Resume Overview\n" +
                "3. Detected Skills\n" +
                "4. Recommended Career Domain\n" +
                "5. Suggested Job Roles\n" +
                "6. Companies that hire these roles\n" +
                "7. Skills the candidate should learn next\n" +
                "8. Career Roadmap\n" +
                "9. Answer the User Query\n\n" +
                "User Query:\n" + userQuery + "\n\n" +
                "Resume:\n" + resumeText;

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
