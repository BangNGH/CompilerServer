package com.example.compiler_server;
import org.apache.tomcat.util.http.fileupload.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
public class ResultController {
    private final ResourceLoader resourceLoader;

    public ResultController(ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
    }


    @GetMapping("/result")
    public ResponseEntity<Resource> getResult() {
        try {
            // Load resource from classpath
            Resource resource = resourceLoader.getResource("classpath:docker/output/result.json");

            // Check if resource exists
            if (!resource.exists()) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }

            // Return resource as ResponseEntity
            return ResponseEntity.ok(resource);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    @PostMapping("/run")
    @ResponseBody
    public String runJava(@RequestBody String source) throws IOException {
        JsonObject jsonObject = new Gson().fromJson(source, JsonObject.class);
        String language = jsonObject.get("language").getAsString();
        String sourceCode = jsonObject.get("source_code").getAsString();
        String stdin = jsonObject.get("stdin")==null?null:jsonObject.get("stdin").getAsString();
        //Complete Java Compiler server
        if ("java".equals(language)) {
            String resourceDirectory = "D:\\Hutech\\DACN\\server\\compiler_server\\src\\main\\resources\\docker";
            // Tạo thư mục tmp trong thư mục resource
            String tmpDirectory = resourceDirectory + File.separator + "tmp" + File.separator + UUID.randomUUID().toString();
            File tmpFolder = new File(tmpDirectory);
            if (!tmpFolder.exists()) {
                tmpFolder.mkdirs();
            }
            // Tạo file main.java trong thư mục tmp
            String mainJavaFilePath = tmpDirectory + File.separator + "Main.java";

            try {
                FileWriter writer = new FileWriter(mainJavaFilePath);
                writer.write(sourceCode);
                writer.close();
                if (stdin!=null){
                    String inputForMainJava = tmpDirectory + File.separator + "input.txt";
                    FileWriter inputWriter = new FileWriter(inputForMainJava);
                    inputWriter.write(stdin);
                    inputWriter.close();
                }

            } catch (IOException e) {
                e.printStackTrace();
            }
            System.out.println("Đường dẫn file main.java: " + mainJavaFilePath);

            try {
                String absoluteFilePathToExecute = tmpDirectory+":/tmp";
                ProcessBuilder pb = new ProcessBuilder("cmd", "/c", "docker", "run", "--rm", "-e", "COMPILER=java", "-e", "FILE=/tmp/Main.java", "-v", absoluteFilePathToExecute, "my_java_app");
                pb.directory(new File(resourceDirectory));
                pb.inheritIO();
                // Bắt đầu tiến trình
                Process process = pb.start();

                // Đợi tiến trình kết thúc và in ra kết quả nếu cần
                int exitCode = process.waitFor();
                System.out.println("Exit code: " + exitCode);

            } catch (IOException | InterruptedException e) {
                e.printStackTrace();
            }

            // Đọc nội dung của tệp result.json
            try {
                // Đường dẫn đến file result.json
                String pathToResultJson = tmpDirectory + "/result.json";
                String resultJsonContent = new String(Files.readAllBytes(Paths.get(tmpDirectory + "/result.json")), StandardCharsets.UTF_8);
                // Xóa file main.java và thư mục tmp sau khi thực thi xong
                FileUtils.deleteDirectory(tmpFolder);
                return resultJsonContent;
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        if ("csharp".equals(language)){

        }
        return "Other Language";
    }
}
