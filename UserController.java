package com.demo.controllers;

import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;
import java.io.*;
import java.util.Base64;
import javax.xml.parsers.*;
import org.xml.sax.InputSource;
import java.io.StringReader;

@RestController
@RequestMapping("/api")
public class UserController {

    // Hardcoded DB credentials
    private static final String DB_URL = "jdbc:mysql://prod-db:3306/appdb";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "password123";

    private static final String JWT_SECRET = "hardcoded_jwt_secret_key";
    private static final String ENCRYPTION_KEY = "1234567890123456";

    // SQL Injection vulnerability
    @GetMapping("/user")
    public String getUser(@RequestParam String username) throws Exception {
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        Statement stmt = conn.createStatement();
        // String concatenation in SQL query
        String query = "SELECT * FROM users WHERE username='" + username + "'";
        ResultSet rs = stmt.executeQuery(query);
        StringBuilder result = new StringBuilder();
        while (rs.next()) {
            result.append(rs.getString("username"));
        }
        return result.toString();
    }

    // XXE vulnerability
    @PostMapping("/xml")
    public String parseXml(@RequestBody String xmlData) throws Exception {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        // XXE not disabled!
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document doc = builder.parse(new InputSource(new StringReader(xmlData)));
        return doc.getDocumentElement().getTextContent();
    }

    // Command injection
    @GetMapping("/ping")
    public String ping(@RequestParam String host) throws Exception {
        Runtime runtime = Runtime.getRuntime();
        // Direct exec with user input
        Process process = runtime.exec("ping -c 1 " + host);
        BufferedReader reader = new BufferedReader(
            new InputStreamReader(process.getInputStream())
        );
        return reader.readLine();
    }

    // Path traversal
    @GetMapping("/file")
    public String readFile(@RequestParam String filename) throws Exception {
        // No path validation
        File file = new File("/var/www/files/" + filename);
        BufferedReader reader = new BufferedReader(new FileReader(file));
        StringBuilder content = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            content.append(line);
        }
        return content.toString();
    }

    // Insecure deserialization
    @PostMapping("/deserialize")
    public String deserialize(@RequestBody byte[] data) throws Exception {
        ByteArrayInputStream bis = new ByteArrayInputStream(data);
        ObjectInputStream ois = new ObjectInputStream(bis);
        // Unsafe deserialization
        Object obj = ois.readObject();
        return obj.toString();
    }

    // Weak crypto - DES
    @PostMapping("/encrypt")
    public String encrypt(@RequestBody String data) throws Exception {
        import javax.crypto.*;
        import javax.crypto.spec.*;
        byte[] keyBytes = "12345678".getBytes();
        SecretKeySpec key = new SecretKeySpec(keyBytes, "DES");
        Cipher cipher = Cipher.getInstance("DES/ECB/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, key);
        return Base64.getEncoder().encodeToString(cipher.doFinal(data.getBytes()));
    }

    // Sensitive data in logs
    @PostMapping("/login")
    public String login(@RequestParam String username, @RequestParam String password) {
        System.out.println("Login attempt: user=" + username + " pass=" + password);
        // Password logged in plaintext!
        return "logged";
    }
}
